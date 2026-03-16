--BI-12996 New procedure
CREATE PROC [DWSAP].[LoadDimSalesDocumentHeader_Performance] @BatchID [int], 
@LastSuccessfullDWTimestamp [datetime2](0) AS --Set current datetime for incremental updates
BEGIN IF OBJECT_ID('[DWSAP].[VBAKS]', 'U') IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBAKS] IF OBJECT_ID(
    '[DWSAP].[VBPA_Pivoted_v2S]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBPA_Pivoted_v2S] DECLARE @lastdatetime datetime, 
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
        AND TABLE_NAME = 'DimSalesDocumentHeader_Performance'
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
      DWSAP.DimSalesDocumentHeader_Performance
  ) END ELSE BEGIN 
SET 
  @lastdatetime = '1900-01-01 00:00:00' END 
  
  CREATE TABLE [DWSAP].[VBAKS] WITH (CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([VBELN])
  ) AS 
SELECT 
  ADLSTimestamp, 
  Convert(BigInt, [VBELN]) [VBELN], 
  [AUART], 
  [VBTYP], 
  [FKARA], 
  [ZZDELI_CATE], 
  [VKORG], 
  [SPART], 
  [ZZCOMP_IND], 
  [BSTNK], 
  [ZZVIP_ORD], 
  [ZZSFDC_ORD], 
  [VTWEG], 
  [VKGRP], 
  [VKBUR], 
  [KOKRS], 
  [KVGR1], 
  [KVGR2], 
  [KVGR3], 
  [KVGR4], 
  [KVGR5], 
  [ZZSR_NO], 
  [ZZ_IN_COM_ID], 
  [ZZAMR_DATE], 
  [ZZTREATMENT], 
  ZZCHECK_IN, 
  [NETWR], 
  [AUDAT] 
FROM 
  [SRCSAP].[VBAK] WITH(NOLOCK) 
WHERE 
  ADLSTimestamp > @lastdatetime 
  
  CREATE NONCLUSTERED INDEX VBAKS_VBELN ON [DWSAP].[VBAKS](VBELN) 
  
  CREATE TABLE [DWSAP].[VBPA_Pivoted_v2S] WITH (CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH([VBELN])
  ) AS 
