CREATE VIEW [TABTOPS].[FactLotCurrent]
AS select	DgnCreationDateTime as LotCreationDateTime
	,	DgnCompleteDateTime as LotCompleteDateTime
	,	DgnFinishedDateTIme as FinishedDateTIme
	,	DgnLotKey as LotKey
	,	DgnLotName as LotName
	,	DgnPriority as LotPriority
	,	DgnPromisedDateTime as LotPromisedDateTime
	,	DgnStatus as LotStatus
	,	DgnWorkOrderKey as WorkOrderKey
	,	DgnWorkOrderNumber as WorkOrderNumber
	,   DgnQCPassFail as QCPassFail
	,	SKCompleteDate
	,	SKCompleteReason
	,	SKCompleteTime
	,	SKCreationDate
	,	SKCreationTime
	,	SKDoctor
	,	SKTeamRegion
	,	SKOperation
	,	SKPart
	,	SKPlantActual
	,	SKPlantOriginal
	,   SKPlantPrevious
	,	SKRoute
	,	SKRouteStep
	,	LotAgingHours
	,	LotAgingDays
from DWTOPS.FactLotCurrent;