CREATE PROC [DWSAP].[LoadOperationsMaterialDocumentItem] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 
DECLARE @ROWSINSERTED INT = 0 
      , @ROWSUPDATED INT = 0 
DECLARE @lastdatetime datetime IF (
  EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'DWSAP' AND TABLE_NAME = 'OperationsMaterialDocumentItem'
  )
) BEGIN 
SET 
  @lastdatetime = (
    SELECT ISNULL(MAX(CONVERT(datetime,ADLSTimestamp)), '1900-01-01 00:00:00') 
    FROM [DWSAP].[OperationsMaterialDocumentItem]) 
  END 
  ELSE 
  BEGIN 
       SET @lastdatetime = '1900-01-01 00:00:00' END 
--The above statement checks that if the table "OperationsMaterialDocumentItem" present in the datawarehouse or not,
--if present then getting the max of ADLSTimestamp and storing it into the variable for incremental inserts,
-- or else declaring the variable at lowest date.  
 
 
--The above statement checks the ADLStimestamp of MSEG  if it is gretaer than the value stored in lastdatetime variable,
--then deleting the common records from table "[OperationsMaterialDocumentItem]"

  IF OBJECT_ID('[Stage].[MSEG_Operations]', 'U') IS NOT NULL 
       DROP TABLE [Stage].[MSEG_Operations] 
  IF OBJECT_ID('[Stage].[BSEG_Operations]', 'U') IS NOT NULL 
       DROP TABLE [Stage].[BSEG_Operations] 
       
       CREATE TABLE [Stage].[MSEG_Operations] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([AWKEY])) AS 
       SELECT 
                      CONVERT(BIGINT, CONCAT(MBLNR,MJAHR)) AS [AWKEY], 
                      CONVERT(BIGINT,MBLNR) MBLNR, --Removing the leading zero
                      MJAHR, 
                      CONVERT(INT, ZEILE) ZEILE, --Removing the leading zero
                      WAERS, 
                      SUM(CASE WHEN SHKZG = 'S' THEN CONVERT(Decimal(15, 3), DMBTR)*-1 ELSE CONVERT(Decimal(15, 3), DMBTR) END) DMBTR, 
                      CONVERT(BIGINT, KDAUF) KDAUF, --Removing the leading zero
                      TRY_CONVERT(DATE, BUDAT_MKPF) BUDAT_MKPF, 
                      REPLACE(LTRIM(REPLACE(MATNR, '0', ' ')), ' ', '0') AS MATNR, --replacing the leading zero
                      WERKS, 
                      BWART, 
                      CHARG, 
                      KZVBR, 
                      TRY_CONVERT(DATE, CPUDT_MKPF) CPUDT_MKPF, 
                      INSMK, 
                      BWTAR, 
                      ELIKZ, 
                      BUALT, 
                      AUFNR, 
                      PPRCTR, 
                      PRCTR, 
                      BPRME, 
                      EBELN, 
                      EBELP, 
                      MANDT, 
                      CONVERT(INT, KDPOS) KDPOS, 
                      VFDAT, 
                      LGPLA, 
                      LGORT, 
                      LGTYP, 
                      SALK3, 
                      LBKUM, 
                      LGNUM, 
                      BWLVS, 
                      BESTQ, 
                      MEINS, 
                      SUM(CONVERT(Decimal(15, 3), MENGE)) AS MENGE, 
                      SUM(CONVERT(Decimal(15, 3), BPMNG)) AS BPMNG, 
                      PAOBJNR, 
                      ADLSTimestamp 
              FROM 
                      SrcSAP.ZRTR_MKPF_MSEG1 WITH(NOLOCK) 
              WHERE 
                      --filtering out the data where MATNR should be in KMAT
                      --REPLACE(LTRIM(REPLACE(MATNR,'0',' ')),' ','0') IN (SELECT KMAT FROM DWSAP.KMATConfig)
                      ADLSTimestamp > @lastdatetime 
              GROUP BY 
                      MEINS, 
                      MBLNR, 
                      MJAHR, 
                      ZEILE, 
                      WAERS, 
                      KDAUF, 
                      BUDAT_MKPF, 
                      MATNR, 
                      WERKS, 
                      BWART, 
                      CHARG, 
                      KZVBR, 
                      CPUDT_MKPF, 
                      INSMK, 
                      BWTAR, 
                      ELIKZ, 
                      BUALT, 
                      AUFNR, 
                      PPRCTR, 
                      PRCTR, 
                      BPRME, 
                      EBELN, 
                      EBELP, 
                      MANDT, 
                      KDPOS, 
                      VFDAT, 
                      LGPLA, 
                      LGORT, 
                      LGTYP, 
                      SALK3, 
                      LBKUM, 
                      LGNUM, 
                      BWLVS, 
                      BESTQ, 
                      PAOBJNR, 
                      ADLSTimestamp
--Creating Index ON MSEG Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [MSEG_AWKEY] ON [Stage].[MSEG_Operations]([AWKEY]) 
  CREATE NONCLUSTERED INDEX [MSEG_ZEILE] ON [Stage].[MSEG_Operations]([ZEILE]) 

  --Deleting the records from Fact Table
 
	DELETE [DWSAP].[OperationsMaterialDocumentItem] FROM 
               [DWSAP].[OperationsMaterialDocumentItem] 
	INNER JOIN [Stage].[MSEG_Operations] MSEG ON (MSEG.MBLNR = [DWSAP].[OperationsMaterialDocumentItem].[MaterialDocument]) 
  --WHERE MSEG.ADLSTimestamp > @lastdatetime 

 
  CREATE TABLE [Stage].[BSEG_Operations] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([AWKEY])) AS 
       SELECT 
                VBEL2, 
                CONVERT(BIGINT, BELNR) BELNR, 
                BUKRS, 
                CONVERT(BIGINT, BSEG.AWKEY) AWKEY, --Removing the leading zero
                REPLACE(LTRIM(REPLACE(BSEG.MATNR, '0', ' ')), ' ', '0') AS MATNR, --replacing the leading zero
                BSEG.WERKS, 
                GJAHR, 
                CONVERT(INT, BUZEI) BUZEI, --Removing the leading zero
                SUM(CASE WHEN SHKZG = 'S' THEN CONVERT(Decimal(15, 3), BSEG.DMBTR)*-1 ELSE CONVERT(Decimal(15, 3), BSEG.DMBTR) END) DMBTR, 
                SUM(CASE WHEN SHKZG = 'S' THEN CONVERT(Decimal(15, 3), DMBE2)*-1 ELSE CONVERT(Decimal(15, 3), DMBE2) END) DMBE2, 
                BSEG.MEINS, 
                GSBER, 
                KOKRS, 
                KOSTL, 
                KUNNR, 
                SHKZG, 
                HKONT, 
                LIFNR, 
                PSWSL, 
                HWAE2 
              FROM 
                [SrcSAP].ZRTR_BKPF_BSEG1 BSEG WITH(NOLOCK) 
                INNER JOIN [Stage].[MSEG_Operations] MSEG WITH(NOLOCK) ON CONVERT(BIGINT, BSEG.AWKEY)= MSEG.AWKEY 
                AND MSEG.ZEILE = CONVERT(INT, BUZEI) 
              --filtering out the data where AWTYP lies in 'MKPF'
              WHERE 
                [AWTYP] = 'MKPF' 
              GROUP BY 
                VBEL2, 
                BSEG.MATNR, 
                BSEG.WERKS, 
                GJAHR, 
                BELNR, 
                BUKRS, 
                BUZEI, 
                BSEG.MEINS, 
                GSBER, 
                KOKRS, 
                KOSTL, 
                KUNNR, 
                SHKZG, 
                HKONT, 
                LIFNR, 
                BSEG.AWKEY, 
                PSWSL, 
                HWAE2 
--Creating Index ON MSEG Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [BSEG_AWKEY] ON [Stage].[BSEG_Operations]([AWKEY]) 
  CREATE NONCLUSTERED INDEX [BSEG_BUZEI] ON [Stage].[BSEG_Operations]([BUZEI])
-- Inserting the records in the table
  INSERT INTO [DWSAP].[OperationsMaterialDocumentItem] 