SELECT 
  DISTINCT REPLACE(
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
  Convert(BigInt, VBPA.[VBELN]) [VBELN] 
FROM 
  DWSAP.VBPA_Pivoted_v2 VBPA WITH(NOLOCK) 
  JOIN [DWSAP].[VBAKS] VBAK WITH(NOLOCK) ON Convert(BigInt, VBPA.[VBELN])= VBAK.[VBELN] 
  
  CREATE NONCLUSTERED INDEX VBPA_Pivoted_v2S_VBELN ON [DWSAP].[VBPA_Pivoted_v2S](VBELN) 
  CREATE NONCLUSTERED INDEX VBPA_Pivoted_v2S_AG ON [DWSAP].[VBPA_Pivoted_v2S](AG) 
  CREATE NONCLUSTERED INDEX VBPA_Pivoted_v2S_RE ON [DWSAP].[VBPA_Pivoted_v2S](RE) 
  
DELETE DWSAP.DimSalesDocumentHeader_Performance 
FROM 
  DWSAP.DimSalesDocumentHeader_Performance 
  INNER JOIN [DWSAP].[VBAKS] ON (
    [DWSAP].[VBAKS].VBELN = DWSAP.DimSalesDocumentHeader_Performance.[Sales Document]
  ) 
WHERE 
  [DWSAP].[VBAKS].ADLSTimestamp > @lastdatetime print('Deleting the common Records') 
  
  INSERT INTO DWSAP.DimSalesDocumentHeader_Performance(
    [ADLSTimestamp], [PartitionColumn], 
    [Sales Document], [Sales Document Type], 
    [Sales Document Category], [Billing Type], 
    [Age Tier], [Order Stages], [Stage Bucket], 
    [PatientType], [SoldTo], [CCADate], 
    [TreatmentCategory], [ClinID], [Professional Category], 
    [Advantage Program Name], [MAF], [Sales Org], 
    [Division], [Compliance Indicator], 
    [PO Number], [IDSOrderID], [SFDCOrderID], 
    [Distribution Channel], [Sales Group], 
    [Sales Office], [Controlling Area], 
    [Purchasing Org], [Unit of Dimension for length/Width/Height], 
    [Bill-to party], [Payer], [Country of ship-to party], 
    [Customer Group1], [Customer Group2], 
    [Customer Group3], [Customer Group4], 
    [Customer Group5], [Equipment Serial Num], 
    [Initiator Company Id], [Document Year], 
    [UpperAlignerStartstage], [UpperAlignerEndStage], 
    [LowerAlignerStartstage], [LowerAlignerEndStage], 
    [CustomerGroupType], [IsDSOOrder], 
    [AgeTierRange], [AgeTierDetail], 
    [AgeSegment], [AgeCategory], [TreatmentId], 
    [ECC_CCADate], [Total Net Amount], 
    [Document Date]
  ) 
SELECT 
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
  b.[AUART] [Sales Document Type], 
  b.[VBTYP] [Sales Document Category], 
  b.[FKARA] [Billing Type] --,a.[Id] [SFDC Order ID]
  , 
  a.[AgeTierCode] AS [Age Tier], 
  a.[OrderStages] AS [Order Stages], 
  a.[Stagesbucket] AS [Stage Bucket], 
  a.[PatientType], 
  COALESCE (
    REPLACE(
      LTRIM(
        REPLACE(a.[SoldTo], '0', ' ')
      ), 
      ' ', 
      '0'
    ), 
    REPLACE(
      LTRIM(
        REPLACE(vbpap.AG, '0', ' ')
      ), 
      ' ', 
      '0'
    )
  ) AS [SoldTo] --,a.[AMRDate]
  , 
  a.[CCADate] --,a.[ShipDate]
  --      ,COALESCE(a.[TreatmentCategory],case when b.[ZZDELI_CATE] = '' then Null else b.[ZZDELI_CATE] END) [TreatmentCategory]
  , 
  CASE WHEN b.[ZZDELI_CATE] = '' THEN Null ELSE b.[ZZDELI_CATE] END [TreatmentCategory] --      ,a.[TreatmentCategory]
  , 
  a.[ClinID], 
  a.[ProfessionalCategory] [Professional Category] --,d.[CertificationDate] [Certification Date]
  --,year(d.[CertificationDate]) [CertificationYear]
  , 
  a.[AdvantageProgramName] [Advantage Program Name], 
  a.[MAF] [MAF], 
  b.VKORG AS [Sales Org], 
  b.SPART AS [Division] --,e.[Country] [Treatment Location - Country]
  --,e.[CountryGroup] [Treatment Loc-Country Group]
  --,e.[RegionPC] [Treatment Loc-Region]
  --,e.[RegionGroup] [Treatment Loc-Region Group]
  --,e.[GlobalRegion] [Treatment Loc-Global Region Group]
  , 
  b.[ZZCOMP_IND] [Compliance Indicator] --JIRA /**11264**/
  , 
  b.[BSTNK] [PO Number], 
  b.[ZZVIP_ORD] AS [IDSOrderID], 
  b.[ZZSFDC_ORD] AS [SFDCOrderID] 
  /*Material*/
  
  /*Organizational Units*/
  , 
  b.[VTWEG] AS [Distribution Channel], 
  b.VKGRP AS [Sales Group], 
  b.VKBUR AS [Sales Office], 
  b.KOKRS AS [Controlling Area], 
  f.EKORG AS [Purchasing Org] 
  /*Units*/
  , 
  '' [Unit of Dimension for length/Width/Height] 
  /*Customer Data */
  , 
  COALESCE (a.[BillTo], vbpap.RE) [Bill-to party] --,concat('0000',a.[ShipTo]) [Ship-to party]
  , 
  a.[Payer] --    ,b.[KUNNR] [Sold-to party]
  , 
  sh.[Country] [Country of ship-to party] --,b.[BSTNK] [Customer number] 
  --,b.[KVGR1] [Customer Group]
  , 
  b.[KVGR1] [Customer Group1], 
  b.[KVGR2] [Customer Group2], 
  b.[KVGR3] [Customer Group3], 
  b.[KVGR4] [Customer Group4], 
  b.[KVGR5] [Customer Group5] 
  /*Additional Fields later added */
  --,c.[ZZCLINICAL] [Clinical Study]
  , 
  b.[ZZSR_NO] [Equipment Serial Num] --,b.[ZZEXT_TXID] AS [External Treatment Id]
  , 
  b.[ZZ_IN_COM_ID] AS [Initiator Company Id] --,b.[ZZCCS_DATE] AS [CCS Date]
  , 
  year(b.[AUDAT]) AS [Document Year], 
  a.UpperAlignerStartstage, 
  a.UpperAlignerEndStage, 
  a.LowerAlignerStartstage, 
  a.LowerAlignerEndStage, 
  a.[CustomerGroupType], 
  a.[IsDSOOrder], 
  age.[AgeTierRange], 
  age.[AgeTierDetail], 
  age.[AgeSegment], 
  age.[AgeCategory], 
  b.ZZTREATMENT AS [TreatmentId], 
  try_convert(date, b.ZZCHECK_IN) AS [ECC_CCADate], 
  b.NETWR AS [Total Net Amount], 
  b.[AUDAT] AS [Document Date] 
FROM 
  [DWSAP].[VBAKS] b --INNER JOIN [SrcSAP].[LIPS] lips ON lips.[VGBEL] = c.[VBELN] and lips.[VGPOS] = c.[POSNR]
  --INNER JOIN [SrcSAP].[LIKP] likp ON likp.[VBELN] = lips.[VBELN]
  LEFT JOIN [DWSAP].[VBPA_Pivoted_v2S] vbpap on b.VBELN = vbpap.VBELN -- LEFT JOIN  SrcSAP.MAKT makt on c.MATNR = makt.MATNR and makt.SPRAS = 'E'
  LEFT JOIN [TabSAP].[DimOrderAttributes] a ON a.[OrderNumber] = b.[VBELN] 
  LEFT JOIN [SrcSAPFile].[Age] age on age.AgeKey = a.[AgeTierCode] 
  LEFT JOIN [SrcSAP].[TVKO] f on f.[VKORG] = b.[VKORG] 
  LEFT JOIN TABSAP.DimCusAccount sh on sh.AccountNumber = a.ShipTo 
WHERE 
  b.ADLSTimestamp > @lastdatetime --JIRA NUMBER // BI-11264
  AND b.[VBELN] NOT IN (
    SELECT 
      OBJECTID AS Sals 
    FROM 
      SrcSAP.ZVOTC_CDHDR_POS1 zcp 
    WHERE 
      zcp.CHNGIND = 'D' 
      ANd TABNAME = 'VBAK'
  ) 
select 
  @RowsInserted - @RowsUpdated AS RowsInserted, 
  @RowsUpdated AS RowsUpdated IF OBJECT_ID('[DWSAP].[VBAKS]', 'U') IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBAKS] IF OBJECT_ID(
    '[DWSAP].[VBPA_Pivoted_v2S]', 'U'
  ) IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBPA_Pivoted_v2S] ----NEW JIRA BI-12223 --- Remove duplicate records from the FDL tables
  ;
