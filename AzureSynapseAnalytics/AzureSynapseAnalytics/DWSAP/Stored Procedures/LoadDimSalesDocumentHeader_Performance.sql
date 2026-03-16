CREATE PROC [DWSAP].[LoadDimSalesDocumentHeader_Performance] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS --Set current datetime for 
BEGIN 

		-- As per the Jira BI-13900
		DECLARE  @lastdatetime datetime
				,@RowsInserted	int = 0
				,@RowsUpdated	int = 0
				,@IsFullLoad	bit = 0

		--Fetching the latest ADLSTimeStamp from the DW Table
		IF(EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'DWSAP' AND TABLE_NAME = 'DimSalesDocumentHeader_Performance')) 
			BEGIN
				SET @lastdatetime = (SELECT ISNULL(MAX(CONVERT(datetime,ADLSTimestamp)) ,'1900-01-01 00:00:00') 
										FROM	DWSAP.DimSalesDocumentHeader_Performance)
			END
		ELSE
			BEGIN
				SET @lastdatetime = '1900-01-01 00:00:00'
			END

		--Dropping the tables if they exist
		IF OBJECT_ID ('[Stage].[Temp_DimSalesDocumentHeader_Performance]', 'U') IS NOT NULL
			DROP TABLE [Stage].[Temp_DimSalesDocumentHeader_Performance]

		IF OBJECT_ID ('[Stage].[LIKPLIPS_Header]', 'U') IS NOT NULL
			DROP TABLE [Stage].[LIKPLIPS_Header]

		
		-- Creating the CTAS and Indices for LIPS combined with LIKP to fetch the delta Sales Orders
        CREATE TABLE [Stage].[LIKPLIPS_Header] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([VGBEL])) AS 
        WITH LIKPLIPSHeaderCTE AS
        (
				SELECT ADLSTimeStamp, VBELN, WADAT_IST, VGBEL, VGPOS, RecordType, ROW_NUMBER() OVER (PARTITION BY VGBEL ORDER BY RecordType DESC, WADAT_IST DESC) AS RNumb  FROM (

				SELECT LIPS.ADLSTimeStamp, CONVERT(BIGINT, LIKP.[VBELN]) [VBELN], WADAT_IST, CONVERT(BIGINT,LIPS.[VGBEL]) [VGBEL], 
						CONVERT(INT,LIPS.[VGPOS]) [VGPOS], 'Shipment' AS RecordType
				FROM   SrcSAP.LIPS LIPS WITH(NOLOCK) 
						INNER JOIN SrcSAP.LIKP LIKP  WITH(NOLOCK)  ON LIKP.VBELN = LIPS.VBELN
				WHERE  (LIPS.ADLSTimestamp > @lastdatetime OR LIKP.ADLSTimestamp > @lastdatetime) AND LIKP.[WADAT_IST] <> '00000000' AND LIKP.[WADAT_IST] <> '' 
						AND LIKP.[WADAT_IST] IS NOT NULL

		--Added the below code to bring the additional sales orders from Revenue based on the Order Type
		--As per the Jira BI-14015

				UNION ALL
		
				SELECT CE11.ADLSTimeStamp, NULL AS VBELN, VBAK.AUDAT AS WADAT_IST, CONVERT(BIGINT, CE11.KAUFN) [VGBEL], 
					    CONVERT(INT,CE11.[KDPOS]) [VGPOS], 'Revenue' AS RecordType
				FROM   SrcSAP.CE110US (NOLOCK) CE11 
						INNER JOIN SrcSAP.VBAK VBAK (NOLOCK) ON CE11.KAUFN = VBAK.VBELN
				WHERE  CE11.ADLSTimeStamp > @lastdatetime
					   AND VBAK.AUART IN ('Z08','Z09','Z10','Z14','Z15','Z16','Z20','Z22','Z23','Z24','Z26')) CombDS
        )
         SELECT ADLSTimeStamp, VBELN, WADAT_IST, VGBEL, VGPOS, RecordType FROM LIKPLIPSHeaderCTE WHERE RNumb = 1

		CREATE NONCLUSTERED INDEX LIKPLIPS_Header_VBELN ON [Stage].[LIKPLIPS_Header](VBELN) 
		CREATE NONCLUSTERED INDEX LIKPLIPS_Header_VGBEL ON [Stage].[LIKPLIPS_Header](VGBEL) 
		CREATE NONCLUSTERED INDEX LIKPLIPS_Header_VGPOS ON [Stage].[LIKPLIPS_Header](VGPOS)


		--Fetching the final dataset that needs to be inserted to the final table 
		CREATE TABLE [Stage].[Temp_DimSalesDocumentHeader_Performance] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Sales Document])) AS
		WITH FinalHeaderCTE AS
		(		SELECT	KPPS.ADLSTimestamp, 
						CONCAT (YEAR (TRY_CONVERT(date, (KPPS.[WADAT_IST]))),'-',MONTH(TRY_CONVERT(DATE, (KPPS.[WADAT_IST])))) AS [PartitionColumn], 
						KPPS.VGBEL AS [Sales Document], 
						VBAK.[AUART] [Sales Document Type], 
						VBAK.[VBTYP] [Sales Document Category], 
						VBAK.[FKARA] [Billing Type], 
						doa.[OrderStages] AS [Order Stages], 
						doa.[Stagesbucket] AS [Stage Bucket], 
						doa.[PatientType], 
            -- As per the Jira BI-13936, Fetching SoldTo and BillTo below from SAP first and then checking with SFDC
						COALESCE (REPLACE(LTRIM(REPLACE(AG, '0', ' ')),' ','0'),doa.[SoldTo]) AS [SoldTo] 
						,doa.[CCADate]
						,CASE WHEN VBAK.[ZZDELI_CATE] = '' THEN NULL ELSE VBAK.[ZZDELI_CATE] END [TreatmentCategory] 
						,doa.[ClinID]
						,doa.[AdvantageProgramName] [Advantage Program Name]
						,doa.[MAF] [MAF]
						,VBAK.VKORG AS [Sales Org]
						,VBAK.SPART AS [Division] 
						,VBAK.[ZZCOMP_IND] [Compliance Indicator]
						,VBAK.[BSTNK] [PO Number]
						,VBAK.[ZZVIP_ORD] AS [IDSOrderID]
						,VBAK.[ZZSFDC_ORD] AS [SFDCOrderID] 
						,VBAK.[VTWEG] AS [Distribution Channel]
						,VBAK.VKGRP AS [Sales Group]
						,VBAK.VKBUR AS [Sales Office]
						,VBAK.KOKRS AS [Controlling Area]
						,TVKO.EKORG AS [Purchasing Org] 
						,'' [Unit of Dimension for length/Width/Height] 
						,COALESCE (REPLACE(LTRIM(REPLACE(RE, '0', ' ')),' ','0'),doa.[BillTo]) [Bill-to party] 
						,doa.[Payer] 
						,sh.[Country] [Country of ship-to party] 
						,VBAK.[KVGR1] [Customer Group1]
						,VBAK.[KVGR2] [Customer Group2]
						,VBAK.[KVGR3] [Customer Group3]
						,VBAK.[KVGR4] [Customer Group4]
						,VBAK.[KVGR5] [Customer Group5] 
						,VBAK.[ZZSR_NO] [Equipment Serial Num] 
						,VBAK.[ZZ_IN_COM_ID] AS [Initiator Company Id] 
						,YEAR (TRY_CONVERT(date, (KPPS.[WADAT_IST]))) AS [Document Year]
						,doa.UpperAlignerStartstage
						,doa.UpperAlignerEndStage
						,doa.LowerAlignerStartstage
						,doa.LowerAlignerEndStage
						,doa.[CustomerGroupType]
						,age.[AgeTierRange]
						,age.[AgeTierDetail]
						,age.[AgeSegment]
						,age.[AgeCategory]
						,VBAK.ZZTREATMENT AS [TreatmentId], 
						TRY_CONVERT(DATE, VBAK.ZZCHECK_IN) AS [ECC_CCADate], 
						VBAK.NETWR AS [Total Net Amount], 
						KPPS.[WADAT_IST] AS [Document Date],
						KPPS.[RecordType],
						ROW_NUMBER() OVER (PARTITION BY KPPS.VGBEL ORDER BY KPPS.[WADAT_IST] DESC) AS RowNumber

				FROM	[Stage].[LIKPLIPS_Header] KPPS
						LEFT JOIN  [SrcSAP].[VBAP] VBAP (NOLOCK) ON CONVERT(BIGINT,VBAP.VBELN) = KPPS.VGBEL AND CONVERT(INT,VBAP.POSNR) = KPPS.VGPOS
						LEFT JOIN  [SrcSAP].[VBAK] VBAK (NOLOCK) ON VBAK.VBELN = VBAP.VBELN 
						LEFT JOIN  [DWSAP].[VBPA_Pivoted_v2] vbpap ON CONVERT(BIGINT,vbpap.VBELN) = KPPS.VGBEL 
						LEFT JOIN  [TABSAP].[DimOrderAttributes] doa ON doa.[OrderNumber] = KPPS.[VGBEL] 
						LEFT JOIN  [SrcSAPFile].[Age] age on age.AgeKey = doa.[AgeTierCode] 
						LEFT JOIN  [SrcSAP].[TVKO] TVKO on TVKO.[VKORG] = VBAK.[VKORG] 
						LEFT JOIN  TABSAP.DimCusAccount sh on sh.AccountNumber = doa.[SoldTo] )
		SELECT 	[ADLSTimestamp], [PartitionColumn], [Sales Document], [Sales Document Type], [Sales Document Category], [Billing Type], 
				[Order Stages], [Stage Bucket], [PatientType], [SoldTo], [CCADate],	[TreatmentCategory], [ClinID], 
				[Advantage Program Name], [MAF], [Sales Org], [Division], [Compliance Indicator], [PO Number], [IDSOrderID], [SFDCOrderID], 
				[Distribution Channel], [Sales Group], [Sales Office], [Controlling Area], [Purchasing Org], [Unit of Dimension for length/Width/Height], 
				[Bill-to party], [Payer], [Country of ship-to party], [Customer Group1], [Customer Group2], [Customer Group3], [Customer Group4], 
				[Customer Group5], [Equipment Serial Num], [Initiator Company Id], [Document Year], [UpperAlignerStartstage], [UpperAlignerEndStage], 
				[LowerAlignerStartstage], [LowerAlignerEndStage], [CustomerGroupType], [AgeSegment], [AgeCategory], [TreatmentId], 
				[ECC_CCADate], [Total Net Amount], [Document Date], [RecordType], [RowNumber]
				From FinalHeaderCTE
	

		-- Inserting the delta Sales Documents in the DW Table
		BEGIN TRAN
					  
		
			--Inserting the records
			INSERT INTO [DWSAP].[DimSalesDocumentHeader_Performance] ([ADLSTimestamp], [PartitionColumn], [Sales Document], [Sales Document Type], [Sales Document Category], [Billing Type], 
						[Order Stages], [Stage Bucket], [PatientType], [SoldTo], [CCADate],	[TreatmentCategory], [ClinID], 
						[Advantage Program Name], [MAF], [Sales Org], [Division], [Compliance Indicator], [PO Number], [IDSOrderID], [SFDCOrderID], 
						[Distribution Channel], [Sales Group], [Sales Office], [Controlling Area], [Purchasing Org], [Unit of Dimension for length/Width/Height], 
						[Bill-to party], [Payer], [Country of ship-to party], [Customer Group1], [Customer Group2], [Customer Group3], [Customer Group4], 
						[Customer Group5], [Equipment Serial Num], [Initiator Company Id], [Document Year], [UpperAlignerStartstage], [UpperAlignerEndStage], 
						[LowerAlignerStartstage], [LowerAlignerEndStage], [CustomerGroupType], [AgeSegment], [AgeCategory], [TreatmentId], 
						[ECC_CCADate], [Total Net Amount], [Document Date], [RecordType])
				SELECT	[ADLSTimestamp], [PartitionColumn], [Sales Document], [Sales Document Type], [Sales Document Category], [Billing Type], 
						[Order Stages], [Stage Bucket], [PatientType], [SoldTo], [CCADate],	[TreatmentCategory], [ClinID], 
						[Advantage Program Name], [MAF], [Sales Org], [Division], [Compliance Indicator], [PO Number], [IDSOrderID], [SFDCOrderID], 
						[Distribution Channel], [Sales Group], [Sales Office], [Controlling Area], [Purchasing Org], [Unit of Dimension for length/Width/Height], 
						[Bill-to party], [Payer], [Country of ship-to party], [Customer Group1], [Customer Group2], [Customer Group3], [Customer Group4], 
						[Customer Group5], [Equipment Serial Num], [Initiator Company Id], [Document Year], [UpperAlignerStartstage], [UpperAlignerEndStage], 
						[LowerAlignerStartstage], [LowerAlignerEndStage], [CustomerGroupType], [AgeSegment], [AgeCategory], [TreatmentId], 
						[ECC_CCADate], [Total Net Amount], [Document Date], [RecordType]
				FROM	[Stage].[Temp_DimSalesDocumentHeader_Performance] AS tempds
				WHERE   tempds.RowNumber = 1 AND NOT EXISTS (SELECT 1 FROM [DWSAP].[DimSalesDocumentHeader_Performance] tgt
																WHERE tempds.[Sales Document] = tgt.[Sales Document] )

		COMMIT TRAN

	SELECT @RowsInserted - @RowsUpdated AS RowsInserted, @RowsUpdated AS RowsUpdated

   END