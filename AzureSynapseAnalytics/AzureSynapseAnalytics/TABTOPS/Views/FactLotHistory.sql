CREATE VIEW [TABTOPS].[FactLotHistory]
AS select	
		DgnTobjHistoryKey as LotHistoryKey
	,	DgnCompleteDateTime as CaseCompleteDateTime
	,	DgnStartDateTime as CaseStartDateTime
	,	DgnLotKey as LotKey
	,	DgnLotName as LotName
	,	DgnWorkOrderKey as WorkOrderKey
	,	DgnWorkOrderNumber as WorkOrderNumber
	,   DgnProductionTeam as ProductionTeam
	,	IsDuplicatedCompletion
	,	SKCompleteComment 
    ,   [SKStartDate]
    ,   [SKStartTime]
	,	SKCompleteDateUTC
	,	SKCompleteTimeUTC
	,	SKCompleteDate
	,	SKCompleteTime
	,	SKCompleteReason
	,   SKTeamRegion
	,	SKCompleteUserName
	,	SKCompletionPass
	,	SKDoctor
	,	SKOperation
	,	SKPart
	,	SKRoute
	,	SKRouteStep
	,	SKStartUserName
	,	CompleteCount
	,	ClinCheckStatus
	,   PostClinCheckFail
	,	CycleTimeMinutes 
	,   NewTreatmentFlow
from DWTOPS.FactLotHistory;