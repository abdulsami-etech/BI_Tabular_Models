CREATE VIEW [TABSAP].[OperationsMaterialDocumentItem] AS 
SELECT 
  [AccountingDocument], 
  [SalesDocument], 
  [SalesOrderItem], 
  [Posting Date], 
  [ProfitCenter] [Profit Center], 
  [Material Number] AS [Material], 
  [MaterialDocument] as [Material Document], 
  [Material Plant], 
  [Movement Type] AS [Goods Movement Type], 
  [Local Currency], 
  [Amount in Local Currency], 
  [Local Currency2], 
  [Amount in Local Currency2] AS [Total MLO Cost], 
  [DebitCreditCode], 
  [YearMonth], 
  Concat(
    [SalesDocument], '/', [Material Number]
  ) as [JoiningKey] 
FROM 
  [DWSAP].[OperationsMaterialDocumentItem] WITH(NOLOCK) 
WHERE 
  [SalesDocument] IS NOT NULL 
  AND [SalesDocument] <> 0
