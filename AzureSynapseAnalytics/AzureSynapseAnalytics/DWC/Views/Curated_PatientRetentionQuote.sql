CREATE VIEW DWC.Curated_PatientRetentionQuote AS
SELECT prq.QuoteId
, c.SKContact
, prq.ClinId
, prq.[Status]
, prq.RejectReason
, prq.QuoteCreatedDate
, prq.QuoteUpdatedDate
, prq.ValidFrom
, prq.ValidTo
, c.SecRegion
FROM SrcSAGA.PatientRetentionQuote prq 
INNER JOIN dw.dimContact c ON prq.ClinId = c.ClinId
INNER JOIN dwglobal.GeographyRegion d ON d.RegionGroup = c.SecRegion and d.dataset='DWC';