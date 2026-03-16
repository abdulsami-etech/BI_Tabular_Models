CREATE VIEW [TABSAP].[DimSales Document Additional Attributes] AS SELECT 
  [ADLSTimestamp],
  [PartitionColumn], 
  [Sales Document], 
  --[Age Tier], 
  [Order Stages], 
  [Stage Bucket], 
  [SoldTo], 
  [TreatmentCategory], 
  --[Professional Category], 
  [Advantage Program Name], 
  [MAF], 
  [Sales Group], 
  [Bill-to party], 
  [Country of ship-to party], 
  --[IsDSOOrder], 
  [AgeTierRange], 
  [AgeTierDetail], 
  [AgeSegment], 
  [AgeCategory] 
FROM 
  [DWSAP].[DimSalesDocumentHeader_Performance] 
UNION ALL 
SELECT 
  [ADLSTimestamp], 
  Max(
    CONCAT(
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
  --[Age Tier], 
  [Order Stages], 
  [Stages Bucket] AS [Stage Bucket], 
  [Sold-to Party] AS [SoldTo], 
  [Treatment Category] AS [TreatmentCategory], 
  --NULL AS [Professional Category], 
  NULL AS [Advantage Program Name], 
  NULL AS [MAF], 
  [Sales Group], 
  [Bill-to party], 
  NULL AS [Country of ship-to party], 
  --NULL AS [IsDSOOrder], 
  NULL AS [AgeTierRange], 
  NULL AS [AgeTierDetail], 
  NULL AS [AgeSegment], 
  NULL AS [AgeCategory]
FROM 
  [DWSAP].[ScannerHistoryProcessed_Performance] 
WHERE 
  [Sales Document] NOT IN(
    SELECT 
      [Sales Document] 
    FROM 
      [DWSAP].[DimSalesDocumentHeader_Performance]
  ) 
Group By 
  [ADLSTimestamp], 
  [Sales Document], 
  --[Age Tier], 
  [Order Stages], 
  [Stages Bucket], 
  [Sold-to Party], 
  [Treatment Category], 
  [Sales Group], 
  [Bill-to party], 
  Year(
    Cast([Document Date] AS date)
  )