CREATE VIEW [TABIRIS].[FactTicketRMA]
AS SELECT
	[SKTicket]										as [SK Ticket],
	[SKAsset]										as [SK Asset],
	[SKParentTicket]								as [SK ParentTicket],
	[SKTeam]										as [SK Team],
	[SKAccount]										as [SK Account],

	convert(date, convert(varchar(8), [TicketOpenDateKey]), 112)		as [Ticket Open Date],
	convert(date, convert(varchar(8), [TicketClosedDateKey]), 112)	as [Ticket Closed Date],
	convert(date, convert(varchar(8), [TicketResolvedDateKey]), 112)	as [Ticket Resolved Date],

	[RMA Count]															as [RMA Count],
	[Ticket Net Hrs]													as [RMA Net Hrs],
	[Ticket Calendar Hrs]												as [RMA Calendar Hrs],
	[Ticket Aging]														as [RMA Aging]

--Count of Item Replaced
--Count of DOA (RTH)
--expected today

FROM [DWIRIS].[DimTicket];