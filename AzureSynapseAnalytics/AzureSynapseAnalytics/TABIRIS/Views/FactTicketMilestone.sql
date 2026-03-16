CREATE VIEW [TABIRIS].[FactTicketMilestone]
AS select
		tm.SKTicketMilestone				as [SK Ticket Milestone]
	,	tm.SKTicket							as [SK Ticket]
	,	t.[SKAsset]							as [SK Asset]
	,	t.[SKTeam]							as [SK Team]
	,	t.[SKAccount]						as [SK Account]
	,	convert(date, tm.StartDate)			as [Key Start Date]
	
	,	tm.MileStoneNetHours				as [MileStone Net Hours]
	,	tm.MilestoneAging					as [Milestone Aging]
	,	tm.MilestonesCount					as [Milestones Count]

from DWIRIS.DimTicketMilestone tm
join DWIRIS.DimTicket t
	on tm.SKTicket = t.SKTicket;