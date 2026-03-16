CREATE VIEW [TABIRIS].[FactTicket]
AS SELECT
	f.[SKTicket],
	f.[SKAsset]										as [SK Asset],
	f.[SKParentTicket]								as [SK ParentTicket],
	f.[SKTeam]										as [SK Team],
	f.[SKAccount]									as [SK Account],

	convert(date, convert(varchar(8), f.[TicketOpenDateKey]), 112)										as [Ticket Open Date],
	convert(date, convert(varchar(8), ISNULL(f.[TicketClosedDateKey],f.[TicketResolvedDateKey])), 112)	as [Ticket Closed Date],
	convert(date, convert(varchar(8), f.[TicketResolvedDateKey]), 112)									as [Ticket Resolved Date],

	f.[Tickets Count]								as [Tickets Count],
	
	CASE f.[Ticket Net Hrs]
		WHEN 0 THEN NULL
		ELSE f.[Ticket Net Hrs]	END					as [Ticket Net Hrs],
	
	CASE f.[Ticket Calendar Hrs]
		WHEN 0 THEN NULL
		ELSE f.[Ticket Calendar Hrs] END			as [Ticket Calendar Hrs],
	f.[Ticket Aging]								as [Ticket Aging],
	CASE WHEN ([TicketClosedDateKey] IS NULL) AND ([TicketResolvedDateKey] IS NULL) THEN 1 ELSE NULL END as [Is Ticket Open]

FROM [DWIRIS].[DimTicket] f;