CREATE VIEW DWC.Curated_PatientRetentionSubscription AS
SELECT prs.SubscriptionId
, prs.PackageId
, c.SKContact 
, prs.ClinId
, prs.PaymentFrequency
, prs.Status
, prs.StartDate
, prs.EndDate
, prs.CancelledDate
, prs.RenewalDate
, prs.ExternalSubscriptionReference
, prs.SubscriptionDateCreated
, prs.SubscriptionDateUpdated
, prs.PaymentFlag
, prs.ValidFrom
, prs.ValidTo
, c.SecRegion
FROM SrcSaga.PatientRetentionSubscription prs 
INNER JOIN dw.dimcontact c ON prs.ClinId = c.ClinId
INNER JOIN dwglobal.GeographyRegion d ON d.RegionGroup = c.SecRegion and d.dataset='DWC';