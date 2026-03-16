CREATE PROC [DWSAP].[LoadDimSalesDocumentHeaderAttr_Performance] @BatchID [int],@LAStSuccessfullDWTimestamp [datetime2](0) AS 
BEGIN
	-- As per the Jira BI-13900
	DECLARE  @lastdatetime datetime
			,@RowsInserted	int = 0
			,@RowsUpdated	int = 0
			,@IsFullLoad	bit = 0

--Fetching the latest ADLSTimeStamp from the DW Table
	IF(EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'DWSAP' AND TABLE_NAME = 'DimSalesDocumentHeaderAttr_Performance')) 
		BEGIN
			SET @lastdatetime = (SELECT ISNULL(MAX(CONVERT(datetime,ADLSTimestamp)) ,'1900-01-01 00:00:00') 
								 FROM	DWSAP.DimSalesDocumentHeaderAttr_Performance)
		END
	ELSE
		BEGIN
			SET @lastdatetime = '1900-01-01 00:00:00'
		END

--Dropping the tables if they exist
	
	IF OBJECT_ID ('[Stage].[Temp_DimSalesDocumentHeaderAttr_Performance]', 'U') IS NOT NULL
		DROP TABLE [Stage].[Temp_DimSalesDocumentHeaderAttr_Performance]

	IF OBJECT_ID ('[Stage].[LIKPLIPS_HeaderAttr]', 'U') IS NOT NULL
		DROP TABLE [Stage].[LIKPLIPS_HeaderAttr]

	IF OBJECT_ID ('[Stage].[VBPA_Pivoted_HeaderAttr]', 'U') IS NOT NULL
		DROP TABLE [Stage].[VBPA_Pivoted_HeaderAttr]

	IF OBJECT_ID ('[Stage].[DimCusAccount_HeaderAttr]', 'U') IS NOT NULL
		DROP TABLE [Stage].[DimCusAccount_HeaderAttr]

	


	-- Creating the CTAS and Indices for LIPS combined with LIKP to fetch the delta Sales Orders
        CREATE TABLE [Stage].[LIKPLIPS_HeaderAttr] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([VGBEL])) AS 
        WITH LIKPLIPSHeaderAttrCTE AS
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
        SELECT ADLSTimeStamp, VBELN, WADAT_IST, VGBEL, VGPOS, RecordType FROM LIKPLIPSHeaderAttrCTE WHERE RNumb = 1

		CREATE NONCLUSTERED INDEX LIKPLIPS_HeaderAttr_VBELN ON [Stage].[LIKPLIPS_HeaderAttr](VBELN) 
		CREATE NONCLUSTERED INDEX LIKPLIPS_HeaderAttr_VGBEL ON [Stage].[LIKPLIPS_HeaderAttr](VGBEL) 
		CREATE NONCLUSTERED INDEX LIKPLIPS_HeaderAttr_VGPOS ON [Stage].[LIKPLIPS_HeaderAttr](VGPOS)

	
	
		--Creating the CTAS and Indices for VBPA_Pivoted
		CREATE TABLE [Stage].[VBPA_Pivoted_HeaderAttr] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([VBELN])) AS 
		SELECT DISTINCT REPLACE(LTRIM(REPLACE(WE, '0', ' ')),' ','0') WE, REPLACE(LTRIM(REPLACE(AG, '0', ' ')),' ','0') AG, 
						REPLACE(LTRIM(REPLACE(RE, '0', ' ')),' ','0') RE, 
						REPLACE(LTRIM(REPLACE(ZL, '0', ' ')),' ','0') ZL,
						CONVERT(BIGINT,VBPA.[VBELN]) VBELN, 
						[ZA], [ZM], [ZF], [ZJ], [ZS], [ZE] 
		FROM	[DWSAP].[VBPA_Pivoted_v2] VBPA WITH(NOLOCK) INNER JOIN 
				[Stage].[LIKPLIPS_HeaderAttr] KPPS WITH(NOLOCK) ON CONVERT(BIGINT,VBPA.[VBELN]) = KPPS.[VGBEL] 
  
		CREATE NONCLUSTERED INDEX VBPA_Pivoted_HeaderAttr_VBELN ON [Stage].[VBPA_Pivoted_HeaderAttr](VBELN) 
		CREATE NONCLUSTERED INDEX VBPA_Pivoted_HeaderAttr_WE ON [Stage].[VBPA_Pivoted_HeaderAttr](WE) 


		--Creating the CTAS for DimCusAccount
		CREATE TABLE [Stage].[DimCusAccount_HeaderAttr] WITH (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH([AccountNumber])) AS   
		SELECT DISTINCT AccountNumber,AccountName FROM TABSAP.DimCusAccount


		--Fetching the final dataset that needs to be inserted to the final table 
		CREATE TABLE [Stage].[Temp_DimSalesDocumentHeaderAttr_Performance] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Sales Document])) AS
		WITH FinalHeaderAttrCTE AS
		(		SELECT  KPPS.ADLSTimeStamp,
						CONCAT (YEAR (TRY_CONVERT(date, (KPPS.[WADAT_IST]))),'-',MONTH(TRY_CONVERT(DATE, (KPPS.[WADAT_IST])))) AS [PartitionColumn],
						KPPS.VGBEL AS [Sales Document],
						doa.[TreatingDoctor], 
			 -- As per the Jira BI-13936, Fetching ShipTo and Treatment Location below from SAP first and then checking with SFDC
						COALESCE(vbpap.WE,doa.[ShipTo]) AS [ShipTo], 
						COALESCE(vbpap.ZL,doa.[TreatmentLocation]) AS TreatmentLocation, 
						doa.[ISIOScan] AS [Is IO Scan], 
						KPPS.[WADAT_IST] AS [Document Date], 
						vbpap.[ZA] [Align Retail], 
						vbpap.[ZM] [Employee Responsible], 
						vbpap.[ZF] [Financial Contact], 
						vbpap.[ZJ] [Junior Doctor], 
						vbpap.[ZS] [Submitting Student], 
						vbpap.[ZE] [Territory Manager], 
						COALESCE (kn2.AccountName, bt.AccountName ) AS [Bill-to party text], 
						COALESCE (kn.AccountName, sh.AccountName) AS [ShipTo Text], 
						COALESCE (kn1.AccountName, sot.AccountName ) AS [SoldTo Text],  
						doa.[ProductType], 
						VBAK.[ZZAMR_DATE] AS [AMR Date COPA],
						KPPS.[RecordType],
						ROW_NUMBER() OVER (PARTITION BY KPPS.VGBEL ORDER BY KPPS.[WADAT_IST] DESC) AS RowNumber
					
				FROM	[Stage].[LIKPLIPS_HeaderAttr] KPPS
						LEFT JOIN  [SrcSAP].[VBAP] VBAP (NOLOCK) ON CONVERT(BIGINT,VBAP.VBELN) = KPPS.VGBEL AND CONVERT(INT,VBAP.POSNR) = KPPS.VGPOS
						LEFT JOIN  [SrcSAP].[VBAK] VBAK (NOLOCK) ON VBAK.VBELN = VBAP.VBELN 
						LEFT JOIN  [Stage].[VBPA_Pivoted_HeaderAttr] vbpap ON vbpap.VBELN = KPPS.VGBEL
						LEFT JOIN  [TABSAP].[DimOrderAttributes] doa ON doa.[OrderNumber] = KPPS.[VGBEL] 
						LEFT JOIN  [Stage].[DimCusAccount_HeaderAttr] sh ON sh.AccountNumber = doa.ShipTo 
						LEFT JOIN  [Stage].[DimCusAccount_HeaderAttr] bt ON bt.AccountNumber = doa.BillTo 
						LEFT JOIN  [Stage].[DimCusAccount_HeaderAttr] sot ON sot.AccountNumber = doa.SoldTo 
						LEFT JOIN  [Stage].[DimCusAccount_HeaderAttr] kn ON vbpap.WE = kn.AccountNumber 
						LEFT JOIN  [Stage].[DimCusAccount_HeaderAttr] kn1 ON vbpap.AG = kn1.AccountNumber 
						LEFT JOIN  [Stage].[DimCusAccount_HeaderAttr] kn2 ON vbpap.RE = kn2.AccountNumber )
			SELECT ADLSTimeStamp, [PartitionColumn], [Sales Document], [TreatingDoctor], [ShipTo], 
				   [TreatmentLocation],[Is IO Scan], [Document Date], [Align Retail],[Employee Responsible], [Financial Contact], [Junior Doctor], 
				   [Submitting Student], [Territory Manager], [Bill-to party text], [ShipTo Text], [SoldTo Text], [ProductType], [AMR Date COPA],
				   [RecordType],[RowNumber]
		           from FinalHeaderAttrCTE
			
-- Inserting the delta Sales Documents to the DW Table 
	BEGIN TRAN

			
			--Inserting the records
			INSERT INTO [DWSAP].[DimSalesDocumentHeaderAttr_Performance] ([ADLSTimestamp], [PartitionColumn],[Sales Document], [TreatingDoctor], 
						[ShipTo], [TreatmentLocation], [Is IO Scan],[Document Date], [Align Retail], [Employee Responsible], 
						[Financial Contact], [Junior Doctor], [Submitting Student], [Territory Manager], [Bill-to party text], [ShipTo Text], 
						[SoldTo Text], [ProductType], [AMR Date COPA], [RecordType])
			SELECT	ADLSTimeStamp, [PartitionColumn], [Sales Document], [TreatingDoctor], [ShipTo], 
					[TreatmentLocation],[Is IO Scan], [Document Date], [Align Retail],[Employee Responsible], [Financial Contact], [Junior Doctor], 
					[Submitting Student], [Territory Manager], [Bill-to party text], [ShipTo Text], [SoldTo Text], [ProductType], [AMR Date COPA], 
					[RecordType]
			FROM	[Stage].[Temp_DimSalesDocumentHeaderAttr_Performance] AS tempds
			WHERE   tempds.RowNumber = 1 AND NOT EXISTS (SELECT 1 FROM [DWSAP].[DimSalesDocumentHeaderAttr_Performance] tgt
																WHERE tempds.[Sales Document] = tgt.[Sales Document] )

	COMMIT TRAN
	

	SELECT @RowsInserted - @RowsUpdated AS RowsInserted, @RowsUpdated AS RowsUpdated

END