WITH CTE AS (
  SELECT 
    ROW_NUMBER() OVER(
      Partition By [Sales Document], 
      [Sales Document Type], 
      [Sales Document Category], 
      [Billing Type], 
      [Age Tier], 
      [Order Stages], 
      [Stage Bucket], 
      [PatientType], 
      [SoldTo], 
      [CCADate], 
      [TreatmentCategory], 
      [ClinID], 
      [Professional Category], 
      [Advantage Program Name], 
      [MAF], 
      [Sales Org], 
      [Division], 
      [Compliance Indicator], 
      [PO Number], 
      [IDSOrderID], 
      [SFDCOrderID], 
      [Distribution Channel], 
      [Sales Group], 
      [Sales Office], 
      [Controlling Area], 
      [Purchasing Org], 
      [Unit of Dimension for length/Width/Height], 
      [Bill-to party], 
      [Payer], 
      [Country of ship-to party], 
      [Customer Group1], 
      [Customer Group2], 
      [Customer Group3], 
      [Customer Group4], 
      [Customer Group5], 
      [Equipment Serial Num], 
      [Initiator Company Id], 
      [Document Year], 
      [UpperAlignerStartstage], 
      [UpperAlignerEndStage], 
      [LowerAlignerStartstage], 
      [LowerAlignerEndStage], 
      [CustomerGroupType], 
      [IsDSOOrder], 
      [AgeTierRange], 
      [AgeTierDetail], 
      [AgeSegment], 
      [AgeCategory], 
      [TreatmentId], 
      [ECC_CCADate], 
      [Total Net Amount], 
      [Document Date] 
      Order By 
        [Sales Document], 
        [Sales Document Type], 
        [Sales Document Category], 
        [Billing Type], 
        [Age Tier], 
        [Order Stages], 
        [Stage Bucket], 
        [PatientType], 
        [SoldTo], 
        [CCADate], 
        [TreatmentCategory], 
        [ClinID], 
        [Professional Category], 
        [Advantage Program Name], 
        [MAF], 
        [Sales Org], 
        [Division], 
        [Compliance Indicator], 
        [PO Number], 
        [IDSOrderID], 
        [SFDCOrderID], 
        [Distribution Channel], 
        [Sales Group], 
        [Sales Office], 
        [Controlling Area], 
        [Purchasing Org], 
        [Unit of Dimension for length/Width/Height], 
        [Bill-to party], 
        [Payer], 
        [Country of ship-to party], 
        [Customer Group1], 
        [Customer Group2], 
        [Customer Group3], 
        [Customer Group4], 
        [Customer Group5], 
        [Equipment Serial Num], 
        [Initiator Company Id], 
        [Document Year], 
        [UpperAlignerStartstage], 
        [UpperAlignerEndStage], 
        [LowerAlignerStartstage], 
        [LowerAlignerEndStage], 
        [CustomerGroupType], 
        [IsDSOOrder], 
        [AgeTierRange], 
        [AgeTierDetail], 
        [AgeSegment], 
        [AgeCategory], 
        [TreatmentId], 
        [ECC_CCADate], 
        [Total Net Amount], 
        [Document Date], 
        [AdLSTIMESTAMP] DESC
    ) AS [ROW], 
    [AdLSTIMESTAMP], 
    [PartitionColumn], 
    [Sales Document], 
    [Sales Document Type], 
    [Sales Document Category], 
    [Billing Type], 
    [Age Tier], 
    [Order Stages], 
    [Stage Bucket], 
    [PatientType], 
    [SoldTo], 
    [CCADate], 
    [TreatmentCategory], 
    [ClinID], 
    [Professional Category], 
    [Advantage Program Name], 
    [MAF], 
    [Sales Org], 
    [Division], 
    [Compliance Indicator], 
    [PO Number], 
    [IDSOrderID], 
    [SFDCOrderID], 
    [Distribution Channel], 
    [Sales Group], 
    [Sales Office], 
    [Controlling Area], 
    [Purchasing Org], 
    [Unit of Dimension for length/Width/Height], 
    [Bill-to party], 
    [Payer], 
    [Country of ship-to party], 
    [Customer Group1], 
    [Customer Group2], 
    [Customer Group3], 
    [Customer Group4], 
    [Customer Group5], 
    [Equipment Serial Num], 
    [Initiator Company Id], 
    [Document Year], 
    [UpperAlignerStartstage], 
    [UpperAlignerEndStage], 
    [LowerAlignerStartstage], 
    [LowerAlignerEndStage], 
    [CustomerGroupType], 
    [IsDSOOrder], 
    [AgeTierRange], 
    [AgeTierDetail], 
    [AgeSegment], 
    [AgeCategory], 
    [TreatmentId], 
    [ECC_CCADate], 
    [Document Date], 
    [Total Net Amount] 
  From 
    DWSAP.DimSalesDocumentHeader_Performance WITH(NOLOCK) 
  WHERE 
    FORMAT(
      TRY_CONVERT(DATE, [Document Date]), 
      'yyyyMM'
    )= FORMAT(
      GETDATE(), 
      'yyyyMM'
    )
) 
DELETE FROM 
  CTE 
WHERE 
  [ROW] > 1 END;
