--BI-12996 New procedure
CREATE PROC [DWSAP].[LoadDimSalesDocumentHeaderAttr_Performance] @BatchID [int], 
@LastSuccessfullDWTimestamp [datetime2](0) AS --Set current datetime for incremental updates
BEGIN IF OBJECT_ID('[DWSAP].[VBAKS1]', 'U') IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBAKS1] IF OBJECT_ID(
    '[DWSAP].[VBPA_Pivoted_v2S1]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBPA_Pivoted_v2S1] DECLARE @lastdatetime datetime, 
  @RowsInserted int = 0, 
  @RowsUpdated int = 0, 
  @IsFullLoad bit = 0 IF (
    EXISTS (
      SELECT 
        * 
      FROM 
        INFORMATION_SCHEMA.TABLES 
      WHERE 
        TABLE_SCHEMA = 'DWSAP' 
        AND TABLE_NAME = 'DimSalesDocumentHeaderAttr_Performance'
    )
  ) BEGIN 
SET 
  @lastdatetime = (
    SELECT 
      ISNULL(
        MAX(
          CONVERT(datetime, ADLSTimestamp)
        ), 
        '1900-01-01 00:00:00'
      ) 
    FROM 
      DWSAP.DimSalesDocumentHeaderAttr_Performance
  ) END ELSE BEGIN 
SET 
  @lastdatetime = '1900-01-01 00:00:00' END CREATE TABLE [DWSAP].[VBAKS1] WITH (
    CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([VBELN])
  ) AS 
SELECT 
  ADLSTimestamp, 
  Convert(BigInt, [VBELN]) [VBELN], 
  [AUDAT], 
  [ZZAMR_DATE] 
FROM 
  [SRCSAP].[VBAK] WITH(NOLOCK) 
WHERE 
  ADLSTimestamp > @lastdatetime CREATE NONCLUSTERED INDEX VBAKS_VBELN ON [DWSAP].[VBAKS1](VBELN) CREATE TABLE [DWSAP].[VBPA_Pivoted_v2S1] WITH (
    CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([VBELN])
  ) AS 
SELECT 
  DISTINCT REPLACE(
    LTRIM(
      REPLACE(WE, '0', ' ')
    ), 
    ' ', 
    '0'
  ) WE, 
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
  Convert(BigInt, VBPA.[VBELN]) [VBELN], 
  [ZA], 
  [ZM], 
  [ZF], 
  [ZJ], 
  [ZS], 
  [ZE] 
FROM 
  DWSAP.VBPA_Pivoted_v2 VBPA WITH(NOLOCK) 
  JOIN [DWSAP].[VBAKS1] VBAK WITH(NOLOCK) ON Convert(BigInt, VBPA.[VBELN])= VBAK.[VBELN] CREATE NONCLUSTERED INDEX VBPA_Pivoted_v2S_VBELN ON [DWSAP].[VBPA_Pivoted_v2S1](VBELN) CREATE NONCLUSTERED INDEX VBPA_Pivoted_v2S_WE ON [DWSAP].[VBPA_Pivoted_v2S1](WE) DELETE DWSAP.DimSalesDocumentHeaderAttr_Performance 
FROM 
  DWSAP.DimSalesDocumentHeaderAttr_Performance 
  INNER JOIN [DWSAP].[VBAKS1] ON (
    [DWSAP].[VBAKS1].VBELN = DWSAP.DimSalesDocumentHeaderAttr_Performance.[Sales Document]
  ) 
WHERE 
  [DWSAP].[VBAKS1].ADLSTimestamp > @lastdatetime print('Deleting the common Records') INSERT INTO DWSAP.DimSalesDocumentHeaderAttr_Performance(
    [ADLSTimestamp], [PartitionColumn], 
    [Sales Document], [TreatingDoctor], 
    [ShipTo], [TreatmentLocation], [Is IO Scan], 
    [Document Date], [Advantage Tier], 
    [Align Retail], [Employee Responsible], 
    [Financial Contact], [Junior Doctor], 
    [Submitting Student], [Territory Manager], 
    [Bill - to party text], [ShipTo Text], 
    [SoldTo Text], [ProductType], [AMR Date COPA]
  ) 
Select 
  b.ADLSTimestamp, 
  CONCAT (
    YEAR (b.AUDAT), 
    '-', 
    MONTH(b.AUDAT)
  ) AS [PartitionColumn], 
  REPLACE(
    LTRIM(
      REPLACE(b.[VBELN], '0', ' ')
    ), 
    ' ', 
    '0'
  ) AS [Sales Document], 
  a.[TreatingDoctor], 
  COALESCE (
    REPLACE(
      LTRIM(
        REPLACE(a.[ShipTo], '0', ' ')
      ), 
      ' ', 
      '0'
    ), 
    REPLACE(
      LTRIM(
        REPLACE(vbpap.WE, '0', ' ')
      ), 
      ' ', 
      '0'
    )
  ) AS [ShipTo], 
  a.[TreatmentLocation], 
  a.[ISIOScan] AS [Is IO Scan], 
  b.[AUDAT] AS [Document Date], 
  a.[AdvantageTier] [Advantage Tier], 
  vbpap.[ZA] [Align Retail], 
  vbpap.[ZM] [Employee Responsible], 
  vbpap.[ZF] [Financial Contact], 
  vbpap.[ZJ] [Junior Doctor], 
  vbpap.[ZS] [Submitting Student], 
  vbpap.[ZE] [Territory Manager], 
  COALESCE (bt.AccountName, kn2.AccountName) AS [Bill - to party text], 
  COALESCE (sh.AccountName, kn.AccountName) AS [ShipTo Text], 
  COALESCE (
    sot.AccountName, kn1.AccountName
  ) AS [SoldTo Text], 
  a.[ProductType], 
  b.[ZZAMR_DATE] AS [AMR Date COPA] 
FROM 
  [DWSAP].[VBAKS1] b 
  LEFT JOIN [DWSAP].[VBPA_Pivoted_v2S1] vbpap on b.VBELN = vbpap.VBELN 
  LEFT JOIN [TabSAP].[DimOrderAttributes] a ON a.[OrderNumber] = b.[VBELN] 
  LEFT JOIN TABSAP.DimCusAccount sh on sh.AccountNumber = a.ShipTo 
  LEFT JOIN TABSAP.DimCusAccount bt on bt.AccountNumber = a.BillTo 
  LEFT JOIN TABSAP.DimCusAccount sot on sot.AccountNumber = a.SoldTo 
  LEFT JOIN TABSAP.DimCusAccount kn on vbpap.WE = kn.AccountNumber 
  LEFT JOIN TABSAP.DimCusAccount kn1 on vbpap.AG = kn1.AccountNumber 
  LEFT JOIN TABSAP.DimCusAccount kn2 on vbpap.RE = kn2.AccountNumber 
select 
  @RowsInserted - @RowsUpdated AS RowsInserted, 
  @RowsUpdated AS RowsUpdated IF OBJECT_ID('[DWSAP].[VBAKS1]', 'U') IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBAKS1] IF OBJECT_ID(
    '[DWSAP].[VBPA_Pivoted_v2S1]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBPA_Pivoted_v2S1] ----NEW JIRA BI-12223 --- Remove duplicate records from the FDL tables
  ;
WITH CTE AS (
  SELECT 
    ROW_NUMBER() OVER(
      Partition By [Sales Document], 
      [TreatingDoctor], 
      [ShipTo], 
      [TreatmentLocation], 
      [Is IO Scan], 
      [Document Date], 
      [Advantage Tier], 
      [Align Retail], 
      [Employee Responsible], 
      [Financial Contact], 
      [Junior Doctor], 
      [Submitting Student], 
      [Territory Manager], 
      [Bill - to party text], 
      [ShipTo Text], 
      [SoldTo Text], 
      [ProductType], 
      [AMR Date COPA] 
      Order By 
        [Sales Document], 
        [TreatingDoctor], 
        [ShipTo], 
        [TreatmentLocation], 
        [Is IO Scan], 
        [Document Date], 
        [Advantage Tier], 
        [Align Retail], 
        [Employee Responsible], 
        [Financial Contact], 
        [Junior Doctor], 
        [Submitting Student], 
        [Territory Manager], 
        [Bill - to party text], 
        [ShipTo Text], 
        [SoldTo Text], 
        [ProductType], 
        [AMR Date COPA], 
        [AdLSTIMESTAMP] DESC
    ) AS [ROW], 
    [Sales Document], 
    [TreatingDoctor], 
    [ShipTo], 
    [TreatmentLocation], 
    [Is IO Scan], 
    [Document Date], 
    [Advantage Tier], 
    [Align Retail], 
    [Employee Responsible], 
    [Financial Contact], 
    [Junior Doctor], 
    [Submitting Student], 
    [Territory Manager], 
    [Bill - to party text], 
    [ShipTo Text], 
    [SoldTo Text], 
    [ProductType], 
    [AMR Date COPA] 
  From 
    DWSAP.DimSalesDocumentHeaderAttr_Performance
) 
DELETE FROM 
  CTE 
WHERE 
  [ROW] > 1 END;
GO
