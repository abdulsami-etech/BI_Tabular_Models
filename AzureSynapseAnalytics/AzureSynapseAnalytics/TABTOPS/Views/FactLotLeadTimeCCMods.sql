CREATE VIEW [TABTOPS].[FactLotLeadTimeCCMods]
AS select	DgnLotKey
	,	DgnCompleteDateTime as CompleteDateTime
	,	SKCompleteDate
	,	TranslationHours
	,	HoldTimeHours
	,	LeadTimeHour
	,	CCModCount
from DWTOPS.FactLotLeadTimeCCMods;