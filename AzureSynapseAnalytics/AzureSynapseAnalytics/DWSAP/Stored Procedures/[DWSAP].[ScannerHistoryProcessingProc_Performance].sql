--BI-12996 New procedure
CREATE PROC [DWSAP].[ScannerHistoryProcessingProc_Performance] @BatchID [int], 
@LastSuccessfullDWTimestamp [datetime2](0) AS BEGIN IF OBJECT_ID('[DWSAP].[VBAPH]', 'U') IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBAPH] IF OBJECT_ID(
    'TEMPDB..#temp_ScannerHistory', 
    'U'
  ) IS NOT NULL 
DROP 
  TABLE #temp_ScannerHistory
  CREATE TABLE [DWSAP].[VBAPH] WITH (
    CLUSTERED COLUMNSTORE INDEX, 
    DISTRIBUTION = HASH(VBELN)
  ) AS 
SELECT 
  CONVERT(BIGINT, VBAP.[VBELN]) [VBELN], 
  CONVERT(BIGINT, VBAP.[POSNR]) [POSNR], 
  CASE WHEN VBAK.[ZZDELI_CATE] = 'Primary' THEN 'Paid' WHEN VBAK.[ZZDELI_CATE] = 'Secondary' 
  AND VBAP.ZZDELI_TYPE IN (
    SELECT 
      OPERAND1 
    FROM 
      [SrcSAPFile].[VolumeConfig] 
    WHERE 
      [NAME] IN (
        'DELV_TYPE_FOC', 'DELV_TYPE_DELV_QTY'
      )
  ) 
  AND VBAP.[ZZFRE_QTY] = 0 THEN 'Paid' WHEN VBAK.[ZZDELI_CATE] = 'Secondary' 
  AND VBAP.ZZDELI_TYPE IN (
    SELECT 
      OPERAND1 
    FROM 
      [SrcSAPFile].[VolumeConfig] 
    WHERE 
      [NAME] IN (
        'DELV_TYPE_FOC', 'DELV_TYPE_DELV_QTY'
      )
  ) 
  AND VBAP.[ZZFRE_QTY] = VBAP.[ZZTOT_QTY] THEN 'Free' WHEN VBAK.[ZZDELI_CATE] = 'Secondary' 
  AND VBAP.ZZDELI_TYPE IN (
    SELECT 
      OPERAND1 
    FROM 
      [SrcSAPFile].[VolumeConfig] 
    WHERE 
      [NAME] IN (
        'DELV_TYPE_FOC', 'DELV_TYPE_DELV_QTY'
      )
  ) 
  AND (
    VBAP.[ZZTOT_QTY] - VBAP.[ZZFRE_QTY]
  ) > 0 THEN 'Paid' WHEN VBAK.[ZZDELI_CATE] = 'Secondary' 
  AND VBAP.ZZDELI_TYPE IN (
    SELECT 
      OPERAND1 
    FROM 
      [SrcSAPFile].[VolumeConfig] 
    WHERE 
      [NAME] IN (
        'DELV_TYPE_FOC', 'DELV_TYPE_DELV_QTY'
      )
  ) 
  AND (
    VBAP.[ZZTOT_QTY] - VBAP.[ZZFRE_QTY]
  ) < 0 THEN 'Error' WHEN VBAK.[ZZDELI_CATE] = 'Secondary' 
  AND VBAP.ZZDELI_TYPE NOT IN (
    SELECT 
      OPERAND1 
    FROM 
      [SrcSAPFile].[VolumeConfig] 
    WHERE 
      [NAME] IN (
        'DELV_TYPE_FOC', 'DELV_TYPE_DELV_QTY'
      )
  ) 
  AND VBAP.[PRODH] LIKE 'A1A1%' 
  AND VBAP.[NETPR] = '0.00' THEN 'Free' WHEN VBAK.[ZZDELI_CATE] = 'Secondary' 
  AND VBAP.ZZDELI_TYPE NOT IN (
    SELECT 
      OPERAND1 
    FROM 
      [SrcSAPFile].[VolumeConfig] 
    WHERE 
      [NAME] IN (
        'DELV_TYPE_FOC', 'DELV_TYPE_DELV_QTY'
      )
  ) 
  AND VBAP.[PRODH] LIKE 'A1A1%' 
  AND VBAP.[NETPR] <> '0.00' THEN 'Paid' WHEN VBAK.[ZZDELI_CATE] = '' 
  AND VBAP.[PRODH] LIKE 'A1S1U1%' THEN 'Paid' WHEN VBAK.[ZZDELI_CATE] = '' 
  AND VBAP.[PRODH] LIKE 'A1S1U2%' 
  AND VBAP.[NETPR] = '0.00' THEN 'Free' WHEN VBAK.[ZZDELI_CATE] = '' 
  AND VBAP.[PRODH] LIKE 'A1S1U2%' 
  AND VBAP.[NETPR] <> '0.00' THEN 'Paid' END [Free_Paid], 
  VBAP.[MVGR1] AS [Material Group 1], 
  VBAP.[MVGR2] AS [Material Group 2], 
  VBAP.[MVGR3] AS [Material Group 3], 
  VBAP.[MVGR4] AS [Material Group 4], 
  VBAP.[MVGR5] AS [Material Group 5], 
  VBAP.[MEINS] AS [Base Unit of Measure], 
  VBAP.[VRKME] AS [Sales Unit], 
  VBAP.[GEWEI] AS [Weight Unit], 
  VBAP.[ZZPROMO] AS [Promotion Bucket], 
  VBAP.[ZZTREV_DATE] AS [Revenue Recognition], 
  VBAP.[AUDAT] AS [Document Date], 
  VBAP.[LGORT] AS [Storage Location], 
  VBAP.[ZZTREAT_OPT] AS [Treatment Option], 
  VBAP.[ZZCOMP_IND] [COMPLIANCE INDICATOR], 
  VBAP.[MATNR] AS [Material Number] 
FROM 
  SrcSAP.VBAP VBAP WITH(NOLOCK) 
  JOIN SrcSAP.VBAK VBAK WITH(NOLOCK) ON CONVERT(BIGINT, VBAP.[VBELN])= CONVERT(BIGINT, VBAK.[VBELN]) 

  --Creating Indexes on VBELN,POSNR For better fetching 
  CREATE NONCLUSTERED INDEX VBAP_VBELN ON [DWSAP].[VBAPH](VBELN) 
  CREATE NONCLUSTERED INDEX VBAP_POSNR ON [DWSAP].[VBAPH](POSNR) 
  
  DECLARE @RowsInserted int = 0, 
  @RowsUpdated int = 0, 
  @IsFullLoad bit = 0 
SELECT 
  ScannerHistory.[LZBatchID], 
  ScannerHistory.[ADLSBatchID], 
  ScannerHistory.[ADLSTimestamp], 
  @BatchID [DWBatchID], 
  @LastSuccessfullDWTimestamp [DWTimeStamp], 
  [DOC_NUMBER] [Sales Document],
  [S_ORD_ITEM], 
  [FISCVARNT] [Fiscal Year Variant], 
  [CALQUARTER] [Cal.Year/Quarter], 
  [CALQUART1] [Quarter], 
  [CALWEEK] [Calender Year/Week], 
  [FISCYEAR] [Fiscal Year], 
  [FISCPER] [Fiscal Year/Period], 
  [FISCPER3] [Posting Period], 
  [/BIC/ZZSR_NO] [Equipment Serial Num], 
  [/BIC/INCOMID] [Initiator Company ID], 
  [/BIC/RREGION] [Reporting Region], 
  [/BIC/EVENTDATE] [Event Date], 
  [DOC_TYPE] [Document Type], 
  [DOC_CATEG] [Document Category], 
  [ITEM_CATEG] [Item Category], 
  [/BIC/DELI_TYPE] [Deliverable Type], 
  [/BIC/ZDELICATE] [Treatment Category], 
  [COMP_CODE] [Company Code], 
  Coalesce(
    [MATERIAL], VBAP.[Material Number]
  ) [Material], 
  [PROD_HIER] [Product Hierarchy], 
  [/BIC/CA_PRIMRY] [CA_PRIMARY], 
  [/BIC/CA_SECNDR] [CA_SECONDARY], 
  [/BIC/CA_NONCAS] [CA_NONCAS], 
  [/BIC/CA_OTHERS] [CA_OTHERS], 
  [/BIC/CA_UNKOWN] [CA_UNKNOWN], 
  [/BIC/ITRO_SCNR] [ITRO_SCNR], 
  [/BIC/ITRO_SERV] [ITRO_SERV], 
  [/BIC/ABSTK] [Overall Rejection St], 
  [REASON_REJ] [Reason For Rejection], 
  [REJECTN_ST] [Rejection Status], 
  [/BIC/REJCT_DAT] [Rejection Date], 
  [/BIC/REJCT_TIM] [Rejection Time], 
  Coalesce([DOC_DATE], VBAP.[Document Date]) [Document Date], 
  [CREATEDON] [Created On], 
  [/BIC/KNUMV] [Doc.Condition], 
  [/BIC/PAOBJNR] [Profit.Segment], 
  [COSTCENTER] [Cost Center], 
  [CO_AREA] [Controlling Area], 
  [PROFIT_CTR] [Profit Center], 
  [/BIC/ZCOSELMNT] [Cost Element(COPA) ], 
  Coalesce(
    [/BIC/ZCOMP_IND], VBAP.[Compliance Indicator]
  ) [Compliance INDICATOR], 
  [/BIC/ZAMR_DATE] [AMR DATE], 
  [/BIC/ZCCS_DATE] [CCS DATE], 
  [/BIC/ZCCA_DATE] [CCA DATE], 
  [/BIC/ZZEXT_PID] [External Patient ID], 
  [/BIC/ZZVIP_ORD] [Source System Order], 
  [/BIC/ZZPATIENT] [Patient ID], 
  [/BIC/ZSFDC_ORD] [SFDC Order ID], 
  [/BIC/ZZFRE_QTY] [FoC Quantity], 
  [/BIC/ZZTOT_QTY] [Deliverable Quantity], 
  [/BIC/TOT_QTY] [Deliverable Quantity for COPA], 
  [/BIC/TOTAL_QTY] [Total Quantity for COPA], 
  Coalesce([SALES_UNIT], VBAP.[Sales Unit]) [Sales Unit], 
  [BASE_UOM], 
  [TARGET_QU], 
  [DOC_CURRCY] [Document Currency], 
  [CML_CF_QTY], 
  [CML_CD_QTY], 
  [CML_OR_QTY] [Order Quantity], 
  [TARGET_QTY] [Target Quantity], 
  [WITHDRWQTY] [Withdraw Quantity], 
  [NET_PRICE] [Net Price], 
  [NET_VALUE] [Net Value], 
  [/BIC/AGE_TIER] [Age Tier], 
  [/BIC/ZCHATREPO] [Reporting Channel], 
  [/BIC/FREE_PAID] [Free/Paid], 
  [SOLD_TO] [Sold - to Party], 
  [CUST_GRP1] [Customer Group 1], 
  [CUST_GRP2] [Customer Group 2], 
  [CUST_GRP3] [Customer Group 3], 
  [CUST_GRP4] [Customer Group 4], 
  [CUST_GRP5] [Customer Group 5], 
  [SALES_GRP] [Sales Group], 
  [SALESORG] [Sales Organization], 
  [DISTR_CHAN] [Distribution Channel], 
  Coalesce(
    [STOR_LOC], VBAP.[Storage Location]
  ) [STORAGE LOCATION], 
  [PLANT] [Plant], 
  [MATL_GROUP] [Material Group], 
  [BILLTOPRTY] [Bill - to Party], 
  [SHIP_TO] [Ship - to Party], 
  [DIVISION] [Division], 
  [COUNTRY] [Country], 
  [/BIC/EXT_TXID] [External Treatment ID], 
  Coalesce(
    [/BIC/ZTREATOPT], VBAP.[Treatment Option]
  ) [Treatment OPTION], 
  [/BIC/ZZTREAT] [Treatment ID], 
  [/BIC/ZZ_STAGES] [Max No Of Stages], 
  [/BIC/TRMNTLOC] [Treatment Location], 
  [/BIC/TRMNTDOC] [Treatment Doctor], 
  [/BIC/ORDSTAGES] [Order Stages], 
  [/BIC/STAGBUCKT] [Stages Bucket], 
  Coalesce(
    [MATL_GRP_1], VBAP.[Material Group 1]
  ) [Material GROUP 1], 
  Coalesce(
    [MATL_GRP_2], VBAP.[Material Group 2]
  ) [Material GROUP 2], 
  Coalesce(
    [MATL_GRP_3], VBAP.[Material Group 3]
  ) [Material GROUP 3], 
  Coalesce(
    [MATL_GRP_4], VBAP.[Material Group 4]
  ) [Material GROUP 4], 
  Coalesce(
    [MATL_GRP_5], VBAP.[Material Group 5]
  ) [Material GROUP 5], 
  [/BIC/TERTRYMGR] [Territory Manager], 
  [/BIC/ALGNRETIL] [Align Retail], 
  [/BIC/FINCONTCT] [Financial Contact], 
  [/BIC/JR_DOCTOR] [Junior Doctor], 
  [/BIC/SUBSTUDNT] [Submitting Student], 
  [/BIC/EMP_RESP] [Employee Responsible], 
  [/BIC/ATNAM_UPR] [Characteristic - Upper], 
  [/BIC/ATNAM_LWR] [Characteristic - Lower], 
  [/BIC/ATWRT_UPR] [Charac.Value - Upper], 
  [/BIC/ATWRT_LWR] [Charac.Value - Lower], 
  [/BIC/ZCLINICAL], 
  [DELIV_NUMB], 
  [DELIV_ITEM], 
  [ACT_GI_DTE], 
  [ACT_DL_QTY], 
  [DLV_QTY], 
  [/BIC/SHPMNTCNT], 
  [/BIC/VOL_SEGMT], 
  [/BIC/VOL_COUNT], 
  [/BIC/VOL_QUANT], 
  [/BIC/SEGMENT], 
  [/BIC/VOLSSEGMT], 
  [/BIC/FILEYN], 
  [BILL_DATE], 
  [/BIC/IACTQTY], 
  [PAYER], 
  [VOLUMEUNIT], 
  [CREA_TIME], 
  [/BIC/ZALGNUSER] [ZALGNUSER], 
  [/BIC/ZFRE_QTY], 
  [/BIC/ZTOTALQT] [Total Quantity], 
  [/BIC/DELV_QTY], 
  Coalesce(
    [/BIC/PROMOBUC], VBAP.[Promotion Bucket]
  ) [Promotion Bucket], 
  [/BIC/ZDATEMIM] [Data of MIM], 
  [/BIC/ZEVENT] [Event Description], 
  'Volume' [Process Name], 
  CASE WHEN [PROD_HIER] like 'A1A1%' THEN 'CLEAR ALIGNER' WHEN [PROD_HIER] like 'A1S1%' THEN 'ITERO' ELSE NULL END AS [Business Segment], 
  VBAP.[BASe Unit of MeASure], 
  VBAP.[Weight Unit], 
  VBAP.[Revenue Recognition], 
  VBAP.[Free_Paid] INTO #temp_ScannerHistory
FROM 
  [SrcSAPFile].[ScannerHistory] ScannerHistory --23693
  LEFT JOIN [DWSAP].[VBAPH] VBAP ON TRY_CONVERT(BIGINT, [DOC_NUMBER])= VBAP.[VBELN] 
  AND TRY_CONVERT(BIGINT, [S_ORD_ITEM]) = VBAP.[POSNR] IF (
    EXISTS (
      SELECT 
        * 
      FROM 
        INFORMATION_SCHEMA.TABLES 
      WHERE 
        TABLE_SCHEMA = 'DWSAP' 
        AND TABLE_NAME = 'ScannerHistoryProcessed_Performance'
    )
  ) BEGIN TRUNCATE TABLE [DWSAP].[ScannerHistoryProcessed_Performance] INSERT INTO [DWSAP].[ScannerHistoryProcessed_Performance] 
SELECT 
  * 
FROM 
  #temp_ScannerHistory END ELSE BEGIN
SELECT 
  * INTO [DWSAP].[ScannerHistoryProcessed_Performance] 
FROM 
  #temp_ScannerHistory END
DROP 
  TABLE #temp_ScannerHistory IF OBJECT_ID('[DWSAP].[VBAPH]',
  'U'
) IS NOT NULL 
DROP 
  TABLE [DWSAP].[VBAPH] -- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
  -- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
SELECT 
  @RowsInserted - @RowsUpdated AS RowsInserted, 
  @RowsUpdated AS RowsUpdated;
WITH CTE AS (
  SELECT 
    ROW_NUMBER() OVER(
      PARTITION BY [Sales Document], 
      [Item], 
      [Fiscal Year Variant], 
      [Cal.Year/Quarter], 
      [Quarter], 
      [Calender Year/Week], 
      [Fiscal Year], 
      [Fiscal Year/Period], 
      [Posting Period], 
      [Equipment Serial Num], 
      [Initiator Company ID], 
      [Reporting Region], 
      [Event Date], 
      [Document Type], 
      [Document Category], 
      [Item Category], 
      [Deliverable Type], 
      [Treatment Category], 
      [Company Code], 
      [Material], 
      [Product Hierarchy], 
      [CA_PRIMARY], 
      [CA_SECONDARY], 
      [CA_NONCAS], 
      [CA_OTHERS], 
      [CA_UNKNOWN], 
      [ITRO_SCNR], 
      [ITRO_SERV], 
      [Overall Rejection St], 
      [Reason For Rejection], 
      [Rejection Status], 
      [Rejection Date], 
      [Rejection Time], 
      [Document Date], 
      [Created On], 
      [Doc.Condition], 
      [Profit.Segment], 
      [Cost Center], 
      [Controlling Area], 
      [Profit Center], 
      [Cost Element(COPA) ], 
      [Compliance Indicator], 
      [AMR DATE], 
      [CCS DATE], 
      [CCA DATE], 
      [External Patient ID], 
      [Source System Order], 
      [Patient ID], 
      [SFDC Order ID], 
      [FoC Quantity], 
      [Deliverable Quantity], 
      [Deliverable Quantity for COPA], 
      [Total Quantity for COPA], 
      [Sales Unit], 
      [BASE_UOM], 
      [TARGET_QU], 
      [Document Currency], 
      [CML_CF_QTY], 
      [CML_CD_QTY], 
      [Order Quantity], 
      [Target Quantity], 
      [Withdraw Quantity], 
      [Net Price], 
      [Net Value], 
      [Age Tier], 
      [Reporting Channel], 
      [Free/Paid], 
      [Sold - to Party], 
      [Customer Group 1], 
      [Customer Group 2], 
      [Customer Group 3], 
      [Customer Group 4], 
      [Customer Group 5], 
      [Sales Group], 
      [Sales Organization], 
      [Distribution Channel], 
      [Storage Location], 
      [Plant], 
      [Material Group], 
      [Bill - to Party], 
      [Ship - to Party], 
      [Division], 
      [Country], 
      [External Treatment ID], 
      [Treatment Option], 
      [Treatment ID], 
      [Max No Of Stages], 
      [Treatment Location], 
      [Treatment Doctor], 
      [Order Stages], 
      [Stages Bucket], 
      [Material Group 1], 
      [Material Group 2], 
      [Material Group 3], 
      [Material Group 4], 
      [Material Group 5], 
      [Territory Manager], 
      [Align Retail], 
      [Financial Contact], 
      [Junior Doctor], 
      [Submitting Student], 
      [Employee Responsible], 
      [Characteristic - Upper], 
      [Characteristic - Lower], 
      [Charac.Value - Upper], 
      [Charac.Value - Lower], 
      [/BIC/ZCLINICAL], 
      [DELIV_NUMB], 
      [DELIV_ITEM], 
      [ACT_GI_DTE], 
      [ACT_DL_QTY], 
      [DLV_QTY], 
      [/BIC/SHPMNTCNT], 
      [/BIC/VOL_SEGMT], 
      [/BIC/VOL_COUNT], 
      [/BIC/VOL_QUANT], 
      [/BIC/SEGMENT], 
      [/BIC/VOLSSEGMT], 
      [/BIC/FILEYN], 
      [BILL_DATE], 
      [/BIC/IACTQTY], 
      [PAYER], 
      [VOLUMEUNIT], 
      [CREA_TIME], 
      [ZALGNUSER], 
      [/BIC/ZFRE_QTY], 
      [Total Quantity], 
      [/BIC/DELV_QTY], 
      [Promotion Bucket], 
      [Data of MIM], 
      [Event Description], 
      [Process Name], 
      [Business Segment], 
      [BASe Unit of MeASure], 
      [Weight Unit], 
      [Revenue Recognition], 
      [Free_Paid] 
      ORDER BY 
        [Sales Document], 
        [Item], 
        [Fiscal Year Variant], 
        [Cal.Year/Quarter], 
        [Quarter], 
        [Calender Year/Week], 
        [Fiscal Year], 
        [Fiscal Year/Period], 
        [Posting Period], 
        [Equipment Serial Num], 
        [Initiator Company ID], 
        [Reporting Region], 
        [Event Date], 
        [Document Type], 
        [Document Category], 
        [Item Category], 
        [Deliverable Type], 
        [Treatment Category], 
        [Company Code], 
        [Material], 
        [Product Hierarchy], 
        [CA_PRIMARY], 
        [CA_SECONDARY], 
        [CA_NONCAS], 
        [CA_OTHERS], 
        [CA_UNKNOWN], 
        [ITRO_SCNR], 
        [ITRO_SERV], 
        [Overall Rejection St], 
        [Reason For Rejection], 
        [Rejection Status], 
        [Rejection Date], 
        [Rejection Time], 
        [Document Date], 
        [Created On], 
        [Doc.Condition], 
        [Profit.Segment], 
        [Cost Center], 
        [Controlling Area], 
        [Profit Center], 
        [Cost Element(COPA) ], 
        [Compliance Indicator], 
        [AMR DATE], 
        [CCS DATE], 
        [CCA DATE], 
        [External Patient ID], 
        [Source System Order], 
        [Patient ID], 
        [SFDC Order ID], 
        [FoC Quantity], 
        [Deliverable Quantity], 
        [Deliverable Quantity for COPA], 
        [Total Quantity for COPA], 
        [Sales Unit], 
        [BASE_UOM], 
        [TARGET_QU], 
        [Document Currency], 
        [CML_CF_QTY], 
        [CML_CD_QTY], 
        [Order Quantity], 
        [Target Quantity], 
        [Withdraw Quantity], 
        [Net Price], 
        [Net Value], 
        [Age Tier], 
        [Reporting Channel], 
        [Free/Paid], 
        [Sold - to Party], 
        [Customer Group 1], 
        [Customer Group 2], 
        [Customer Group 3], 
        [Customer Group 4], 
        [Customer Group 5], 
        [Sales Group], 
        [Sales Organization], 
        [Distribution Channel], 
        [Storage Location], 
        [Plant], 
        [Material Group], 
        [Bill - to Party], 
        [Ship - to Party], 
        [Division], 
        [Country], 
        [External Treatment ID], 
        [Treatment Option], 
        [Treatment ID], 
        [Max No Of Stages], 
        [Treatment Location], 
        [Treatment Doctor], 
        [Order Stages], 
        [Stages Bucket], 
        [Material Group 1], 
        [Material Group 2], 
        [Material Group 3], 
        [Material Group 4], 
        [Material Group 5], 
        [Territory Manager], 
        [Align Retail], 
        [Financial Contact], 
        [Junior Doctor], 
        [Submitting Student], 
        [Employee Responsible], 
        [Characteristic - Upper], 
        [Characteristic - Lower], 
        [Charac.Value - Upper], 
        [Charac.Value - Lower], 
        [/BIC/ZCLINICAL], 
        [DELIV_NUMB], 
        [DELIV_ITEM], 
        [ACT_GI_DTE], 
        [ACT_DL_QTY], 
        [DLV_QTY], 
        [/BIC/SHPMNTCNT], 
        [/BIC/VOL_SEGMT], 
        [/BIC/VOL_COUNT], 
        [/BIC/VOL_QUANT], 
        [/BIC/SEGMENT], 
        [/BIC/VOLSSEGMT], 
        [/BIC/FILEYN], 
        [BILL_DATE], 
        [/BIC/IACTQTY], 
        [PAYER], 
        [VOLUMEUNIT], 
        [CREA_TIME], 
        [ZALGNUSER], 
        [/BIC/ZFRE_QTY], 
        [Total Quantity], 
        [/BIC/DELV_QTY], 
        [Promotion Bucket], 
        [Data of MIM], 
        [Event Description], 
        [Process Name], 
        [Business Segment], 
        [BASe Unit of MeASure], 
        [Weight Unit], 
        [Revenue Recognition], 
        [Free_Paid]
    ) AS [ROW], 
    [Sales Document], 
    [Item], 
    [Fiscal Year Variant], 
    [Cal.Year/Quarter], 
    [Quarter], 
    [Calender Year/Week], 
    [Fiscal Year], 
    [Fiscal Year/Period], 
    [Posting Period], 
    [Equipment Serial Num], 
    [Initiator Company ID], 
    [Reporting Region], 
    [Event Date], 
    [Document Type], 
    [Document Category], 
    [Item Category], 
    [Deliverable Type], 
    [Treatment Category], 
    [Company Code], 
    [Material], 
    [Product Hierarchy], 
    [CA_PRIMARY], 
    [CA_SECONDARY], 
    [CA_NONCAS], 
    [CA_OTHERS], 
    [CA_UNKNOWN], 
    [ITRO_SCNR], 
    [ITRO_SERV], 
    [Overall Rejection St], 
    [Reason For Rejection], 
    [Rejection Status], 
    [Rejection Date], 
    [Rejection Time], 
    [Document Date], 
    [Created On], 
    [Doc.Condition], 
    [Profit.Segment], 
    [Cost Center], 
    [Controlling Area], 
    [Profit Center], 
    [Cost Element(COPA) ], 
    [Compliance Indicator], 
    [AMR DATE], 
    [CCS DATE], 
    [CCA DATE], 
    [External Patient ID], 
    [Source System Order], 
    [Patient ID], 
    [SFDC Order ID], 
    [FoC Quantity], 
    [Deliverable Quantity], 
    [Deliverable Quantity for COPA], 
    [Total Quantity for COPA], 
    [Sales Unit], 
    [BASE_UOM], 
    [TARGET_QU], 
    [Document Currency], 
    [CML_CF_QTY], 
    [CML_CD_QTY], 
    [Order Quantity], 
    [Target Quantity], 
    [Withdraw Quantity], 
    [Net Price], 
    [Net Value], 
    [Age Tier], 
    [Reporting Channel], 
    [Free/Paid], 
    [Sold - to Party], 
    [Customer Group 1], 
    [Customer Group 2], 
    [Customer Group 3], 
    [Customer Group 4], 
    [Customer Group 5], 
    [Sales Group], 
    [Sales Organization], 
    [Distribution Channel], 
    [Storage Location], 
    [Plant], 
    [Material Group], 
    [Bill - to Party], 
    [Ship - to Party], 
    [Division], 
    [Country], 
    [External Treatment ID], 
    [Treatment Option], 
    [Treatment ID], 
    [Max No Of Stages], 
    [Treatment Location], 
    [Treatment Doctor], 
    [Order Stages], 
    [Stages Bucket], 
    [Material Group 1], 
    [Material Group 2], 
    [Material Group 3], 
    [Material Group 4], 
    [Material Group 5], 
    [Territory Manager], 
    [Align Retail], 
    [Financial Contact], 
    [Junior Doctor], 
    [Submitting Student], 
    [Employee Responsible], 
    [Characteristic - Upper], 
    [Characteristic - Lower], 
    [Charac.Value - Upper], 
    [Charac.Value - Lower], 
    [/BIC/ZCLINICAL], 
    [DELIV_NUMB], 
    [DELIV_ITEM], 
    [ACT_GI_DTE], 
    [ACT_DL_QTY], 
    [DLV_QTY], 
    [/BIC/SHPMNTCNT], 
    [/BIC/VOL_SEGMT], 
    [/BIC/VOL_COUNT], 
    [/BIC/VOL_QUANT], 
    [/BIC/SEGMENT], 
    [/BIC/VOLSSEGMT], 
    [/BIC/FILEYN], 
    [BILL_DATE], 
    [/BIC/IACTQTY], 
    [PAYER], 
    [VOLUMEUNIT], 
    [CREA_TIME], 
    [ZALGNUSER], 
    [/BIC/ZFRE_QTY], 
    [Total Quantity], 
    [/BIC/DELV_QTY], 
    [Promotion Bucket], 
    [Data of MIM], 
    [Event Description], 
    [Process Name], 
    [Business Segment], 
    [BASe Unit of MeASure], 
    [Weight Unit], 
    [Revenue Recognition], 
    [Free_Paid] 
  FROM 
    [DWSAP].[ScannerHistoryProcessed_Performance]
) 
DELETE FROM 
  CTE 
WHERE 
  [ROW] > 1 END
