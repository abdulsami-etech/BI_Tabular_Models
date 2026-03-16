CREATE VIEW [TABIRIS].[FactTicketOnboarding]
AS SELECT
	f.[SKTicketOnboarding]							as [SK Ticket Onboarding],
	f.[SKAsset]										as [SK Asset],
	f.[SKParentTicket]								as [SK ParentTicket],
	f.[SKTeam]										as [SK Team],
	f.[SKAccount]									as [SK Account],

	convert(date, convert(varchar(8), f.[TicketOpenDateKey]), 112)										as [Ticket Open Date],
	convert(date, convert(varchar(8), ISNULL(f.[TicketClosedDateKey],f.[TicketResolvedDateKey])), 112)	as [Ticket Closed Date],
	convert(date, convert(varchar(8), f.[TicketResolvedDateKey]), 112)									as [Ticket Resolved Date],
	
	
	convert(date, convert(varchar(8), f.[TicketCancelledDateKey]), 112)									as [Ticket Cancelled Date],
	convert(date, convert(varchar(8), f.[TicketFirstContactEmailDateKey]), 112)							as [Ticket First Contact Email Date],
	convert(date, convert(varchar(8), f.[TicketThirdContactDateKey]), 112)								as [Ticket Third Contact Date],
	convert(date, convert(varchar(8), f.[TicketFourthContactDateKey]), 112)								as [Ticket Fourth Contact Date],
	convert(date, convert(varchar(8), f.[NotificationSentToTrainerDateKey]), 112)						as [Notification Sent To Trainer Date],
	convert(date, convert(varchar(8), f.[LeasingStatusDateKey]), 112)									as [Leasing Status Date],
	convert(date, convert(varchar(8), f.[OnboardingDateKey]), 112)										as [Onboarding Date],
	
	f.[Tickets Count]								as [Tickets Count],
	
	CASE f.[Ticket Net Hrs]
		WHEN 0 THEN NULL
		ELSE f.[Ticket Net Hrs]	END					as [Ticket Net Hrs],
	
	CASE f.[Ticket Calendar Hrs]
		WHEN 0 THEN NULL
		ELSE f.[Ticket Calendar Hrs] END			as [Ticket Calendar Hrs],
	f.[Ticket Aging]								as [Ticket Aging],
	CASE WHEN ([TicketClosedDateKey] IS NULL) AND ([TicketResolvedDateKey] IS NULL) THEN 1 ELSE NULL END as [Is Ticket Open]

FROM [DWIRIS].[DimTicketOnboarding] f;