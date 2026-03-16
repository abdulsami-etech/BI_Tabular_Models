CREATE VIEW [TABTOPS].[FactLotLeadTime]
AS select	DgnLotKey
	,	DgnCompleteDateTime as CompleteDateTime
	,	SKCompleteDate
	,	TranslationHours
	,	HoldTimeHours
	,	LeadTimeHour
	,	CCModCount
from DWTOPS.FactLotLeadTime;