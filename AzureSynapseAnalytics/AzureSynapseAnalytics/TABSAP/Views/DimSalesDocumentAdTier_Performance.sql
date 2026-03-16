CREATE VIEW [TABSAP].[DimSalesDocumentAdTier_Performance] AS 
SELECT
[PartitionColumn],
[Sales Document],
[Advantage Tier],
[Age Tier],
[Professional Category],
[IsDSOOrder]
FROM
[DWSAP].[DimSalesDocumentAdTier_Performance]