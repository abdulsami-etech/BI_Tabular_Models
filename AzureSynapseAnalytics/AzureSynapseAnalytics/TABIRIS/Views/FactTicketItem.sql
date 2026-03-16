CREATE VIEW [TABIRIS].[FactTicketItem]
AS select	ti.SKTicketItem												as [SK Ticket Item]
	,	isnull(ti.SKAsset, -1)										as [SK Asset]
	,	isnull(ti.SKTicket, -1)										as [SK Ticket]
	,	convert(date, convert(varchar(8), ti.SKCreatedDate), 112)	as [Created Date]
	,	isnull(t.SKAccount, -1)										as [SK Account]
	,	isnull(t.SKTeam, -1)										as [SK Team]
	,	isnull(t.SKUser, -1)										as [SK User]

	,	ti.IsRMA													as [RMA Item Count]

from DWIRIS.DimTicketItem as ti
join DWIRIS.DimTicket as t
	on ti.SKTicket = t.SKTicket;