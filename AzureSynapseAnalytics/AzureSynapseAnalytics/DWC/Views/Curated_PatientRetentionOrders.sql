CREATE VIEW DWC.Curated_PatientRetentionOrders AS
SELECT ho.SKOrder
, pro.[OrderId] as IDSOrderNumber
, pro.[SubscriptionId]
, pro.[SAPOrderNumber]
, pro.[OrderType]
, pro.[SubmissionType]
, pro.[SubmittedBy]
, pro.[SubmissionDate]
, pro.[AMRDate]
, pro.[CCADate]
, pro.[CancellationDate]
, pro.[ShipmentDate]
, pro.[ShipmentTrackingNumber]
, pro.[ShippingProvider]
, pro.[DateCreated]
, pro.[DateUpdated]
, sfo.SecRegion
FROM [SrcSAGA].[PatientRetentionOrder] pro 
INNER JOIN dw.huborder  ho ON pro.SAPOrderNumber = ho.KeyOrder
INNER JOIN dw.DimOrderSFDC sfo ON sfo.SKOrder = ho.SKOrder
INNER JOIN dwglobal.GeographyRegion d ON d.RegionGroup = sfo.SecRegion and d.dataset='DWC'
where pro.SAPOrderNumber is not null and pro.[SubscriptionId] is not null;