CREATE VIEW DWC.Curated_PatientRetentionPackage AS 
SELECT prp.[PackageId]
, prp.[QuoteId]
, prp.[NumberOfSets]
, prp.[MonthlyPaymentAmount]
, prp.[AnnualPaymentAmount]
, prp.[DownPaymentAmount]
, prp.[IsRecommended]
, prp.[PackageType]
, prp.[DeliveryFrequency]
, prp.[PackageCreatedDate]
, prp.[PackageUpdatedDate]
, prp.[ValidFrom]
, prp.[ValidTo]
, c.secRegion
FROM Srcsaga.PatientRetentionPackage prp  
INNER JOIN SrcSAGA.PatientRetentionQuote prq  ON prp.QuoteId = prq.QuoteId
INNER JOIN dw.dimContact c ON prq.ClinId = c.ClinId
INNER JOIN dwglobal.GeographyRegion d ON d.RegionGroup = c.SecRegion and d.dataset='DWC';