SELECT 
  BSEG.[BELNR] AS [AccountingDocument], 
  BSEG.[BUZEI] AS [AccountingDocumentItem], 
  BSEG.[MEINS] AS [BASeUnit], 
  MSEG.[CHARG] AS [Batch], 
  BSEG.[GSBER] AS [BusinessArea], 
  BSEG.[BUKRS] AS [CompanyCode], 
  BSEG.[DMBTR] AS [Amount in Local Currency], 
  MSEG.[KZVBR] AS [ConsumptionPosting], 
  BSEG.[KOKRS] AS [ControllingArea], 
  BSEG.[KOSTL] AS [CostCenter], 
  BSEG.[KUNNR] AS [CustomerAccountNumber], 
  BSEG.[SHKZG] AS [DebitCreditCode], 
  MSEG.[CPUDT_MKPF] AS [EnteredDate], 
  BSEG.[GJAHR] AS [FiscalYear], 
  BSEG.[HKONT] AS [GLAccount], 
  MSEG.[BWART] AS [Movement Type], 
  MSEG.[INSMK] AS [InventorySpecialStockType], 
  MSEG.[BWTAR] AS [InventoryValuationType], 
  MSEG.[ELIKZ] AS [IsCompletelyDelivered], 
  MSEG.[MATNR] AS [Material Number] --replacing the leading zero
  , 
  MSEG.[MBLNR] AS [MaterialDocument], 
  MSEG.[MJAHR] AS [MaterialDocumentYear], 
  MSEG.[BUALT] AS [MaterialPriceControl], 
  MSEG.[AUFNR] AS [Order], 
  MSEG.[PPRCTR] AS [PartnerProfitCenter], 
  MSEG.[WERKS] AS [Material Plant], 
  MSEG.[BUDAT_MKPF] AS [Posting Date], 
  FORMAT(MSEG.[BUDAT_MKPF], 'yyyyMM') AS [YearMonth], 
  MSEG.[PRCTR] AS [ProfitCenter], 
  MSEG.[PAOBJNR] AS [ProfitabilitySegment], 
  MSEG.[BPRME] AS [PurchASeOrderPriceUnit], 
  MSEG.[EBELN] AS [PurchASingDocument], 
  MSEG.[EBELP] AS [PurchASingDocumentItem], 
  MSEG.[BPRME] AS [PurchASingDocumentOrderQty], 
  MSEG.[MANDT] AS [SAPClient], 
  MSEG.[KDAUF] AS [SalesDocument] --replacing the leading zero
  , 
  MSEG.[KDPOS] AS [SalesOrderItem], 
  MSEG.[VFDAT] AS [ShelfLifeExpirationDate], 
  MSEG.[LGPLA] AS [StorageBin], 
  MSEG.[LGORT] AS [StorageLocation], 
  MSEG.[LGTYP] AS [StorageType], 
  MSEG.[SALK3] AS [TotVltdStockValueInCoCodeCrcy], 
  MSEG.[LBKUM] AS [TotalVltdStockQuantity], 
  BSEG.[LIFNR] AS [Vendor], 
  MSEG.[LGNUM] AS [Warehouse], 
  MSEG.[BWLVS] AS [WarehouseMvtType], 
  MSEG.[BESTQ] AS [WarehouseStockCategory], 
  BSEG.[DMBTR] AS [AmountInCompanyCodeCurrency], 
  MSEG.[MEINS] AS [QuantityInBASeUnit], 
  MSEG.[MENGE] AS [GoodsMovementEntryQty], 
  MSEG.[BPMNG] AS [PurchASeOrderQty], 
  MSEG.[DMBTR] AS [GdsMvtExtAmtInCoCodeCrcy], 
  MSEG.[BPMNG] AS [PurchASeDocumentOrderQty], 
  BSEG.[DMBE2] AS [Amount in Local Currency2], 
  MSEG.[WAERS] AS [Local Currency], 
  BSEG.[HWAE2] AS [Local Currency2], 
  ADLSTimestamp 
FROM 
  [Stage].[MSEG_Operations] MSEG 
  JOIN [Stage].[BSEG_Operations] BSEG ON MSEG.[AWKEY] = BSEG.[AWKEY] 
  AND MSEG.ZEILE = BSEG.BUZEI 

  IF OBJECT_ID('[Stage].[MSEG_Operations]', 'U') IS NOT NULL 
       DROP TABLE [Stage].[MSEG_Operations] 
  IF OBJECT_ID('[Stage].[BSEG_Operations]', 'U') IS NOT NULL 
       DROP TABLE [Stage].[BSEG_Operations]
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
Select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated