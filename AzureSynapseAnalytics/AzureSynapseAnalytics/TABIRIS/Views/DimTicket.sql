CREATE VIEW [TABIRIS].[DimTicket] AS SELECT
	t.[SKTicket]														as [SK Ticket],
	t.[KeyTicket]														as [Key Ticket],
	a.[AccountName]														as [Company],
	t.[ContactFullName]													as [Contact Full Name],
	t.[EntityType]														as [Entity Type],
	t.[ScannerSN]														as [Scanner SN],
	t.[IssueType]														as [Issue Type],
	t.[SubIssueType]													as [Sub Issue Type],
	t.[MATTicketID]														as [MAT Ticket ID],
	t.[PriorityGenericDescription]										as [Priority],
	t.[TicketAssignedTo]												as [Ticket Assigned To],
	t.[TicketIssueAssetGenericDescription]								as [Issue Asset],
	convert(date, convert(varchar(8), t.[TicketOpenDateKey]), 112)		as [Ticket Open Date],
	convert(datetime, t.[TicketOpenDate])								as [Ticket Open Date Time],
	convert(date, convert(varchar(8), t.[TicketClosedDateKey]), 112)	as [Ticket Closed Date],
	convert(datetime, t.[TicketClosedDate])								as [Ticket Closed Date Time],
	t.[TicketOpenedBy]													as [Ticket Opened By],
	convert(date, convert(varchar(8), t.[TicketResolvedDateKey]), 112)	as [Ticket Resolved Date],
	convert(datetime, t.[TicketResolvedDate])							as [Ticket Resolved Date Time],
	t.[TrackStatus]														as [Track Status],
	t.[LastModifiedDate]												as [Last Modified Date],
	t.[Origin]															as [Origin],
	CASE WHEN ([TicketClosedDateKey] IS NULL) 
			  AND ([TicketResolvedDateKey] IS NULL) 
		 THEN 'Open' 
		 ELSE 'Closed' 
	END																	as [Is Ticket Open],
	CASE WHEN [TicketResolvedDateKey] IS NOT NULL 
		 THEN 'Resolved' 
		 ELSE 'Not Resolved' 
	END																	as [Is Ticket Resolved],
	t.[Ticket Net Hrs]													as [Ticket Net Hrs],
	ROUND(t.[Ticket Net Hrs]/24,2)										as [Ticket Net Days],
	t.[Ticket Aging]													as [Ticket Aging],
	isnull(t.RecordType, N'Unknown')									as [Record Type],
	t.[TicketType]														as [Ticket Type],
	t.[FirstInteractionResolution]										as [First Interaction Resolution],
	t.TicketStatus														as [Ticket Status],
	DATEDIFF(HH,t.LastActivityDate,GETUTCDATE())						as [Aging Since Last Update],
	t.OrderID															as [Order ID],
	t.ActivityCount														as [Activity Count],
	t.LastActivityDate													as [Last Activity Date],
	case 
		WHEN 
		EXISTS 
		(
			select top 1 tck.SKTicketComplaint from DWIRIS.DimTicketComplaint tck
			WHERE tck.SKParentTicket = t.SKTicket
		) THEN 'Yes'
		ELSE 'No'
    END																	as [Complaint Exist],
	case 
		WHEN 
		EXISTS 
		(
			select tck.SKTicketComplaint from DWIRIS.DimTicketComplaint tck
			WHERE tck.SKParentTicket = t.SKTicket
		) THEN 
		(select top 1 tck.TicketNumber from DWIRIS.DimTicketComplaint tck
			WHERE tck.SKParentTicket = t.SKTicket)
		ELSE NULL
    END																	as [Ticket Complaint Number],
	case 
		WHEN 
		EXISTS 
		(
			select tck.SKTicketComplaint from DWIRIS.DimTicketComplaint tck
			WHERE tck.SKParentTicket = t.SKTicket
		) THEN 
		(select top 1 tck.IsSafety from DWIRIS.DimTicketComplaint tck
			WHERE tck.SKParentTicket = t.SKTicket)
		ELSE NULL
    END																	as [Is Safety]

,t.SKAccount
,t.SKAsset
,t.SKParentTicket
,t.SKTeam
,t.EntityType
,TicketAssignedTo
,t.[TicketNumber]													as [Ticket Number]
,t.[ReturnType]														as [Return Type]
,t.NumberOfComments													as [Number Of Comments]
,t.NumberOfAttachments												as [Number Of Attachments]
,t.[SAP_SO] 														as [SAP SO]
FROM [DWIRIS].[DimTicket] t
INNER JOIN [DWIRIS].[HubTicket] ht
	on ht.[SKTicket] = t.[SKTicket]
LEFT JOIN [DW].[DimAccount] a
	on t.SKAccount = a.SKAccount;