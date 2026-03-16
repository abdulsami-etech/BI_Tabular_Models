CREATE VIEW [TABIRIS].[DimTracker]
AS SELECT
	dt.[SKAsset]															as [SKAsset],
	dt.[TrackerName]														as [Tracker Name],
	dt.[TrackingMessage]													as [Tracking Message],
	dt.[TrackingNumber]														as [Tracking Number],
	dt.[TrackingStatus]														as [Tracking Status],
	dt.[ScheduledDeliveryDeliveredDate]										as [Scheduled Delivery/Delivered Date],
	dt.[Carrier]															as [Carrier],
	dt.[ShippedDate]														as [Shipped Date],
	dt.OpportunityId														as [OpportunityId],
	dt.ProcessingStatus														as [ProcessingStatus],
	dt.KeyTicket														as [KeyTicket]
FROM [DWIRIS].[HubTracker] ht
inner join [DWIRIS].[DimTracker] dt
	on ht.[SKTracker] = dt.[SKTracker]