CREATE PROC [DWSAP].[LoadOperationsManufacturingOrderItem] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 
DECLARE @ROWSINSERTED INT = 0 
      , @ROWSUPDATED INT = 0 
DECLARE @lastdatetime datetime IF (
  EXISTS (
    SELECT 
      * 
    FROM 
      INFORMATION_SCHEMA.TABLES 
    WHERE 
      TABLE_SCHEMA = 'DWSAP' 
      AND TABLE_NAME = 'OperationsManufacturingOrderItem'
  )
) BEGIN 
SET 
  @lastdatetime = (
    SELECT 
      ISNULL(
        MAX(
          CONVERT(datetime,ADLSTimestamp)
        ), 
        '1900-01-01 00:00:00'
      ) 
    FROM 
      [DWSAP].[OperationsManufacturingOrderItem]
  ) END ELSE BEGIN 
SET 
  @lastdatetime = '1900-01-01 00:00:00' END 
--The above statement checks that the table "OperationsManufacturingOrderItem" present in the datawarehouse or not ,
--if present then getting the max of ADLSTimestamp and storing it into the variable for incremental inserts, or else declaring
--the variable at lowest date.
  DELETE [DWSAP].[OperationsManufacturingOrderItem] 
FROM 
  [DWSAP].[OperationsManufacturingOrderItem] 
  INNER JOIN SrcSAP.ZOTC_AFKO_AFVC1 AFKO ON (
    REPLACE(
      LTRIM(
        REPLACE(AFKO.AUFNR, '0', ' ')
      ), 
      ' ', 
      '0'
    ) = [DWSAP].[OperationsManufacturingOrderItem].[Manufacturing Order]
  ) 
WHERE 
  AFKO.ADLSTimestamp > @lastdatetime print('Deleting the common Records') 
