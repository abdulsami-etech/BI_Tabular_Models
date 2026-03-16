CREATE VIEW DWC.Curated_SAGASubscription AS
SELECT s.[ContractNumber]
, s.[LastAction]
, c.SKContact 
, s.[ClinId]
, s.[SoldTo]
, a.SKAccount as SKSoldTo
, s.[ContractStartDate]
, s.[ContractEndDate]
, s.[LastRequestDate]
, s.[ProgramCode], s.[PackageCode], s.[PackageName]
, s.[PricePerAligner]
, s.[AlignerPerMonth]
, s.[ContractTermLength]
, s.[Allowance]
, s.[CancellationDate]
, s.[ValidFrom]
, s.[ValidTo]
, a.SecRegion
from Srcsaga.Subscription  s 
INNER JOIN DW.DimAccount a ON s.SoldTo = a.AccountNumber
INNER JOIN DW.DimContact c ON s.ClinId = c.ClinId
INNER JOIN dwglobal.GeographyRegion d ON d.RegionGroup = c.SecRegion and d.dataset='DWC';