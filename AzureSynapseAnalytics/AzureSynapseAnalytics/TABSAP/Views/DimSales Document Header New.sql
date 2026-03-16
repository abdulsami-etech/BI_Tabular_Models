CREATE VIEW [TABSAP].[DimSales Document Header New] AS 
--BI-12996 New View
SELECT 
  [ADLSTimestamp], 
  [PartitionColumn], 
  [Sales Document], 
  [TreatingDoctor], 
  [ShipTo], 
  [TreatmentLocation], 
  [Is IO Scan], 
  [Document Date], 
  [Align Retail], 
  [Employee Responsible], 
  [Financial Contact], 
  [Junior Doctor], 
  [Submitting Student], 
  [Territory Manager], 
  [Bill-to party text], 
  [ShipTo Text], 
  [SoldTo Text], 
  [ProductType], 
  [AMR Date COPA] 
FROM 
  [DWSAP].[DimSalesDocumentHeaderAttr_Performance] 
UNION ALL 
SELECT 
  [ADLSTimestamp], 
  MAX(
    CONCAT (
      YEAR (
        Coalesce([Document Date], [ACT_GI_DTE])
      ), 
      '-', 
      MONTH(
        Coalesce([Document Date], [ACT_GI_DTE])
      )
    )
  ) AS [PartitionColumn], 
  [Sales Document], 
  [Treatment Doctor] AS [TreatingDoctor], 
  [Ship-to Party] AS [ShipTo], 
  [Treatment Location] AS [TreatmentLocation], 
  NULL AS [Is IO Scan], 
  MAX(
    Coalesce([Document Date], [ACT_GI_DTE])
  ) AS [Document Date], 
  [Align Retail], 
  [Employee Responsible], 
  [Financial Contact], 
  [Junior Doctor], 
  [Submitting Student], 
  [Territory Manager], 
  NULL AS [Bill-to party text], 
  NULL AS [ShipTo Text], 
  NULL AS [SoldTo Text], 
  NULL AS [ProductType], 
  NULL AS [AMR Date COPA] 
FROM 
  [DWSAP].[ScannerHistoryProcessed_Performance] 
WHERE 
  [Sales Document] NOT IN(
    SELECT 
      DISTINCT [Sales Document] 
    FROM 
      [DWSAP].[DimSalesDocumentHeaderAttr_Performance]
  ) 
GROUP BY 
  [ADLSTimestamp], 
  [Sales Document], 
  [Treatment Doctor], 
  [Ship-to Party], 
  [Treatment Location], 
  [Align Retail], 
  [Employee Responsible], 
  [Financial Contact], 
  [Junior Doctor], 
  [Submitting Student], 
  [Territory Manager];
