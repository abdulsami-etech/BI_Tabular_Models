CREATE VIEW DWC.FactPipeline AS
SELECT SAPOrderNumber
		,	DateKey
		,	StatusDate
		,	SKOrderStatus
		,	SKContact
		,	SKOrder
		,	SecRegion
		,	SKAccountSoldTo
		,	TreatmentOption
		,	DeliverableType
		,	ProfitCenter
		,	CCAAAging
FROM DW.FactPipeline fp
INNER JOIN dwglobal.GeographyRegion d ON d.RegionGroup = fp.SecRegion AND d.dataset='DWC';	