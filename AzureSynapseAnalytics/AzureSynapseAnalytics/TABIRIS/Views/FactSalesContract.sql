CREATE VIEW [TABIRIS].[FactSalesContract]
AS SELECT
	[SKSalesContract]															as [SK SalesContract],
	[SKAsset]																	as [SK Asset],
    [SKAccount]																	as [SK Account],
    [SKTeam]																	as [SK Team],
    [SKUser]																	as [SK User],

	convert(date, convert(varchar(8), AuditCompletedDateKey), 112)				as [KeyDate AuditCompleted],
	convert(date, convert(varchar(8), CaseManufacturingDateKey), 112)			as [KeyDate CaseManufacturing],
	convert(date, convert(varchar(8), ContractSignedDateKey), 112)				as [KeyDate ContractSigned],
	convert(date, convert(varchar(8), FirstContactEmailDateKey), 112)			as [KeyDate FirstContactEmail],
	convert(date, convert(varchar(8), FourthContactDateKey), 112)				as [KeyDate FourthContact],
	convert(date, convert(varchar(8), MiMDateKey), 112)							as [KeyDate MiM],
	convert(date, convert(varchar(8), NotificationSenttoTrainerDateKey), 112)	as [KeyDate NotificationSenttoTrainer],
	convert(date, convert(varchar(8), ThirdContactDateKey), 112)				as [KeyDate ThirdContact],
	convert(date, convert(varchar(8), InvoiceDateKey), 112)						as [KeyDate Invoice],
	convert(date, convert(varchar(8), DimLeasingStatusDateKey), 112)			as [KeyDate LeasingStatus],
	--convert(date, convert(varchar(8), EffectiveShipmentDateKey), 112)			as [KeyDate EffectiveShipment],
	convert(date, convert(varchar(8), FinalReceivedDateKey), 112)				as [KeyDate FinalReceived],
	convert(date, convert(varchar(8), iTeroScannerRevRecDateKey), 112)			as [KeyDate iTeroScannerRevRec],
	convert(date, convert(varchar(8), OnboardingDateKey), 112)					as [KeyDate Onboarding],
	convert(date, convert(varchar(8), ProcessingCompletedDateKey), 112)			as [KeyDate ProcessingCompleted],
	convert(date, convert(varchar(8), ShippingDateKey), 112)					as [KeyDate Shipping],
	convert(date, convert(varchar(8), SpareDeliveryDateKey), 112)				as [KeyDate SpareDelivery],
	convert(date, convert(varchar(8), VCTTrainingDateKey), 112)					as [KeyDate VCTTraining],
	convert(date, convert(varchar(8), DeliveredDateKey), 112)					as [KeyDate Delivered],
	[AuditTimeElapsed]															as [Audit Time Elapsed],
	[ProcessingTimeElapsed]														as [Processing Time Elapsed],
	[ShipmentTimeElapsed]														as [Shipment Time Elapsed],
	1																			as [Contracts Count]

--Business Hours Age (Hours)
--Count of Contract Signed
--Scanners Shipped
--Count of Contract Loaded
--Sign to Ship
--Onboarding Duration
--Sign to Approved
--Pending Information Duration
--Sign to Delivery
--Days ship to pick up
--Days to process

FROM [DWIRIS].[DimSalesContract];