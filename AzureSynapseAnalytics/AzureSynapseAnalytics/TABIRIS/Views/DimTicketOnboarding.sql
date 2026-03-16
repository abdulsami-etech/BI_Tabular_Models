CREATE VIEW [TABIRIS].[DimTicketOnboarding]
AS SELECT
	t.[SKTicketOnboarding]																			as [SK Ticket Onboarding],
	t.[KeyTicketOnboarding]																			as [Key Ticket Onboarding],
	t.[TicketNumber]																				as [Ticket Number],
	t.[TicketStatus]																				as [Ticket Status],
	t.[TicketAssignedTo]																			as [Ticket Assigned To],
	a.[AccountName]																					as [Company],
	t.[ContactFullName]																				as [Contact Full Name],
	t.[Origin]																						as [Origin],
	t.[ProcessingStageStatus]																		as [Processing Status],
	t.[ShippingStageStatus]																			as [Shipping Status],
	t.[TicketOpenedBy]																				as [Ticket Opened By],
	CASE 
		WHEN ([TicketClosedDateKey] IS NULL) AND ([TicketResolvedDateKey] IS NULL) 
			THEN 'Open' 
		ELSE 'Closed' 
	END 																						    as [Is Ticket Open],
	convert(date, convert(varchar(8), t.[TicketOpenDateKey]), 112)									as [Ticket Open Date],
	convert(datetime, t.[TicketOpenDate])															as [Ticket Open Date Time],
	convert(date, convert(varchar(8), t.[TicketCancelledDateKey]), 112)								as [Ticket Cancelled Date],
	convert(datetime, t.[TicketCancelledDate])														as [Ticket Cancelled Date Time],
	convert(date, convert(varchar(8), t.[TicketClosedDateKey]), 112)								as [Ticket Closed Date],
	convert(datetime, t.[TicketClosedDate])															as [Ticket Closed Date Time],
	convert(date, convert(varchar(8), t.[TicketResolvedDateKey]), 112)								as [Ticket Resolved Date],
	convert(datetime, t.[TicketResolvedDate])														as [Ticket Resolved Date Time],
	convert(date, convert(varchar(8), t.[TicketFirstContactEmailDateKey]), 112)						as [Ticket First Contact Email Date],
	convert(datetime, t.[TicketFirstContactEmailDate])												as [Ticket First Contact Email Date Time],
	convert(date, convert(varchar(8), t.[TicketThirdContactDateKey]), 112)							as [Ticket Third Contact Date],
	convert(datetime, t.[TicketThirdContactDate])													as [Ticket Third Contact Date Time],
	convert(date, convert(varchar(8), t.[TicketFourthContactDateKey]), 112)							as [Ticket Fourth Contact Date],
	convert(datetime, t.[TicketFourthContactDate])													as [Ticket Fourth Contact Date Time],
	convert(date, convert(varchar(8), t.[NotificationSentToTrainerDateKey]), 112)					as [Notification Sent To Trainer Date],
	convert(datetime, t.[NotificationSentToTrainerDate])											as [Notification Sent To Trainer Date Time],
	convert(date, convert(varchar(8), t.[LeasingStatusDateKey]), 112)								as [Leasing Status Date],
	convert(datetime, t.[LeasingStatusDate])														as [Leasing Status Date Time],
	convert(date, convert(varchar(8), t.[OnboardingDateKey]), 112)									as [Onboarding Date],
	convert(datetime, t.[OnboardingDate])															as [Onboarding Date Time],
	t.[TrackStatus]																					as [Track Status]
FROM [DWIRIS].[DimTicketOnboarding] t
INNER JOIN [DWIRIS].[HubTicketOnboarding] ht
	on ht.[SKTicketOnboarding] = t.[SKTicketOnboarding]
LEFT JOIN [DW].[DimAccount] a
	on t.SKAccount = a.SKAccount;