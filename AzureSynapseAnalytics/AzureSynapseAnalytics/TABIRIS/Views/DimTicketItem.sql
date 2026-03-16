CREATE VIEW [TABIRIS].[DimTicketItem] AS select	ti.SKTicketItem				as [SK Ticket Item]
	,	ti.KeyTicketItem			as [Key Ticket Item]
	,	ti.CreatedDate				as [Created Date]
	,	ti.IsRMA					as [Is RMA]
	,	ti.IsDOA					as [Is DOA]
	,	ti.ReplacedType				as [Replaced Type]
	,	ti.ReplacedSN				as [Replaced SN]
	,	ti.ReplacementSN			as [Replacement SN]
	,	ti.TrackingNumber			as [Tracking Number]
	,	ti.ReportedIssue			as [Reported Issue]
	,	ti.RootCause				as [Root Cause]
	,	ti.ApprovedStatus			as [Approved Status]
	,	ti.ReplacementReason		as [Replacement Reason]
	,   ti.ProductName				as [Product Name]
	,   ti.ProductGroup             as [Product Group]
	,	ti.ProductCode				as [Product code]
from DWIRIS.DimTicketItem as ti
inner join DWIRIS.HubTicketItem hti
	on hti.SKTicketItem = ti.SKTicketItem;