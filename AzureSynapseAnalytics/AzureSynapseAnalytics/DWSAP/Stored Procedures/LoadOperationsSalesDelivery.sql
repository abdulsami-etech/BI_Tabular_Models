CREATE PROC [DWSAP].[LoadOperationsSalesDelivery] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 
DECLARE @ROWSINSERTED INT = 0 
       ,@ROWSUPDATED INT = 0 
DECLARE @lastdatetime datetime 
IF (
  EXISTS (
    SELECT 
      * 
    FROM 
      INFORMATION_SCHEMA.TABLES 
    WHERE 
      TABLE_SCHEMA = 'DWSAP' 
      AND TABLE_NAME = 'OperationsSalesDeliveryDetails'
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
      [DWSAP].[OperationsSalesDeliveryDetails]
  ) END ELSE BEGIN 
SET 
  @lastdatetime = '1900-01-01 00:00:00' END 
  --The above statement checks that if the table "OperationsSalesDeliveryDetails" present in the datawarehouse or not,
  --if present then getting the max of ADLSTimestamp and storing it into the variable for incremental inserts,
  -- or else declaring the variable at lowest date.   
  DELETE [DWSAP].[OperationsSalesDeliveryDetails] 
FROM 
  [DWSAP].[OperationsSalesDeliveryDetails] 
  INNER JOIN SrcSAP.LIPS ON (
    REPLACE(
      LTRIM(
        REPLACE(LIPS.VBELN, '0', ' ')
      ), 
      ' ', 
      '0'
    ) = [DWSAP].[OperationsSalesDeliveryDetails].[Delivery Document]
  ) 
WHERE 
  SrcSAP.LIPS.ADLSTimestamp > @lastdatetime 
  print('Deleting the common Records') 
  --The above statement checks the ADLStimestamp of Lips table if it is gretaer than the value stored in lastdatetime variable,
  --then deleting the common records from table "[OperationsSalesDeliveryDetails]"
  -- Inserting the records in the table
  IF OBJECT_ID(
    '[Stage].[LIPS_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[LIPS_Operations] 
  
  IF OBJECT_ID(
    '[Stage].[VBAP_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[VBAP_Operations] 
  IF OBJECT_ID(
    '[Stage].[VBAK_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[VBAK_Operations] 
  IF OBJECT_ID(
    '[Stage].[DimOrderAttributes_Operations]', 
    'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[DimOrderAttributes_Operations] 
  IF OBJECT_ID(
    '[Stage].[VBPA_Pivoted_Operations]', 
    'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[VBPA_Pivoted_Operations] 
  CREATE TABLE [Stage].[LIPS_Operations] WITH (
    CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([VBELN])
  ) AS 
SELECT 
  PRCTR, 
  MATNR, 
  PRODH, 
  KVGR1, 
  ORMNG, 
  LGMNG, 
  SPART, 
  VTWEG, 
  VGBEL, 
  VGPOS,
  VBELN, 
  ADLSTimestamp, 
  KUNNR, 
  KUNAG, 
  WADAT_IST 
FROM 
  (
    SELECT 
      REPLACE(
        LTRIM(
          REPLACE(LIPS.PRCTR, '0', ' ')
        ), 
        ' ', 
        '0'
      ) PRCTR, 
      --Replacing the leading zeros
      REPLACE(
        LTRIM(
          REPLACE(LIPS.MATNR, '0', ' ')
        ), 
        ' ', 
        '0'
      ) MATNR, 
      --Replacing the leading zeros
      LIPS.PRODH, 
      LIPS.KVGR1, 
      SUM(LIPS.ORMNG) ORMNG, 
      SUM(LIPS.LGMNG) LGMNG, 
      LIPS.SPART, 
      LIPS.VTWEG, 
      CONVERT(BIGINT, LIPS.VGBEL) VGBEL, 
      --For Removing the leading zeros
      CONVERT(BIGINT, LIPS.VBELN) VBELN, 
      --For Removing the leading zeros
      CONVERT(INT, LIPS.VGPOS) VGPOS, 
      --For Removing the leading zeros
      LIPS.ADLSTimestamp, 
      LIKP.KUNNR, 
      LIKP.KUNAG, 
      Try_CONVERT(DATE,LIKP.WADAT_IST) WADAT_IST, 
      Row_Number() Over(
        Partition By CONVERT(BIGINT,LIPS.VGBEL), 
        CONVERT(BIGINT,LIPS.VGPOS) 
        Order BY 
          Try_CONVERT(DATE,LIKP.WADAT_IST) DESC, 
          LIPS.AEDAT DESC
      ) AS [Row] 
    FROM 
      [SrcSAP].[LIPS] LIPS WITH(NOLOCK) 
      JOIN [SrcSAP].[LIKP] LIKP WITH(NOLOCK) ON CONVERT(BIGINT, LIKP.VBELN) = CONVERT(BIGINT, LIPS.VBELN) 
       WHERE LIPS.ADLSTimestamp > @lastdatetime --filtering out the data where ADLStimestamp is greater than lstdatetime
    GROUP BY 
      PRCTR, 
      MATNR, 
      PRODH, 
      KVGR1, 
      SPART, 
      VTWEG, 
      LIPS.VGBEL, 
      LIPS.VBELN, 
      VGPOS, 
      LIPS.ADLSTimestamp, 
      LIKP.KUNNR, 
      LIKP.KUNAG, 
      Try_CONVERT(DATE,LIKP.WADAT_IST),
	  LIPS.AEDAT
  ) Z 
WHERE 
  [ROW] = 1 
--Creating Index ON LIPS Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [LIPS_VGBEL] ON [Stage].[LIPS_Operations](VGBEL) 
  CREATE NONCLUSTERED INDEX [LIPS_VBELN] ON [Stage].[LIPS_Operations](VBELN) 
  CREATE NONCLUSTERED INDEX [LIPS_VGPOS] ON [Stage].[LIPS_Operations](VGPOS) 
 
  CREATE TABLE [Stage].[VBAP_Operations] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([VBELN])) AS 
SELECT 
  Count(VBAP.VBELN) AS [SalesOrderCount], 
  CONVERT(BIGINT, VBAP.VBELN) VBELN, 
  CONVERT(INT, VBAP.POSNR) POSNR, 
  PSTYV, 
  ZZTREAT_OPT, 
  ZZDELI_TYPE, 
  SUM(ZZTOTAL_QTY) [Total Quantity], 
  SUM(ZZTOT_QTY) [Deliverable Quantity], 
  WERKS, 
  SUM(NETWR) NETWR, 
  SUM(KWMENG) KWMENG, 
  SUM(ZZFRE_QTY) ZZFRE_QTY, 
  VBAP.SPART, 
  WAERK, 
  ZZCOMP_IND 
FROM 
  [SrcSAP].[VBAP] VBAP WITH(NOLOCK) 
  JOIN [Stage].[LIPS_Operations] LIPS WITH(NOLOCK) ON CONVERT(BIGINT, VBAP.VBELN)= LIPS.VGBEL 
  AND CONVERT(INT, VBAP.POSNR)= LIPS.VGPOS 
GROUP BY 
  VBAP.VBELN, 
  PSTYV, 
  ZZTREAT_OPT, 
  ZZDELI_TYPE, 
  WERKS, 
  ZZCOMP_IND, 
  POSNR, 
  VBAP.SPART, 
  WAERK, 
  ZZCOMP_IND 
--Creating Index ON VBAP Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [VBAP_VBELN] ON [Stage].[VBAP_Operations] (VBELN) 
  CREATE NONCLUSTERED INDEX [VBAP_POSNR] ON [Stage].[VBAP_Operations] (POSNR) 
  CREATE TABLE [Stage].[VBAK_Operations] WITH (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH([VBELN])) AS --1852271
SELECT 
  DISTINCT CONVERT(BIGINT, VBAK.VBELN) AS VBELN, 
  [AUART] AS [Sales Document Type], 
  [ZZDELI_CATE] AS [TreatmentCategory], 
  [ZZTREATMENT] AS [TreatmentId], 
  [ZZSFDC_ORD] AS [SFDCOrderID], 
  [ZZVIP_ORD] AS [IDSOrderID], 
  [ZZAMR_DATE] AS [AMR Date COPA], 
  [VKGRP] AS [Sales Group], 
  [VTWEG] AS [Distribution Channel], 
  VBAK.[NETWR] AS [Total Net Amount], 
  [KVGR1] AS [Customer Group1], 
  TRY_CONVERT(DATE, [ZZCHECK_IN]) AS [ECC_CCADate] 
FROM 
  [SRCSAP].[VBAK] VBAK WITH(NOLOCK) 
  JOIN [Stage].[VBAP_Operations] VBAP WITH(NOLOCK) ON CONVERT(BIGINT, VBAK.VBELN)= VBAP.VBELN --Creating Index ON VBAK Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [VBAK_VBELN] ON [Stage].[VBAK_Operations](VBELN) 
  
  CREATE TABLE [Stage].[DimOrderAttributes_Operations] WITH (CLUSTERED COLUMNSTORE INDEX,  DISTRIBUTION = HASH([OrderNumber])) AS 
SELECT 
  REPLACE(
    LTRIM(
      REPLACE([SoldTo], '0', ' ')
    ), 
    ' ', 
    '0'
  ) [SoldTo], 
  CONVERT(BIGINT, OrderNumber) OrderNumber, 
  [BillTo], 
  ContactName, 
  [ProfessionalCategory], 
  [MAF], 
  [IsDSOOrder] 
FROM 
  TABSAP.DimOrderAttributes DOA WITH(NOLOCK) 
  JOIN [Stage].[VBAK_Operations] VBAK WITH(NOLOCK) ON CONVERT(BIGINT,DOA.OrderNumber)= VBAK.VBELN --1654850
  --Creating Index ON DimOrderAttributes Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [DimOrderAttributes_OrderNumber] ON [Stage].[DimOrderAttributes_Operations](OrderNumber) 
  
  CREATE TABLE [Stage].[VBPA_Pivoted_Operations] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([VBELN])) AS 
SELECT 
  REPLACE(
    LTRIM(
      REPLACE(AG, '0', ' ')
    ), 
    ' ', 
    '0'
  ) AG, 
  REPLACE(
    LTRIM(
      REPLACE(RE, '0', ' ')
    ), 
    ' ', 
    '0'
  ) RE, 
  REPLACE(
    LTRIM(
      REPLACE(WE, '0', ' ')
    ), 
    ' ', 
    '0'
  ) WE, 
  Convert(BigInt,VBPA.[VBELN]) [VBELN] 
FROM 
  DWSAP.VBPA_Pivoted_v2 VBPA WITH(NOLOCK) 
  JOIN [Stage].[VBAK_Operations] VBAK WITH(NOLOCK) ON CONVERT(BIGINT, VBPA.[VBELN])= VBAK.[VBELN] 
  --Creating Index ON VBPA_Pivoted Table for Fast Retrievel of DATA
  CREATE NONCLUSTERED INDEX [VBPA_Pivoted_VBELN] ON [Stage].[VBPA_Pivoted_Operations](VBELN) 
  INSERT INTO [DWSAP].[OperationsSalesDeliveryDetails] 
SELECT 
  LIPS.VGBEL AS [Sales Document], 
  LIPS.VGPOS AS [Sales Document Line Item], 
  LIPS.VBELN AS [Delivery Document], 
  VBAP.PSTYV AS [Sales Document Item Category], 
  VBAK.[Sales Group] AS [Sales Group], 
  LIPS.WADAT_IST AS [Actual Goods Movement Date], 
  LIPS.PRCTR AS [Profit Center], 
  LIPS.MATNR AS [Material], 
  LIPS.PRODH AS [Product Hierarchy Node], 
  VBAP.ZZTREAT_OPT AS [Treatment Option], 
  VBAP.ZZDELI_TYPE AS [DeliverableType], 
  VBAK.[Customer Group1] AS [Additional Customer Group1], 
  VBAP.[SalesOrderCount] AS [Sales Order Count], 
  VBAP.[Total Quantity] - VBAP.[Deliverable Quantity] AS [Attachment Template Quantity], 
  VBAP.[Total Quantity] AS [TotalQuantity], 
  VBAP.[Deliverable Quantity] AS [DeliverableQuantity], 
  VBAP.WERKS AS [Production Plant], 
  VBAK.[TreatmentCategory] AS [Treatment Category], 
  VBAK.[Sales Document Type] AS [Sales Order Type], 
  VBAK.[SFDCOrderID] AS [SFDC Order ID], 
  VBAK.[IDSOrderID] AS [IDS Order ID] 
  , 
  VBAK.[TreatmentId] AS [Treatment ID], 
  VBAK.[ECC_CCADate] AS [CCA Date], 
  VBAK.[AMR Date COPA] AS [AMR Date], 
  COALESCE (DOA.[SoldTo], vbpap.AG) AS [Sold To Party], 
  COALESCE (DOA.[BillTo], vbpap.RE) AS [Bill To Party] , 
  kn2.AccountName AS [TreatmentLocationName], 
  DOA.ContactName AS [Treating Doctor Name], 
-- deriving the Total Net Amount based on some fields
  CASE WHEN VBAP.WAERK IN (
    SELECT 
      [Total Net Amount Unit/Currency] 
    FROM 
      DWSAP.[TotalNetAmountCurrencyConfig]
  ) THEN VBAK.[Total Net Amount] * 100 ELSE VBAK.[Total Net Amount] END AS [Total Net Amount], 
  VBAP.WAERK AS [Total Net Amount Unit/Currency], 
  VBAP.KWMENG AS [Order Quantity], 
  VBAP.ZZFRE_QTY AS [FOCQuantity], 
  LIPS.ORMNG AS [Original Delivery Quantity], 
  LIPS.LGMNG AS [Actual Delivery Quantity], 
  VBAP.[ZZCOMP_IND] AS [Compliance Indicator], 
  VBAP.SPART AS [Division], 
  VBAK.[Distribution Channel] AS [Distribution Channel], 
  DOA.[ProfessionalCategory] AS [Contact Professional Category], 
  DOA.[MAF] AS [Mandular Adjustment Flag], 
  DOA.[IsDSOOrder] AS [DSO Flag], 
  [Plant Text] AS [Production Plant Name], 
  BEZEI AS [Additional Customer Group1 Description], 
  ADLSTimestamp 
  ,
  --formatting the field into date format i.e. yyyyMM
  FORMAT(LIPS.WADAT_IST, 'yyyyMM') AS [YearMonth] 
FROM 
  [Stage].[LIPS_Operations] LIPS 
--Joining the [VBAP] for extracting the certain fields
  LEFT JOIN [Stage].[VBAP_Operations] VBAP ON VBAP.VBELN = LIPS.VGBEL 
  AND VBAP.POSNR = LIPS.VGPOS 
-- Joining the table [VBAK] for extracting few fields
  LEFT JOIN [Stage].[VBAK_Operations] VBAK ON VBAP.VBELN = VBAK.VBELN 
  LEFT JOIN [Stage].[DimOrderAttributes_Operations] DOA ON DOA.OrderNumber = VBAK.VBELN 
--left Joining VBPA_Pivoted_v2 for extracting certain fields
  LEFT JOIN [Stage].[VBPA_Pivoted_Operations] vbpap on VBAK.VBELN = vbpap.VBELN 
--left Joining DimCusAccount for extracting certain fields
  LEFT JOIN (
    SELECT 
      AccountName, 
      AccountNumber 
    FROM 
      TABSAP.DimCusAccount
  ) kn2 on vbpap.WE = kn2.AccountNumber 
--left Joining [DimPlant] for extracting certain fields
  Left Join (
    Select 
      Plant, 
      [Plant Text] 
    FROM 
      [TABSAP].[DimPlant]
  ) Plant On VBAP.WERKS = Plant.Plant 
--left Joining [TVV1T] for extracting certain fields
  Left Join (
    Select 
      KVGR1, 
      BEZEI 
    FROM 
      [SrcSAP].[TVV1T] 
    WHERE 
      SPRAS = 'E'
  ) TVV1T On VBAK.[Customer Group1] = TVV1T.KVGR1 
  IF OBJECT_ID(
    '[Stage].[LIPS_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[LIPS_Operations] 
  
  IF OBJECT_ID(
    '[Stage].[VBAP_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[VBAP_Operations] 
  IF OBJECT_ID(
    '[Stage].[VBAK_Operations]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[VBAK_Operations] 
  IF OBJECT_ID(
    '[Stage].[DimOrderAttributes_Operations]', 
    'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[DimOrderAttributes_Operations] 
  IF OBJECT_ID(
    '[Stage].[VBPA_Pivoted_Operations]', 
    'U'
  ) IS NOT NULL 
DROP 
  TABLE [Stage].[VBPA_Pivoted_Operations]
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
Select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated



