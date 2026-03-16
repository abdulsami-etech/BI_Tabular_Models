CREATE VIEW [TABSAP].[FactCOPARevenue] AS SELECT
BUKRS as [Company Code]
,t.CURTP as [Currency Type]
,t.[REC_WAERS] as [Currency Key]
,LTEXT as [Currency Key Text]
,t.PRCTR as [Profit Center]
--,t.MATKL as  [Material Number]
--,vbap.PRODH as [Product Hierarchy]
,t.PRODH as [Product Hierarchy]
,VERSI as [Version]
,KAUFN as [Sales Order]
,KSTAR as [Cost Element]
,KOKRS as [Controlling Area]
,vbapWERKS as [Plant]
,BUDAT as [Posting Date]
,COPA_KOSTL as [Cost center]
--,t.SPART as [Division]
,VKORG as [Sales Organisation]
--,WW025 as [Deliverable Quantity]
--,WWA01 as [Deliv. Qty]
--,WWA02 as [FoC Qty]
--,WW028 as [Total Qty. for COPA],
,PSTYV as [Item Category],
ValueField as [Value Fields],
[BUSSEGMNT] as [Business Segment],
 ColumnValue [COPA Revenue],
CONCAT(KOKRS,',',KSTAR) AS COST_ELMNT_KEY,CONCAT(BUKRS,',',KSTAR) AS GL_ACCNT_KEY,
CONCAT(t.SPART,',',t.SPRAS) AS DIVISION_KEY,CONCAT(t.PRCTR,',',KOKRS) AS PROFIT_CENTER_KEY,
t.BELNR as [Document number],
--t.POSNR as [Line Item of CO Document],
t.RPOSN as [Reference item],
t.KDPOS as [Sales Ord. Item],
--t.AUART as [Sales Doc. Type],
t.VRGAR as [Record Type],
t.POSNR as [Item Number],
t.PLIKZ as [Plan/Actual Indicator],
--t.PAOBJNR as [Profitability Segment],
t.STO_POSNR as [Canceled item],
t.RBELN as [Ref.doc.number],
vbapZZDELI_TYPE as  [Deliverable Type],
PERIO as [Period/Year],
t.WW015 as [Reporting Channel],
CONCAT(KAUFN,'/',KDPOS) as [Sales Order Key]
/*Other COPA Attributes*/
--,[COPA_AWTYP] [Reference Procedure]
--,[COPA_AWORG] [Reference Organizational Units]
--,[COPA_BWZPT] [CO-PA Point of valuation]
--,[COPA_AWSYS] [Logical system of source document]
--,[HRKFT] [Origin Group as Subdivision of Cost Element]
--,[RKESTATU] [Update Status]
,[HZDAT] [Created Date]
--,[TIMESTMP] [UTC Timestamp]
--,[USNAM] [Created By]
,[WW023] [No. of Stages]
,[PRZNR] [Business Process]
,[WW027] [AMR Date for COPA]
,[LAND1] [Country Key]
,[WWFT6] [Future 6]
,[WWFT7] [Future 7]
,[WWFT8] [Future 8]
,[WWFT9] [Future 9]
    ,[WWFT1] [Incentive Code]
    --,b.[Name] [Incentive Code Description] 
    ,IncentiveName [Incentive Code Description]
,[WWICI] [Intercompany Ind]
,[AUGRU] [Order Reason]
--,[PLTYP] [Price List Type]
,t.[ABGRU] [Rejection Reason]
--,[WWFT2] [Revenue Group]
,[WW010] [Revenue Type]
,[VRTNR] [Sales Employee]
,[STO_BELNR] [Canceled doc.]
,[WWSIZ] [Future 10]
,[ZPROCESS] [Process Name]
,'9999' [Cust. Lifetime]
,'10' [Value Type]
,[PASUBNR] [Profitability Sub-segment (CO-PA)]
,[DDTEXT] as [Currency Type Text],
--PERIO as [PartitionColumn],
Concat(Year(Cast(BUDAT as date)),'-',Month(Cast(BUDAT as date))) as [PartitionColumn]
,'ACTUALS' AS [Scenario Name]
--,[PAPAOBJNR] [Partner Profitability Segment Number (CO-PA)]
--,[PAPASUBNR] [Partner Profitability Sub-segment changes (CO-PA)]

 

FROM [DWSAP].[FactCOPATranspose] t
WHERE  BUDAT > '20160630' and ZPROCESS = 'Revenue';