--The above statement checks the ADLStimestamp of AFKO view if it is gretaer than the value stored in lastdatetime variable,
--then deleting the common records from table "OperationsManufacturingOrderItem"
-- Inserting the records in the table
  IF OBJECT_ID(
    '[Stage].[AFKO_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[AFKO_Operations] IF OBJECT_ID(
    '[Stage].[AUFK_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[AUFK_Operations] IF OBJECT_ID(
    '[Stage].[AFPO_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[AFPO_Operations] 
  CREATE TABLE [Stage].[AFKO_Operations] WITH (
    CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([AUFNR])
  ) AS 
SELECT 
  CONVERT(BIGINT,AUFNR) AUFNR --Removing leading zeros 
  , 
  CONVERT(BIGINT,AUFPL) AUFPL --Removing leading zeros 
  , 
  TRY_CONVERT(DATE,GLTRI) GLTRI, 
  CONVERT(BIGINT,ARBID) ARBID --Removing leading zeros 
  , 
  [LTXA1], 
  ARBPL, 
  --deriving DatPrpPlant based on ARBPL
  CASE WHEN ARBPL = 'DATPRP' THEN WERKS END AS DatPrpPlant , 
  --deriving OrderAcquisition Plant based on ARBPL 
  CASE WHEN ARBPL = 'ODRACQ' THEN WERKS END AS OrdAdqPlant,
 --deriving Treatment Plant based on ARBPL
  CASE WHEN ARBPL = 'TREATM' THEN WERKS END AS TreatMPlant ,
   --deriving DDT Plant based on ARBPL
  CASE WHEN ARBPL = 'DDT' THEN WERKS END AS DDTPlant ,
  ADLSTimestamp 
FROM 
  SrcSAP.ZOTC_AFKO_AFVC1 (NOLOCK) 
--deriving the values from table where LTXA1 not equals to 'ClinCheck Approval' and ARBPL shoulb be in 'DATPRP','ODRACQ','TREATM','DDT'
WHERE 
  [LTXA1] <> 'ClinCheck Approval' 
  AND ARBPL IN ('DATPRP', 'ODRACQ', 'TREATM', 'DDT') 
  AND ADLSTimestamp > @lastdatetime --Creating Index ON AFKO Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [AFKO_VBELN] ON [Stage].[AFKO_Operations](AUFNR) 
  CREATE TABLE [Stage].[AUFK_Operations] WITH (
    CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([AUFNR])
  ) AS 
SELECT 
  CONVERT(BIGINT,AUFNR) AUFNR, 
  CONVERT(BIGINT,KDAUF) KDAUF, 
  CONVERT(INT,KDPOS) KDPOS, 
  OBJNR, 
  STAT, 
  INACT 
FROM 
  SrcSAP.ZOTC_AUFK_JEST1 (NOLOCK) 
--Creating Index ON AUFK Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [AUFK_VBELN] ON [Stage].[AUFK_Operations](AUFNR) 
  CREATE NONCLUSTERED INDEX [AUFK_STAT] ON [Stage].[AUFK_Operations](STAT) 
  CREATE TABLE [Stage].[AFPO_Operations] WITH (
    CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([AUFNR])
  ) AS 
SELECT 
  CONVERT(BIGINT,AUFNR) AUFNR, 
  CONVERT(BIGINT,KDAUF) KDAUF, 
  CONVERT(INT,KDPOS) KDPOS, 
  REPLACE(
    LTRIM(
      REPLACE(MATNR, '0', ' ')
    ), 
    ' ', 
    '0'
  ) MATNR 
FROM 
  [SrcSAP].[AFPO] (NOLOCK) 
--Creating Index ON AFPO Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [AFPO_VBELN] ON [Stage].[AFPO_Operations](AUFNR) INSERT INTO [DWSAP].[OperationsManufacturingOrderItem] 
SELECT 
  Z.[Sales Document], 
  Z.[Sales Document Item Number], 
  Z.[Mfg Order Actual End Date], 
  Z.DatPrpPlant, 
  Z.OrdAdqPlant, 
  Z.TreatMPlant, 
  Z.DDTPlant,
  Z.[Manufacturing Order], 
  Z.[Mfg Material Number], 
  Z.ADLSTimestamp, 
  Z.TXT30, 
  Plant2.[Plant Text] AS [Data Prep Plant Name], 
  Plant3.[Plant Text] AS [Order Acquisition Plant Name], 
  Plant4.[Plant Text] AS [Treatment Plant Name],
  Plant5.[Plant Text] AS [DDT Plant Name]
FROM 
  (
    SELECT 
      AUFK.KDAUF AS [Sales Document], 
      AUFK.KDPOS AS [Sales Document Item Number], 
      AFKO.GLTRI AS [Mfg Order Actual End Date], 
      --deriving the max values from the columns
      MAX(DatPrpPlant) DatPrpPlant, 
      MAX(OrdAdqPlant) OrdAdqPlant, 
      MAX(TreatMPlant) TreatMPlant, 
	  MAX(DDTPlant) DDTPlant,
      AUFK.AUFNR AS [Manufacturing Order], 
      AFPO.MATNR AS [Mfg Material Number], 
      ADLSTimestamp, 
      TJ02T.TXT30 
    FROM 
      [Stage].[AFKO_Operations] AFKO WITH(NOLOCK) 
--left Joining AFPO for extracting certain fields
      LEFT JOIN [Stage].[AFPO_Operations] AFPO WITH(NOLOCK) ON AFKO.AUFNR = AFPO.AUFNR 
--left Joining AUFK for extracting certain fields
      LEFT join [Stage].[AUFK_Operations] AUFK WITH(NOLOCK) ON AUFK.AUFNR = AFKO.AUFNR 
      AND AUFK.KDAUF = AFPO.KDAUF 
      AND AUFK.KDPOS = AFPO.KDPOS 
--left Joining TJ02T for extracting certain fields
      LEFT join (
        SELECT 
          ISTAT, 
          TXT30 
        FROM 
          [SrcSAP].[TJ02T] 
        WHERE 
          SPRAS = 'E'
      ) TJ02T on AUFK.STAT = TJ02T.ISTAT 
    GROUP BY 
      AUFK.KDAUF, 
      AUFK.KDPOS, 
      GLTRI, 
      AUFK.AUFNR, 
      MATNR, 
      ADLSTimestamp, 
      TXT30
  ) Z 
--left Joining DimPlant for extracting certain fields
  Left Join (
    Select 
      Plant, 
      [Plant Text] 
    FROM 
      [TABSAP].[DimPlant]
  ) Plant2 On [DatPrpPlant] = Plant2.Plant 
--left Joining DimPlant for extracting certain fields
  Left Join (
    Select 
      Plant, 
      [Plant Text] 
    FROM 
      [TABSAP].[DimPlant]
  ) Plant3 On [OrdAdqPlant] = Plant3.Plant 
 --left Joining DimPlant for extracting certain fields
  Left Join (
    Select 
      Plant, 
      [Plant Text] 
    FROM 
      [TABSAP].[DimPlant]
  ) Plant4 On [TreatMPlant] = Plant4.Plant 
  --left Joining DimPlant for extracting certain fields
  Left Join (
    Select 
      Plant, 
      [Plant Text] 
    FROM 
      [TABSAP].[DimPlant]
  ) Plant5 On [DDTPlant] = Plant5.Plant 
  
  
  IF OBJECT_ID(
    '[Stage].[AFKO_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[AFKO_Operations] 
  IF OBJECT_ID(
    '[Stage].[AUFK_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[AUFK_Operations] 
  IF OBJECT_ID(
    '[Stage].[AFPO_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[AFPO_Operations] 

-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
Select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated

