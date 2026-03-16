CREATE VIEW [TABSAP].[FactCOPARevenue_Performance] AS
--BI-12996 New View 
SELECT 
  BUKRS AS [Company Code], 
  t.CURTP AS [Currency Type], 
  t.[REC_WAERS] AS [Currency Key], 
  LTEXT AS [Currency Key Text], 
  t.PRCTR AS [Profit Center] --,t.MATKL AS  [Material Number]
  --,vbap.PRODH AS [Product Hierarchy]
  , 
  t.PRODH AS [Product Hierarchy], 
  VERSI AS [Version], 
  KAUFN AS [Sales Order], 
  KSTAR AS [Cost Element], 
  KOKRS AS [Controlling Area], 
  vbapWERKS AS [Plant], 
  BUDAT AS [Posting Date], 
  COPA_KOSTL AS [Cost center] --,t.SPART AS [Division]
  , 
  VKORG AS [Sales Organisation] --,WW025 AS [Deliverable Quantity]
  --,WWA01 AS [Deliv. Qty]
  --,WWA02 AS [FoC Qty]
  --,WW028 AS [Total Qty. for COPA],
  , 
  PSTYV AS [Item Category], 
  ValueField AS [Value Fields], 
  [BUSSEGMNT] AS [Business Segment], 
  ColumnValue [COPA Revenue], 
  CONCAT(KOKRS, ',', KSTAR) AS COST_ELMNT_KEY, 
  CONCAT(BUKRS, ',', KSTAR) AS GL_ACCNT_KEY, 
  CONCAT(t.SPART, ',', t.SPRAS) AS DIVISION_KEY, 
  CONCAT(t.PRCTR, ',', KOKRS) AS PROFIT_CENTER_KEY, 
  t.BELNR AS [Document number], 
  --t.POSNR AS [Line Item of CO Document],
  t.RPOSN AS [Reference item], 
  t.KDPOS AS [Sales Ord. Item], 
  --t.AUART AS [Sales Doc. Type],
  t.VRGAR AS [Record Type], 
  t.POSNR AS [Item Number], 
  t.PLIKZ AS [Plan/Actual Indicator], 
  --t.PAOBJNR AS [Profitability Segment],
  t.STO_POSNR AS [Canceled item], 
  t.RBELN AS [Ref.doc.number], 
  vbapZZDELI_TYPE AS [Deliverable Type], 
  PERIO AS [Period/Year], 
  t.WW015 AS [Reporting Channel], 
  CONCAT(KAUFN, '/', KDPOS) AS [Sales Order Key] 
  /*Other COPA Attributes*/
  --,[COPA_AWTYP] [Reference Procedure]
  --,[COPA_AWORG] [Reference Organizational Units]
  --,[COPA_BWZPT] [CO-PA Point of valuation]
  --,[COPA_AWSYS] [Logical system of source document]
  --,[HRKFT] [Origin Group AS Subdivision of Cost Element]
  --,[RKESTATU] [Update Status]
  , 
  [HZDAT] [Created Date] --,[TIMESTMP] [UTC Timestamp]
  --,[USNAM] [Created By]
  , 
  [WW023] [No. of Stages], 
  [PRZNR] [Business Process], 
  [WW027] [AMR Date for COPA], 
  [LAND1] [Country Key], 
  [WWFT6] [Future 6], 
  [WWFT7] [Future 7], 
  [WWFT8] [Future 8], 
  [WWFT9] [Future 9], 
  [WWFT1] [Incentive Code] --,b.[Name] [Incentive Code Description] 
  , 
  IncentiveName [Incentive Code Description], 
  [WWICI] [Intercompany Ind], 
  [AUGRU] [Order Reason] --,[PLTYP] [Price List Type]
  , 
  t.[ABGRU] [Rejection Reason] --,[WWFT2] [Revenue Group]
  , 
  [WW010] [Revenue Type], 
  [VRTNR] [Sales Employee], 
  [STO_BELNR] [Canceled doc.], 
  [WWSIZ] [Future 10], 
  [ZPROCESS] [Process Name], 
  '9999' [Cust. Lifetime], 
  '10' [Value Type], 
  [PASUBNR] [Profitability Sub-segment (CO-PA)], 
  [DDTEXT] AS [Currency Type Text], 
  --PERIO AS [PartitionColumn],
  Concat(
    Year(
      Cast(BUDAT AS date)
    ), 
    '-', 
    Month(
      Cast(BUDAT AS date)
    )
  ) AS [PartitionColumn], 
  'ACTUALS' AS [Scenario Name] --,[PAPAOBJNR] [Partner Profitability Segment Number (CO-PA)]
  --,[PAPASUBNR] [Partner Profitability Sub-segment changes (CO-PA)]
  , 
  [vbapMATNR] AS [Material Number], 
  MATKL AS [Material Group], 
  [FreePaid] AS [FreePaid], 
  [VBAPZZPROMO] AS [Promotion Bucket], 
  [VBAPAUDAT] AS [Document Date], 
  [VBAPKWMENG] AS [Order quantity], 
  [VBAPZZTOTAL_QTY] AS [Total Quantity], 
  --[VBAPVBELN] AS [Sales Document],
  [Compliance Indicator] AS [Compliance Indicator], 
  [vbapMVGR1] AS [Material Group 1], 
  [vbapMVGR2] AS [Material Group 2], 
  [vbapMVGR3] AS [Material Group 3], 
  [vbapMVGR4] AS [Material Group 4], 
  [vbapMVGR5] AS [Material Group 5], 
  [vbapMEINS] AS [Base Unit of Measure], 
  [VbapVRKME] AS [Sales Unit], 
  [vbapVOLEH] AS [Volume Unit], 
  [vbapGEWEI] AS [Weight Unit], 
  [vbapZZTREV_DATE] AS [Revenue Recognition], 
  [vbapLGORT] AS [Storage Location], 
  [VbapZZTREAT_OPT] AS [Treatment Option], 
  [vbapPSTYV] AS [Item category Sales] --[VbapZZDELI_TYPE] AS [[Deliverable Type]
FROM 
  DWSAP.FactCOPATranspose_Performance t 
WHERE 
  BUDAT > '20160630' 
  and ZPROCESS = 'Revenue'
