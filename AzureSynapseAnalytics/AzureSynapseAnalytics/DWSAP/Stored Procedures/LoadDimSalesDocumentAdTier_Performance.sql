CREATE PROC [DWSAP].[LoadDimSalesDocumentAdTier_Performance] @BatchID [int],@LAStSuccessfullDWTimestamp [datetime2](0) AS 
BEGIN

		-- As per the Jira BI-13900
		DECLARE  @lastdatetime datetime
                ,@RowsInserted int = 0
                ,@RowsUpdated int = 0
                ,@IsFullLoad  bit = 0
       
		--Fetching the latest ADLSTimeStamp from the DW Table
        IF(EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'DWSAP' AND TABLE_NAME = 'DimSalesDocumentAdTier_Performance')) 
				BEGIN
                  SET @lastdatetime = (SELECT ISNULL(MAX(CONVERT(datetime,ADLSTimestamp)) ,'1900-01-01 00:00:00') 
									   FROM  DWSAP.DimSalesDocumentAdTier_Performance)
				END
        ELSE
				BEGIN
                  SET @lastdatetime = '1900-01-01 00:00:00'
				END

		--Dropping the tables if they exist
		IF OBJECT_ID ('[Stage].[Temp_DimSalesDocumentAdTier_Performance]', 'U') IS NOT NULL
			DROP TABLE [Stage].[Temp_DimSalesDocumentAdTier_Performance]

		IF OBJECT_ID ('[Stage].[LIKPLIPS_ADTier]', 'U') IS NOT NULL
			DROP TABLE [Stage].[LIKPLIPS_ADTier]


		-- Creating the CTAS and Indices for LIPS combined with LIKP to fetch the delta Sales Orders

        CREATE TABLE [Stage].[LIKPLIPS_ADTier] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([VGBEL])) AS 
        WITH LIKPLIPSCTE AS
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
        SELECT ADLSTimeStamp, VBELN, WADAT_IST, VGBEL, VGPOS, RecordType FROM LIKPLIPSCTE WHERE RNumb = 1

	 
	    --Fetching the final dataset that needs to be inserted to the final table 
	    CREATE TABLE [Stage].[Temp_DimSalesDocumentAdTier_Performance] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Sales Document])) AS
	    WITH FinalDataSetCTE AS
	    (			
				SELECT KPPS.ADLSTimeStamp,
						CONCAT (YEAR (TRY_CONVERT(date, (KPPS.[WADAT_IST]))),'-',MONTH(TRY_CONVERT(DATE, (KPPS.[WADAT_IST])))) AS [PartitionColumn],
						KPPS.VGBEL AS [Sales Document],
						KPPS.[WADAT_IST] AS [Document Date], 
						doa.[AdvantageTier] [Advantage Tier],
						doa.[AgeTierCode] AS [Age Tier],
						doa.[ProfessionalCategory] as [Professional Category],
						doa.[IsDSOOrder],
						KPPS.[RecordType],
						ROW_NUMBER() OVER (PARTITION BY KPPS.VGBEL ORDER BY KPPS.[WADAT_IST] DESC) AS RowNumber
				FROM	[Stage].[LIKPLIPS_ADTier] KPPS
						LEFT JOIN [TABSAP].[DimOrderAttributes] doa ON doa.[OrderNumber] = KPPS.VGBEL
						)
	    SELECT  ADLSTimeStamp,PartitionColumn,[Sales Document], [Document Date],[Advantage Tier],[Age Tier],[Professional Category],[IsDSOOrder],
				[RecordType],[RowNumber]
	    FROM   FinalDataSetCTE 

	    
		-- Inserting the delta Sales Documents in the DW Table
	    BEGIN TRAN

				--Inserting the records
				INSERT INTO [DWSAP].[DimSalesDocumentAdTier_Performance] ([ADLSTimeStamp], [PartitionColumn], [Sales Document], [Document Date],[Advantage Tier],
							[Age Tier], [Professional Category], [IsDSOOrder], [RecordType])
				SELECT [ADLSTimeStamp], [PartitionColumn], [Sales Document], [Document Date],[Advantage Tier],
							[Age Tier], [Professional Category], [IsDSOOrder], [RecordType]
				FROM       [Stage].[Temp_DimSalesDocumentAdTier_Performance] AS tempds
				WHERE	   tempds.RowNumber = 1 AND NOT EXISTS (SELECT 1 FROM [DWSAP].[DimSalesDocumentAdTier_Performance] tgt
																WHERE tempds.[Sales Document] = tgt.[Sales Document] )

	   COMMIT TRAN
	 

	   SELECT @RowsInserted - @RowsUpdated AS RowsInserted, @RowsUpdated AS RowsUpdated

END