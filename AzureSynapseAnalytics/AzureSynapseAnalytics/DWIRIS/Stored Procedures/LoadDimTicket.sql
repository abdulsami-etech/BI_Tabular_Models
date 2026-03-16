CREATE PROC [DWIRIS].[LoadDimTicket] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on


	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#schedule') is not null
			drop table #schedule


			

/* Workday time */
		select 
				 [Id]
				,[Name]
				,datename
				,Start_time
				,End_time
		into #schedule
			from (
					select
						 [Id]
						,[Name]
						,'Monday' as datename
						,[MondayStartTime] as Start_time
						,[MondayEndTime]  as End_time
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Tuesday' as datename
						,[TuesdayStartTime]
						,[TuesdayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Wednesday' as datename
						,[WednesdayStartTime]
						,[WednesdayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Thursday' as datename
						,[ThursdayStartTime]
						,[ThursdayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Friday' as datename
						,[FridayStartTime]
						,[FridayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Saturday' as datename
						,[SaturdayStartTime]
						,[SaturdayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Sunday' as datename
						,[SundayStartTime]
						,[SundayEndTime]
					from [SrcSFDC].[BusinessHours]
				 ) t




	if object_id('tempdb..#TempDimTicket') is not null
		drop table #TempDimTicket

-- Get delta rows
	create table #TempDimTicket with (distribution = round_robin, heap) as 
	select 
			ht.SKTicket								as SKTicket
		,	c.ADLSBatchID							as ADLSBatchID
		,	c.ADLSTimestamp							as ADLSTimestamp
		,	c.LZBatchID								as LZBatchID
		,	convert(char(40), '')					as DWHash,
			ht.KeyTicket							as KeyTicket,
		   hac.SKAccount							as SKAccount, -- lookup 
		   ha.SKAsset								as SKAsset, -- lookup in HubAsset
		   htp.SKTicket								as SKParentTicket,
		   htm.SKTeam								as SKTeam,

		   op.Cancellation_Cause__c					as CancellationCause,
		   convert(nvarchar(255), NULL) /*op.Cancellation_Status__c*/					as CancellationStatus,
		   con.Name									as ContactFullName,
		   c.Did_scanner_ship__c					as DidScannerShipFlag,
		   convert(int, convert(varchar(8), c.Date_Issue_was_Found__c, 112))	as IssueFoundDateKey,
		   c.Date_Issue_was_Found__c				as IssueFoundDate,
		   CONVERT(nvarchar(50),NULL)				as EntityType,
		   c.Final_Status__c						as FinalStatus,
		   isnull(ast.SerialNumber,c.Serial_Number__c)						as ScannerSN,
		   c.IsClosed								as IsClosed,
		   c.IsClosedOnCreate						as IsClosedOnCreate,
		   c.IsDeleted								as IsDeleted,
		   c.IsEscalated							as IsEscalated,
		   c.Issue_Type__c							as IssueType,
		   c.LastModifiedDate						as LastModifiedDate,
		   c.Location_Status__c						as LocationStatus,
		   NULL										as MATTicketID,
		   c.New_iTero_customer__c					as NewIteroCustomer,
		   c.Origin									as Origin,
		   convert(nchar(18),c.ParentId)			as ParentTicket,
		   c.[Priority]								as [Priority], -- WTF two same fields
		   c.[Priority]								as [PriorityGenericDescription],
		   c.Processing_Stage_Status__c				as ProcessingStageStatus,
		   rt.Name									as RecordType,
		   c.Return_Type__c							as [ReturnType],
		   c.Scanner_Rev_Req__c						as ScannerRevReq,
		   c.Shipping_Stage_Status__c				as ShippingStageStatus,
		   c.[Status]								as [Status],
		   c.Sub_Issue_Type__c						as SubIssueType,
		   own.Name									as [TicketAssignedTo],
		   convert(int, convert(varchar(8), c.Cancelled_Date__c, 112))		as TicketCancelledDateKey,
		   c.Cancelled_Date__c						as TicketCancelledDate,
		   convert(int, convert(varchar(8), c.ClosedDate, 112))			as TicketClosedDateKey,
		   c.ClosedDate								as TicketClosedDate,
		   NULL										as TicketIssueAssetGenericDescription,
		   c.CaseNumber								as TicketNumber,
		   convert(int, convert(varchar(8), c.CreatedDate, 112))		as TicketOpenDateKey,
		   c.CreatedDate							as TicketOpenDate,
		   u.Name									as TicketOpenedBy,
		   convert(int, convert(varchar(8), c.ClosedDate, 112))			as TicketResolvedDateKey,
		   c.ClosedDate								as TicketResolvedDate,
		   c.Status									as TicketStatus,
		   c.Ticket_Type__c							as TicketType,
		   c.Track_status__c						as TrackStatus,
   		   /* Facts */
		   NULL										as [Ticket Net Hrs], -- how to calculate this ?
		   datediff(hh, c.CreatedDate,isnull(c.ClosedDate, getdate())) as [Ticket Calendar Hrs],
		   datediff(dd, c.CreatedDate, getdate()) as [Ticket Aging], -- how to calculate this , depends on [Ticket Net Hrs]
		   1 as [Tickets Count],
		   CASE 
			WHEN rt.Name = 'iTero RMA' THEN 1
			else 0
		   end as [RMA Count],
		   c.[BusinessHoursId],
		   hu.SKUser as SKUser,
		   c.[First_Interaction_Resolution__c]		as [FirstInteractionResolution],
		   CONVERT(int,NULL) as OrderID,
		   CONVERT(int,NULL) as ActivityCount,
		   c.LastModifiedDate as LastActivityDate,
		   hu_owner.SKUser	  as SKUserAssignedTo,
		   case when gr.Id is not null then 1 else 0 end as [IsInvalid],
		   'SFDC'											as [SourceSystem],
		   --c.[Description]									as [TicketDescription],
		   cc.[NumOfCom]									as [NumberOfComments],
		   att.[NumOfAttach]								as [NumberOfAttachments],
		   c.SO_number__c									as [SAP_SO]
 	from SrcSFDC.[Case] c
			join [DWIRIS].[HubTicket] ht
				on ht.KeyTicket = convert(nchar(18),c.Id)
			left join SrcSFDC.Asset ast
				on ast.Id = c.AssetId
			left join [DWIRIS].[HubAsset] ha
				on ha.KeyAsset = isnull(ast.SerialNumber,c.Serial_Number__c)
			/* Added SKTeam */
			left join [DWIRIS].[HubTeam] htm
				on htm.KeyTeam = c.Team_Function__c 
				and htm.SourceSystemCode = 'SFDC'
			left join [SrcSFDC].[User] u
				on c.CreatedById = u.Id
			left join SrcSFDC.Opportunity op
				on c.Opportunity__c = op.Id
			left join DW.HubAccount hac
				on hac.KeyAccount = c.AccountID
			left join SrcSFDC.Contact con
				on con.Id = c.ContactId
			left join SrcSFDC.RecordType rt
				on rt.Id = c.RecordTypeId
			left join SrcSFDC.Contact own
				on c.OwnerId = own.Id
			left join [DWIRIS].[HubUser] hu
				on hu.KeyUser = u.Id and hu.SourceSystemCode = 'SFDC'
			left join [DWIRIS].[HubUser] hu_owner
				on hu_owner.KeyUser = c.OwnerId and hu.SourceSystemCode = 'SFDC'
			/* Parent Ticket */
			left join [DWIRIS].[HubTicket] htp
				on htp.KeyTicket = convert(nchar(18),c.ParentID)
			left join SrcSFDC.[Group] gr
				on gr.Id = c.OwnerID and gr.[Name] = 'Invalid Tickets'
			/* BI-11319 */
			left join (select ParentId, count(*) as NumOfCom from SrcSFDC.[CaseComment] group by ParentId) cc
				on cc.ParentID = c.Id
			left join (select ParentId, count(*) as NumOfAttach from SrcSFDC.[Attachment] group by ParentId) att
				on att.ParentID = c.Id
			where rt.Name in ('iTero RMA','iTero Support')
			and c.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTicket where SourceSystem = 'SFDC')
UNION ALL
		select 
			 	ht.SKTicket								as SKTicket,
				tck.ADLSBatchID							as ADLSBatchID,
				tck.ADLSTimestamp							as ADLSTimestamp,
				tck.LZBatchID								as LZBatchID,
				convert(char(40), '')					as DWHash,
				ht.KeyTicket							as KeyTicket,
			 hac.SKAccount												as SKAccount, -- lookup
			 ha.SKAsset													as SKAsset, -- lookup in HubAsset
			 NULL														as SKParentTicket,
			 htm.SKTeam													as SKTeam,
			 NULL														as CancellationCause,
			 NULL														as CancellationStatus,
			 c_init.ContactFullName										as ContactFullName,
			 NULL														as DidScannerShipFlag,
			 NULL														as IssueFoundDateKey,
			 NULL														as IssueFoundDate,
			 isnull(ent.TicketIssueEntityTypeGenericDescription, N'')	as EntityType,
			 NULL														as FinalStatus,
			 CASE
				WHEN CONVERT(NVARCHAR(30),ent.TicketIssueEntityTypeGenericDescription) = 'Scanner' 
					THEN ec.SerialIdentifier
				WHEN CONVERT(NVARCHAR(30),ent.TicketIssueEntityTypeGenericDescription) = 'Specific order' 
					THEN (SELECT MAX(cast(TicketIssueEntityID as nvarchar))
					FROM [SrcMAT].svc_Ticket WHERE TicketIssueEntityID = tck.TicketIssueEntityID)
				ELSE ''
			 END														AS ScannerSN,
			 NULL														as IsClosed,
			 NULL														as IsClosedOnCreate,
			 NULL														as IsDeleted,
			 NULL														as IsEscalated,
			 t.TicketIssueTypeGenericDescription						as IssueType,
			 tck.DateUpdated											as LastModifiedDate,
			 NULL														as LocationStatus,
			 tck.TicketID												as MATTicketID,
			 NULL														as NewIteroCustomer,
			 NULL														as Origin,
			 NULL														as ParentTicket,
			 NULL														as [Priority],
			 p.PriorityGenericDescription								as [PriorityGenericDescription],
			 NULL														as ProcessingStageStatus,
			 NULL														as RecordType,
			 convert(nvarchar(255),tpr.IsRMA)							as [ReturnType],
			 NULL														as ScannerRevReq,
			 NULL														as ShippingStageStatus,
			 NULL														as [Status],
			 st.TicketIssueSubTypeGenericDescription					as SubIssueType,
			 c_assign.ContactFullName									as [TicketAssignedTo],
			 NULL														as TicketCancelledDateKey, 
			 NULL														as TicketCancelledDate, 
			 CASE WHEN rs.RowStatusDescriptionGeneric = 'Closed'
				  THEN convert(int, convert(varchar(8), tck.DateUpdated, 112))
			 END														as TicketClosedDateKey,
			 CASE WHEN rs.RowStatusDescriptionGeneric = 'Closed'
			 THEN tck.DateUpdated
			 END														as TicketClosedDate,
			 asset.TicketIssueAssetGenericDescription					as TicketIssueAssetGenericDescription,
			 NULL														as TicketNumber,
			 convert(int, convert(varchar(8), tck.DateCreated, 112))	as TicketOpenDateKey,
			 tck.DateCreated											as TicketOpenDate,
			 c_creator.ContactFullName									as TicketOpenedBy,
			 convert(int, convert(varchar(8), tck.DateResolved, 112))	as TicketResolvedDateKey,
			 tck.DateResolved											as TicketResolvedDate,
			 rs.RowStatusDescriptionGeneric								as TicketStatus,
			 NULL														as TicketType,
			 NULL														as TrackStatus,
			  /* Facts */
			NULL														as [Ticket Net Hrs], -- how to calculate this ?
			   datediff(hh, tck.DateCreated,coalesce(tck.DateUpdated,tck.DateResolved, getdate())) as [Ticket Calendar Hrs],
			   datediff(dd, tck.DateCreated,getdate()) as [Ticket Aging], -- how to calculate this , depends on [Ticket Net Hrs]
			   1 as [Tickets Count],
			   CASE 
				WHEN tpr.IsRMA = 1 THEN 1
				else 0
			   end as [RMA Count]
			   ,
			   '01mi0000000Xp2YAAS' as [BusinessHoursId], -- use default SFDC businesshoursid for calculation (in MAT there is no suh id)
			   hu.SKUser,
			N''															as [FirstInteractionResolution],
			case tck.TicketIssueEntityTypeID 
				when 2 then tck.TicketIssueEntityID
				else -1 
			end						  as OrderID,
			isnull(act.cnt, 0) as ActivityCount,
			case when (act.dt is null or act.dt < tck.DateUpdated) then tck.DateUpdated else act.dt end as LastActivityDate,
			hu_owner.SKUser	  as SKUserAssignedTo,
			NULL as IsInvalid,
		   'MAT'													as [SourceSystem],
		   --tck.[Description]										as [TicketDescription],
		   convert(int,null)										as [NumberOfComments],
		   convert(int,null)										as [NumberOfAttachments],
		   NULL														as [SAP_SO]

		from SrcMAT.svc_Ticket tck
		join [DWIRIS].[HubTicket] ht
			on ht.KeyTicket = convert(nchar(18),tck.TicketID)
		left join [SrcMAT].svc_Team team
			on team.TeamID = tck.TicketTeamID
		/* Added SKTeam */
		left join [DWIRIS].[HubTeam] htm
			on htm.KeyTeam = team.ContactTeamGenericDescription 
			and htm.SourceSystemCode = 'MAT'
		left join SrcMAT.svc_EquipmentCard ec
			on ec.EquipmentCardID = tck.TicketIssueEntityID
		left join [DWIRIS].[HubAsset] ha
			on ha.KeyAsset = ec.SerialIdentifier
		left join SrcMAT.BusinessPartnerSalesforceLink BPlink 
			ON BPlink.BusinessPartnerID =  tck.TicketInitiatorBusinessPartnerID
			and BPlink.RowStatusID <> 5
		left join SrcSFDC.Account ac
			on ac.Account_Number__c = BPlink.SalesforceAccountNum
			and try_convert(int, ac.MAT_ID__c) = BPlink.BusinessPartnerID
		left join DW.HubAccount hac
			on hac.KeyAccount = ac.Id
		/* Init Contact */
		left join SrcMat.Contact c_init
			on c_init.ContactID = tck.TicketInitiatorContactID
		/* Assign contact */
		left join SrcMat.Contact c_assign
			on c_assign.ContactID = tck.TicketAssignedToContactID
		left join SrcMAT.svc_TicketIssueEntityType ent 
			on ent.TicketIssueEntityTypeID = tck.TicketIssueEntityTypeID
		left join SrcMAT.svc_TicketIssueType t 
			on t.TicketIssueTypeID = tck.TicketIssueTypeID
		left join SrcMAT.[Priority] p
			on p.PriorityID = tck.PriorityID
		left join(
				select 
					tprl.TicketId,
					MAX(CASE WHEN tpr.IsRMA = 1 THEN 1 ELSE 0 END) as IsRMA
				from SrcMAT.svc_Ticket_PartsRequestLink tprl
				left join SrcMAT.svc_Ticket_PartsTracking tpr
					on tpr.RequestLinkId = tprl.svc_Ticket_PartsRequestLinkId
				group by tprl.TicketId
			) tpr
			on tpr.TicketId = tck.TicketID

		left join SrcMAT.svc_TicketIssueSubType st 
			on st.TicketIssueSubTypeID = tck.TicketIssueSubTypeID
		left join SrcMAT.svc_TicketIssueAsset asset 
			on tck.TicketIssueAssetID = asset.TicketIssueAssetID
		/* Created by Contact */
		left join SrcMat.Contact c_creator
			on c_creator.ContactID = tck.CreatedByUserID
		/* Ticket Status */
		left join SrcMAT.RowStatus rs 
			on tck.RowStatusID = rs.RowStatusID
		/* Join For close date*/
		left join SrcMAT.svc_Ticket tck_closed
			on tck_closed.TicketID = tck.TicketID and tck_closed.RowStatusID = 7
		left join [DWIRIS].[HubUser] hu
			on hu.KeyUser = tck.CreatedByUserID and hu.SourceSystemCode = 'MAT'
		left join [DWIRIS].[HubUser] hu_owner
			on hu_owner.KeyUser = tck.TicketAssignedToContactID and hu_owner.SourceSystemCode = 'MAT'
	    left join (
					select atl.TicketID
						, cnt = count(distinct atl.ActivityID)
						, dt = max(a.DateCreated)
						from SrcMAT.Activity_TicketLink atl 
					join SrcMAT.Activity a
						on atl.ActivityID = a.ActivityID
					group by atl.TicketID
				) act 
					on tck.TicketID = act.TicketID
	where tck.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTicket where SourceSystem = 'MAT')
	and tck.TicketID not in (select TicketID from SrcMAT.TicketComplaint)



	if object_id('tempdb..#TempDuration') is not null
		drop table #TempDuration

select 
							t.SKTicket,
							round(cast(sum(
							CASE
								WHEN t.date_order = 'First' 
									then  
										CASE 
											WHEN CONVERT(TIME, t.start_date) < CONVERT(TIME, sc.start_time)
											THEN datediff(ss,cast(sc.start_time as time),cast(sc.end_time as time))
											WHEN CONVERT(TIME, t.start_date) >= CONVERT(TIME, sc.start_time) and CONVERT(TIME, t.start_date) < CONVERT(TIME, sc.end_time)
											THEN datediff(ss,cast(t.start_date as time),cast(sc.end_time as time))
											ELSE 0
										END
								WHEN t.date_order = 'Between'
									 then datediff(ss,cast(sc.start_time as time),cast(sc.end_time as time))
								WHEN t.date_order = 'Last' 
									THEN
										CASE	
											WHEN CONVERT(TIME, t.start_date) >=  CONVERT(TIME, sc.end_time)
												THEN datediff(ss,cast(sc.start_time as time),cast(sc.end_time as time))
											WHEN CONVERT(TIME, t.start_date) >=  CONVERT(TIME, sc.start_time) and CONVERT(TIME, t.start_date) < CONVERT(TIME, sc.end_time)
												THEN datediff(ss,cast(sc.start_time as time),cast(t.start_date as time))
											WHEN CONVERT(TIME, t.start_date) < CONVERT(TIME, sc.end_time)
												THEN 0
										END
							end
							) as float)/3600,2)
							 as Duration
						into #TempDuration
						from (select
								SKTicket as SKTicket,
								'First' as date_order,
								DATENAME(weekday, TicketOpenDate) as date_name, 
								TicketOpenDate as start_Date,
								BusinessHoursId
								from #TempDimTicket
							UNION ALL
							select
								SKTicket,
								'Between' as date_order,
								DayNameLong,
								convert(datetime,KeyDate),
								BusinesshoursID
							from #TempDimTicket dmt 
								join DW.DimDate dd
							on convert(datetime,dd.KeyDate) > dmt.TicketOpenDate and convert(datetime,dd.KeyDate) < isnull(dmt.TicketClosedDate,getdate())
							--on convert(datetime,dd.KeyDate) > dmt.TicketOpenDate and dd.KeyDate < convert(date,dmt.TicketClosedDate)
							UNION all
							select
								SKTicket,
								'Last' as date_order,
								DATENAME(weekday,isnull(TicketClosedDate,getdate())), 
								TicketClosedDate,
								BusinesshoursID
							from #TempDimTicket) t
						inner join #schedule	sc
							on t.BusinessHoursID = sc.[Id] and t.date_name = sc.datename
						group by 
							t.SKTicket

update #TempDimTicket 
set [Ticket Net Hrs] = (
	select 
		case 
			when cast(TicketOpenDate as date) = cast(TicketClosedDate as date)
			THEN datediff(hh,TicketOpenDate,TicketClosedDate)
			when TicketClosedDate > TicketOpenDate
			THEN 0
			else Duration 
		end from #TempDuration where #TempDuration.SKTicket = #TempDimTicket.SKTicket)


--update HASH
	update #TempDimTicket set DWHash=
		convert(char(40),
			hashbytes('SHA1',
								 ISNULL(convert(nvarchar(255),[SKAccount]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKAsset]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKParentTicket]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKUserAssignedTo]),'')
							+'|'+ISNULL(convert(nvarchar(255),[CancellationCause]),'')
							+'|'+ISNULL(convert(nvarchar(255),[CancellationStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ContactFullName]),'')
							+'|'+ISNULL(convert(nvarchar(255),[DidScannerShipFlag]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IssueFoundDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[EntityType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[FinalStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ScannerSN]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsClosed]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsClosedOnCreate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsDeleted]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsEscalated]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IssueType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[LastModifiedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[LocationStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[MATTicketID]),'')
							+'|'+ISNULL(convert(nvarchar(255),[NewIteroCustomer]),'')
							+'|'+ISNULL(convert(nvarchar(255),[Origin]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ParentTicket]),'')
							+'|'+ISNULL(convert(nvarchar(255),[Priority]),'')
							+'|'+ISNULL(convert(nvarchar(255),[PriorityGenericDescription]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ProcessingStageStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[RecordType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ReturnType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ScannerRevReq]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ShippingStageStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[Status]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SubIssueType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketAssignedTo]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketCancelledDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketClosedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketIssueAssetGenericDescription]),'')
							+'|'+ISNULL(convert(nvarchar(255),[KeyTicket]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketNumber]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketOpenDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketOpenedBy]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketResolvedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TrackStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[BusinessHoursId]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKUser]),'')
							+'|'+ISNULL(convert(nvarchar(255),[FirstInteractionResolution]),'')
							+'|'+ISNULL(convert(nvarchar(255),[OrderID]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ActivityCount]),'')
							+'|'+ISNULL(convert(nvarchar(255),[LastActivityDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKUserAssignedTo]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsInvalid]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SourceSystem]),'')
							--+'|'+ISNULL(convert(nvarchar(255),[TicketDescription]),'')
							+'|'+ISNULL(convert(nvarchar(255),[NumberOfComments]),'')
							+'|'+ISNULL(convert(nvarchar(255),[NumberOfAttachments]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SAP_SO]),'')
							

				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTicket] where SKTicket = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWIRIS.DimTicket (
				[SKTicket]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[SKAccount]
				,[SKAsset]
				,[SKParentTicket]
				,[SKTeam]

				--,[AdditionalCommentsOther]
				--,[AdditionalInformation]
				,[CancellationCause]
				,[CancellationStatus]
				--,[ComplaintHandlingAndAssessmentDoneBy]
				--,[ComplaintStatus]
				,[ContactFullName]
				--,[CustomerIssueDescription]
				--,[CustomerServiceInitialInvestigation]
				--,[DidEventResultIn]
				,[DidScannerShipFlag]
				,[IssueFoundDateKey]
				,[IssueFoundDate]
				--,[DuplicateOf]
				,[EntityType]
				--,[EvaluationImpactLevel]
				,[FinalStatus]
				--,[HazardSituation]
				,[ScannerSN]
				--,[InvestigationCAPAReference]
				--,[InWhatCountry]
				,[IsClosed]
				,[IsClosedOnCreate]
				,[IsDeleted]
				,[IsEscalated]
				--,[IsFurtherInvestigationNeeded]
				--,[IsRegulatoryNonConformance]
				--,[IsReportable]
				--,[IsSafety]
				--,[IsSafetyOrPotentially]
				,[IssueType]
				--,[IsValidComplaint]
				--,[JustificationReportSummary]
				,[LastModifiedDate]
				,[LocationStatus]
				,[MATTicketID]
				,[NewIteroCustomer]
				,[Origin]
				,[ParentTicket]
				,[Priority]
				,[PriorityGenericDescription]
				,[ProcessingStageStatus]
				--,[RationaleForFurtherInvestigationCAPANotRequired]
				,[RecordType]
				,[ReturnType]
				--,[RiskAnalysisDOC]
				--,[RootCause]
				,[ScannerRevReq]
				,[ShippingStageStatus]
				,[Status]
				,[SubIssueType]
				,[TicketAssignedTo]
				,[TicketCancelledDateKey]
				,[TicketCancelledDate]
				,[TicketClosedDateKey]
				,[TicketClosedDate]
				,[TicketIssueAssetGenericDescription]
				,[KeyTicket]
				,[TicketNumber]
				,[TicketOpenDateKey]
				,[TicketOpenDate]
				,[TicketOpenedBy]
				,[TicketResolvedDateKey]
				,[TicketResolvedDate]
				,[TicketStatus]
				,[TicketType]
				,[TrackStatus]
				,[Ticket Net Hrs]
				,[Ticket Calendar Hrs]
				,[Ticket Aging]
				,[Tickets Count]
				,[RMA Count]
				--,[Complaints Count]
				,[BusinessHoursId]
				,[SKUser]
				,[FirstInteractionResolution]
				,[OrderID]
				,[ActivityCount]
				,[LastActivityDate]
				,[IsInvalid]
				,[SourceSystem]
				--,[TicketDescription]
				,[NumberOfComments]
				,[NumberOfAttachments]
				,[SAP_SO]
		)
		values (
				-1					-- SKTicket
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
			,	-1					--[SKAccount]
			,	-1					--[SKAsset]
			,	-1					--[SKParentTicket]
			,	-1					--[SKTeam]

			--,	'N/A'				-- AdditionalCommentsOther
			--,	'N/A'				-- AdditionalInformation
			,	'N/A'				--[CancellationCause]
			,	'N/A'				--[CancellationStatus]
			--,	'N/A'				--[ComplaintHandlingAndAssessmentDoneBy]
			--,	'N/A'				--[ComplaintStatus]
			,	'N/A'				--[ContactFullName]
			--,	'N/A'				--[CustomerIssueDescription]
			--,	'N/A'				--[CustomerServiceInitialInvestigation]
			--,	-1					--[DidEventResultIn]
			,	'N/A'				--[DidScannerShipFlag]
			,	19000101			--[IssueFoundDateKey]
			,	'19000101'			--[IssueFoundDate]
			--,	'N/A'				--[DuplicateOf]
			,	'N/A'				--[EntityType]
			--,	'N/A'				--[EvaluationImpactLevel]
			,	'N/A'				--[FinalStatus]
			--,	'N/A'				--[HazardSituation]
			,	'N/A'				--[ScannerSN]
			--,	'N/A'				--[InvestigationCAPAReference]
			--,	'N/A'				--[InWhatCountry]
			,	'N/A'				--[IsClosed]
			,	'N/A'				--[IsClosedOnCreate]
			,	'N/A'				--[IsDeleted]
			,	'N/A'				--[IsEscalated]
			--,	-1					--[IsFurtherInvestigationNeeded]
			--,	-1					--[IsRegulatoryNonConformance]
			--,	-1					--[IsReportable]
			--,	-1					--[IsSafety]
			--,	-1					--[IsSafetyOrPotentially]
			,	'N/A'				--[IssueType]
			--,	-1					--[IsValidComplaint]
			--,	'N/A'				--[JustificationReportSummary]
			,	'19000101'			--[LastModifiedDate]
			,	'N/A'				--[LocationStatus]
			,	-1					--[MATTicketID]
			,	'N/A'				--[NewIteroCustomer]
			,	'N/A'				--[Origin]
			,	'N/A'				--[ParentTicket]
			,	'N/A'				--[Priority]
			,	'N/A'				--[PriorityGenericDescription]
			,	'N/A'				--[ProcessingStageStatus]
			--,	'N/A'				--[RationaleForFurtherInvestigationCAPANotRequired]
			,	'N/A'				--[RecordType]
			,	-1					--[ReturnType]
			--,	'N/A'				--[RiskAnalysisDOC]
			--,	'N/A'				--[RootCause]
			,	-1					--[ScannerRevReq]
			,	'N/A'				--[ShippingStageStatus]
			,	'N/A'				--[Status]
			,	'N/A'				--[SubIssueType]
			--, [Subject]
			,	'N/A'				--[TicketAssignedTo]
			,	19000101			--[TicketCancelledDateKey]
			,	'19000101'			--[TicketCancelledDate]
			,	19000101			--[TicketClosedDateKey]
			,	'19000101'			--[TicketClosedDate]
			,	'N/A'				--[TicketIssueAssetGenericDescription]
			,	'N/A'				--[TicketKey]
			,	'N/A'				--[TicketNumber]
			,	19000101			--[TicketOpenDateKey]
			,	'19000101'			--[TicketOpenDate]
			,	'N/A'				--[TicketOpenedBy]
			,	19000101			--[TicketResolvedDateKey]
			,	'19000101'			--[TicketResolvedDate]
			,	'N/A'				--[TicketStatus]
			,	'N/A'				--[TicketType]
			,	'N/A'				--[TrackStatus]
			,	0					--[Ticket Net Hrs]
			,	0					--[Ticket Calendar Hrs]
			,	0					--[Ticket Aging]
			,	0					--[Tickets Count]
			,	0					--[RMA Count]
			--,	0					--[Complaints Count]
			,  NULL					--[BusinessHoursId]
			,	-1					--[SKUser]
			,	N''					--[FirstInteractionResolution]
			,	-1					--[OrderID]
			,	-1					--[ActivityCount]
			,	'19000101'			--[LastActivityDate]
			,	0					--[IsInvalid]
			,	'N/A'				--[SourceSystem]
			--,	'N/A'				--[TicketDescription]
			,	0					--[NumberOfComments]
			,	0					--[NumberOfAttachments]
			,	'N/A'				--[SAP_SO]
		)
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTicket]
		set
		     ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash
			,[SKAccount]   =  src.[SKAccount]
			,[SKAsset]   =  src.[SKAsset]
			,[SKParentTicket]   =  src.[SKParentTicket]
			,[SKTeam]=src.[SKTeam]

			--,[AdditionalCommentsOther]   =  src.[AdditionalCommentsOther]
			--,[AdditionalInformation]   =  src.[AdditionalInformation]
			,[CancellationCause]   =  src.[CancellationCause]
			,[CancellationStatus]   =  src.[CancellationStatus]
			--,[ComplaintHandlingAndAssessmentDoneBy]   =  src.[ComplaintHandlingAndAssessmentDoneBy]
			--,[ComplaintStatus]   =  src.[ComplaintStatus]
			,[ContactFullName]   =  src.[ContactFullName]
			--,[CustomerIssueDescription]   =  src.[CustomerIssueDescription]
			--,[CustomerServiceInitialInvestigation]   =  src.[CustomerServiceInitialInvestigation]
			--,[DidEventResultIn]   =  src.[DidEventResultIn]
			,[DidScannerShipFlag]   =  src.[DidScannerShipFlag]
			,[IssueFoundDateKey]   =  src.[IssueFoundDateKey]
			,[IssueFoundDate]   =  src.[IssueFoundDate]
			--,[DuplicateOf]   =  src.[DuplicateOf]
			,[EntityType]   =  src.[EntityType]
			--,[EvaluationImpactLevel]   =  src.[EvaluationImpactLevel]
			,[FinalStatus]   =  src.[FinalStatus]
			--,[HazardSituation]   =  src.[HazardSituation]
			,[ScannerSN]   =  src.[ScannerSN]
			--,[InvestigationCAPAReference]   =  src.[InvestigationCAPAReference]
			--,[InWhatCountry]   =  src.[InWhatCountry]
			,[IsClosed]   =  src.[IsClosed]
			,[IsClosedOnCreate]   =  src.[IsClosedOnCreate]
			,[IsDeleted]   =  src.[IsDeleted]
			,[IsEscalated]   =  src.[IsEscalated]
			--,[IsFurtherInvestigationNeeded]   =  src.[IsFurtherInvestigationNeeded]
			--,[IsRegulatoryNonConformance]   =  src.[IsRegulatoryNonConformance]
			--,[IsReportable]   =  src.[IsReportable]
			--,[IsSafety]   =  src.[IsSafety]
			--,[IsSafetyOrPotentially]   =  src.[IsSafetyOrPotentially]
			,[IssueType]   =  src.[IssueType]
			--,[IsValidComplaint]   =  src.[IsValidComplaint]
			--,[JustificationReportSummary]   =  src.[JustificationReportSummary]
			,[LastModifiedDate]   =  src.[LastModifiedDate]
			,[LocationStatus]   =  src.[LocationStatus]
			,[MATTicketID]   =  src.[MATTicketID]
			,[NewIteroCustomer]   =  src.[NewIteroCustomer]
			,[Origin]   =  src.[Origin]
			,[ParentTicket]   =  src.[ParentTicket]
			,[Priority]   =  src.[Priority]
			,[PriorityGenericDescription]   =  src.[PriorityGenericDescription]
			,[ProcessingStageStatus]   =  src.[ProcessingStageStatus]
			--,[RationaleForFurtherInvestigationCAPANotRequired]   =  src.[RationaleForFurtherInvestigationCAPANotRequired]
			,[RecordType]   =  src.[RecordType]
			,[ReturnType]   =  src.[ReturnType]
			--,[RiskAnalysisDOC]   =  src.[RiskAnalysisDOC]
			--,[RootCause]   =  src.[RootCause]
			,[ScannerRevReq]   =  src.[ScannerRevReq]
			,[ShippingStageStatus]   =  src.[ShippingStageStatus]
			,[Status]   =  src.[Status]
			,[SubIssueType]   =  src.[SubIssueType]
			,[TicketAssignedTo]   =  src.[TicketAssignedTo]
			,[TicketCancelledDateKey]   =  src.[TicketCancelledDateKey]
			,[TicketCancelledDate]   =  src.[TicketCancelledDate]
			,[TicketClosedDateKey]   =  src.[TicketClosedDateKey]
			,[TicketClosedDate]   =  src.[TicketClosedDate]
			,[TicketIssueAssetGenericDescription]   =  src.[TicketIssueAssetGenericDescription]
			,[KeyTicket]   =  src.[KeyTicket]
			,[TicketNumber]   =  src.[TicketNumber]
			,[TicketOpenDateKey]   =  src.[TicketOpenDateKey]
			,[TicketOpenDate]   =  src.[TicketOpenDate]
			,[TicketOpenedBy]   =  src.[TicketOpenedBy]
			,[TicketResolvedDateKey]   =  src.[TicketResolvedDateKey]
			,[TicketResolvedDate]   =  src.[TicketResolvedDate]
			,[TicketStatus]   =  src.[TicketStatus]
			,[TicketType]   =  src.[TicketType]
			,[TrackStatus]   =  src.[TrackStatus]
			,[Ticket Net Hrs]   =  src.[Ticket Net Hrs]
			,[Ticket Calendar Hrs]   =  src.[Ticket Calendar Hrs]
			,[Ticket Aging]   =  src.[Ticket Aging]
			,[Tickets Count]   =  src.[Tickets Count]
			,[RMA Count]   =  src.[RMA Count]
			--,[Complaints Count]   =  src.[Complaints Count]
			,[BusinessHoursId]=src.[BusinessHoursId]
			,[SKUser]=src.[SKUser]
			,[FirstInteractionResolution]	= src.[FirstInteractionResolution]
			,[OrderID]	= src.[OrderID]
			,[ActivityCount] = src.[ActivityCount]
			,[LastActivityDate] = src.[LastActivityDate]
			,SKUserAssignedTo = src.SKUserAssignedTo
			,IsInvalid = src.IsInvalid
			,[SourceSystem] = src.[SourceSystem]
			--,[TicketDescription] = src.[TicketDescription]
			,[NumberOfComments] = src.[NumberOfComments]
			,[NumberOfAttachments] = src.[NumberOfAttachments]
			,[SAP_SO] = src.[SAP_SO]

	from #TempDimTicket src
	where [DWIRIS].[DimTicket].SKTicket	=	src.SKTicket
		and [DWIRIS].[DimTicket].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTicket_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicket_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTicket] (
					[SKTicket]
				   ,[ADLSBatchID]
				   ,[ADLSTimestamp]
				   ,[LZBatchID]
				   ,[DWBatchID]
				   ,[DWHash]
				   ,[SKAccount]
				   ,[SKAsset]
				   ,[SKParentTicket]
				   ,[SKTeam]

				   --,[AdditionalCommentsOther]
				   --,[AdditionalInformation]
				   ,[CancellationCause]
				   ,[CancellationStatus]
				   --,[ComplaintHandlingAndAssessmentDoneBy]
				   --,[ComplaintStatus]
				   ,[ContactFullName]
				   --,[CustomerIssueDescription]
				   --,[CustomerServiceInitialInvestigation]
				   --,[DidEventResultIn]
				   ,[DidScannerShipFlag]
				   ,[IssueFoundDateKey]
				   ,[IssueFoundDate]
				   --,[DuplicateOf]
				   ,[EntityType]
				   --,[EvaluationImpactLevel]
				   ,[FinalStatus]
				   --,[HazardSituation]
				   ,[ScannerSN]
				   --,[InvestigationCAPAReference]
				   --,[InWhatCountry]
				   ,[IsClosed]
				   ,[IsClosedOnCreate]
				   ,[IsDeleted]
				   ,[IsEscalated]
				   --,[IsFurtherInvestigationNeeded]
				   --,[IsRegulatoryNonConformance]
				   --,[IsReportable]
				   --,[IsSafety]
				   --,[IsSafetyOrPotentially]
				   ,[IssueType]
				   --,[IsValidComplaint]
				   --,[JustificationReportSummary]
				   ,[LastModifiedDate]
				   ,[LocationStatus]
				   ,[MATTicketID]
				   ,[NewIteroCustomer]
				   ,[Origin]
				   ,[ParentTicket]
				   ,[Priority]
				   ,[PriorityGenericDescription]
				   ,[ProcessingStageStatus]
				   --,[RationaleForFurtherInvestigationCAPANotRequired]
				   ,[RecordType]
				   ,[ReturnType]
				   --,[RiskAnalysisDOC]
				   --,[RootCause]
				   ,[ScannerRevReq]
				   ,[ShippingStageStatus]
				   ,[Status]
				   ,[SubIssueType]
				   ,[TicketAssignedTo]
				   ,[TicketCancelledDateKey]
				   ,[TicketCancelledDate]
				   ,[TicketClosedDateKey]
				   ,[TicketClosedDate]
				   ,[TicketIssueAssetGenericDescription]
				   ,[KeyTicket]
				   ,[TicketNumber]
				   ,[TicketOpenDateKey]
				   ,[TicketOpenDate]
				   ,[TicketOpenedBy]
				   ,[TicketResolvedDateKey]
				   ,[TicketResolvedDate]
				   ,[TicketStatus]
				   ,[TicketType]
				   ,[TrackStatus]
				   ,[Ticket Net Hrs]
				   ,[Ticket Calendar Hrs]
				   ,[Ticket Aging]
				   ,[Tickets Count]
				   ,[RMA Count]
				   --,[Complaints Count]
				   ,[BusinessHoursId]
				   ,[SKUser]
				   ,[FirstInteractionResolution]
				   ,[OrderID]
				   ,[ActivityCount]
				   ,[LastActivityDate]
				   ,[SKUserAssignedTo]
				   ,[IsInvalid]
				   ,[SourceSystem]
				   --,[TicketDescription]
				   ,[NumberOfComments]
				   ,[NumberOfAttachments]
				   ,[SAP_SO]
	)
	select 
					[SKTicket]
				   ,[ADLSBatchID]
				   ,[ADLSTimestamp]
				   ,[LZBatchID]
				   ,@BatchID
				   ,[DWHash]
				   ,[SKAccount]
				   ,[SKAsset]
				   ,[SKParentTicket]
				   ,[SKTeam]

				   --,[AdditionalCommentsOther]
				   --,[AdditionalInformation]
				   ,[CancellationCause]
				   ,[CancellationStatus]
				   --,[ComplaintHandlingAndAssessmentDoneBy]
				   --,[ComplaintStatus]
				   ,[ContactFullName]
				   --,[CustomerIssueDescription]
				   --,[CustomerServiceInitialInvestigation]
				   --,[DidEventResultIn]
				   ,[DidScannerShipFlag]
				   ,[IssueFoundDateKey]
				   ,[IssueFoundDate]
				   --,[DuplicateOf]
				   ,[EntityType]
				   --,[EvaluationImpactLevel]
				   ,[FinalStatus]
				   --,[HazardSituation]
				   ,[ScannerSN]
				   --,[InvestigationCAPAReference]
				   --,[InWhatCountry]
				   ,[IsClosed]
				   ,[IsClosedOnCreate]
				   ,[IsDeleted]
				   ,[IsEscalated]
				   --,[IsFurtherInvestigationNeeded]
				   --,[IsRegulatoryNonConformance]
				   --,[IsReportable]
				   --,[IsSafety]
				   --,[IsSafetyOrPotentially]
				   ,[IssueType]
				   --,[IsValidComplaint]
				   --,[JustificationReportSummary]
				   ,[LastModifiedDate]
				   ,[LocationStatus]
				   ,[MATTicketID]
				   ,[NewIteroCustomer]
				   ,[Origin]
				   ,[ParentTicket]
				   ,[Priority]
				   ,[PriorityGenericDescription]
				   ,[ProcessingStageStatus]
				   --,[RationaleForFurtherInvestigationCAPANotRequired]
				   ,[RecordType]
				   ,[ReturnType]
				   --,[RiskAnalysisDOC]
				   --,[RootCause]
				   ,[ScannerRevReq]
				   ,[ShippingStageStatus]
				   ,[Status]
				   ,[SubIssueType]
				   ,[TicketAssignedTo]
				   ,[TicketCancelledDateKey]
				   ,[TicketCancelledDate]
				   ,[TicketClosedDateKey]
				   ,[TicketClosedDate]
				   ,[TicketIssueAssetGenericDescription]
				   ,[KeyTicket]
				   ,[TicketNumber]
				   ,[TicketOpenDateKey]
				   ,[TicketOpenDate]
				   ,[TicketOpenedBy]
				   ,[TicketResolvedDateKey]
				   ,[TicketResolvedDate]
				   ,[TicketStatus]
				   ,[TicketType]
				   ,[TrackStatus]
				   ,[Ticket Net Hrs]
				   ,[Ticket Calendar Hrs]
				   ,[Ticket Aging]
				   ,[Tickets Count]
				   ,[RMA Count]
				   --,[Complaints Count]
				   ,[BusinessHoursId]
				   ,[SKUser]
				   ,[FirstInteractionResolution]
				   ,[OrderID]
				   ,[ActivityCount]
				   ,[LastActivityDate]
				   ,[SKUserAssignedTo]
				   ,[IsInvalid]
				   ,[SourceSystem]
				   --,[TicketDescription]
				   ,[NumberOfComments]
				   ,[NumberOfAttachments]
				   ,[SAP_SO]
	from #TempDimTicket src
	where not exists(
		select dst.SKTicket 
		from DWIRIS.DimTicket dst 
		where dst.SKTicket = src.SKTicket
	)
	option (label = 'DWIRIS.LoadDimTicket_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicket_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure