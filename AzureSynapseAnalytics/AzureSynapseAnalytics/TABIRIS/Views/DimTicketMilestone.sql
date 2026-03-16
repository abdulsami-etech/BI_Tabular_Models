CREATE VIEW [TABIRIS].[DimTicketMilestone]
AS select
		tm.SKTicketMilestone				as [SK Ticket Milestone]
	,	tm.BusinessHoursId					as [Key Business Hours]
	,	tm.TicketMilestoneId				as [Key Ticket Milestone]
	,	tm.CaseId							as [Key Ticket]
	,	tm.IsCompleted						as [Is Completed]
	,	tm.IsDeleted						as [Is Deleted]
	,	tm.IsViolated						as [Is Violated]
	,	tm.TargetResponseInDays				as [Target Response in Days]
	,	tm.TargetResponseInHrs				as [Target Response in Hrs]
	,	tm.TargetResponseInMins				as [Target Response in Mins]
	,	tm.CompletionDate					as [Completion Date]
	,	tm.ElapsedTimeInMins				as [Elapsed Time in Mins]
	,	tm.ElapsedTimeInDays				as [Elapsed Time in Days]
	,	tm.ElapsedTimeInHrs					as [Elapsed Time in Hrs]
	,	tm.StartDate						as [Start Date]
	,	tm.TargetDate						as [Target Date]
	,	tm.MilestoneName					as [Milestone Name]
	,	tm.MilestoneDescription				as [Milestone Description]
	,	tm.MileStoneNetHours				as [MileStone Net Hours]
	,	tm.MilestoneAging					as [Milestone Aging]
	,	tm.MilestonesCount					as [Milestones Count]

from DWIRIS.DimTicketMilestone tm
inner join DWIRIS.HubTicketMilestone htm
	on htm.SKTicketMilestone = tm.SKTicketMilestone;