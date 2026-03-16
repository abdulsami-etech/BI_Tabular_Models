CREATE PROC [DWIRIS].[LoadDimTicketTraining] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
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




	if object_id('tempdb..#TempDimTicketTraining') is not null
		drop table #TempDimTicketTraining

-- Get delta rows
	create table #TempDimTicketTraining with (distribution = round_robin, heap) as 
	select 
			ht.SKTicketTraining					as SKTicketTraining
		,	c.ADLSBatchID							as ADLSBatchID
		,	c.ADLSTimestamp							as ADLSTimestamp
		,	c.LZBatchID								as LZBatchID
		,	convert(char(40), '')					as DWHash,
			ht.KeyTicketTraining					as KeyTicketTraining,
		   hac.SKAccount							as SKAccount, -- lookup 
		   ha.SKAsset								as SKAsset, -- lookup in HubAsset
		   ht_p.SKTicket							as SKParentTicket,
		   htm.SKTeam								as SKTeam,
		   hu.SKUser								as SKUser,
		   own.Name									as [TicketAssignedTo],

		   c.CaseNumber								as TicketNumber,
		   con.Name									as ContactFullName,
		   c.Origin									as Origin,
		   c.[Status]								as [TicketStatus],
		   c.Processing_Stage_Status__c				as ProcessingStageStatus,
		   c.Shipping_Stage_Status__c				as ShippingStageStatus,
		   c.Final_Status__c						as FinalStatus,
		   c.[Priority]								as [Priority], -- WTF two same fields
		   convert(int, convert(varchar(8), c.Cancelled_Date__c, 112))		as TicketCancelledDateKey,
		   c.Cancelled_Date__c						as TicketCancelledDate,
		   convert(int, convert(varchar(8), c.ClosedDate, 112))			as TicketClosedDateKey,
		   c.ClosedDate								as TicketClosedDate,
		   convert(int, convert(varchar(8), c.CreatedDate, 112))		as TicketOpenDateKey,
		   c.CreatedDate							as TicketOpenDate,
		   u.Name									as TicketOpenedBy,
		   convert(int, convert(varchar(8), c.ClosedDate, 112))			as TicketResolvedDateKey,
		   c.ClosedDate								as TicketResolvedDate,
		   convert(int, convert(varchar(8), c.Date_First_Contact_Email__c, 112))				as [TicketFirstContactEmailDateKey],
		   c.Date_First_Contact_Email__c														as [TicketFirstContactEmailDate],
		   convert(int, convert(varchar(8), c.Date_Third_Contact__c, 112))						as [TicketThirdContactDateKey],
		   c.Date_Third_Contact__c																as [TicketThirdContactDate],	
		   convert(int, convert(varchar(8), c.Date_Fourth_Contact__c, 112))						as [TicketFourthContactDateKey],
		   c.Date_Fourth_Contact__c																as [TicketFourthContactDate],	
		   convert(int, convert(varchar(8), c.Date_Notification_Sent_to_Trainer__c, 112))		as [NotificationSentToTrainerDateKey],
		   c.Date_Notification_Sent_to_Trainer__c												as [NotificationSentToTrainerDate],	
		   convert(int, convert(varchar(8), op.Leasing_status_date__c, 112))					as [LeasingStatusDateKey],
		   op.Leasing_status_date__c															as [LeasingStatusDate],
		   convert(int, convert(varchar(8), NULL/*c.Next_Training_Contact_Date__c*/, 112))				as [TrainingDateKey],
		   convert(datetime2,NULL)/*c.Next_Training_Contact_Date__c*/													as [TrainingDate],	
		   c.Ticket_Type__c							as TicketType,
		   c.Track_status__c						as TrackStatus,
   		   /* Facts */
		   NULL										as [Ticket Net Hrs], 
		   datediff(hh, c.CreatedDate,isnull(c.ClosedDate, getdate())) as [Ticket Calendar Hrs],
		   NULL as [Ticket Aging],
		   1 as [Tickets Count],
		   c.[BusinessHoursId],
		   cp.CaseNumber as ParentTicketNumber,
		   c.Issue_Type__c as IssueType
	from SrcSFDC.[Case] c
			join [DWIRIS].[HubTicketTraining] ht
				on ht.KeyTicketTraining = convert(nchar(18),c.Id)
			/* Parent Ticket */
			left join [DWIRIS].[HubTicket] ht_p
				on ht_p.KeyTicket = convert(nchar(18),c.ParentID)
			left join [DWIRIS].[HubAsset] ha
				on ha.KeyAsset = c.Serial_Number__c
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
			left join SrcSFDC.[Case] cp
				on cp.Id = c.ParentID
			where c.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTicketTraining)
			and rt.Name in ('iTero Training','EU Training Records')


	if object_id('tempdb..#TempDuration') is not null
		drop table #TempDuration

	select 
		t.SKTicketTraining,
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
	from (
		select
			SKTicketTraining as SKTicketTraining,
			'First' as date_order,
			DATENAME(weekday, TicketOpenDate) as date_name, 
			TicketOpenDate as start_Date,
			BusinessHoursId
			from #TempDimTicketTraining
		UNION ALL
		select
			SKTicketTraining,
			'Between' as date_order,
			DayNameLong,
			convert(datetime,KeyDate),
			BusinesshoursID
		from #TempDimTicketTraining dmt 
			join DW.DimDate dd
		on convert(datetime,dd.KeyDate) > dmt.TicketOpenDate and convert(datetime,dd.KeyDate) < isnull(dmt.TicketClosedDate,getdate())
		--on convert(datetime,dd.KeyDate) > dmt.TicketOpenDate and dd.KeyDate < convert(date,dmt.TicketClosedDate)
		UNION all
		select
			SKTicketTraining,
			'Last' as date_order,
			DATENAME(weekday,isnull(TicketClosedDate,getdate())), 
			TicketClosedDate,
			BusinesshoursID
		from #TempDimTicketTraining
	) t
	inner join #schedule	sc
		on t.BusinessHoursID = sc.[Id] and t.date_name = sc.datename
	group by 
		t.SKTicketTraining

	update #TempDimTicketTraining 
	set [Ticket Net Hrs] = (
		select 
			case 
				when cast(TicketOpenDate as date) = cast(TicketClosedDate as date)
				THEN datediff(hh,TicketOpenDate,TicketClosedDate)
				when TicketClosedDate > TicketOpenDate
				THEN 0
				else Duration 
			end 
		from #TempDuration 
		where #TempDuration.SKTicketTraining = #TempDimTicketTraining.SKTicketTraining
	)


--update HASH
	update #TempDimTicketTraining set DWHash=
		convert(char(40),
			hashbytes('SHA1',
								 ISNULL(convert(nvarchar,[SKAccount]),'')
							+'|'+ISNULL(convert(nvarchar,[KeyTicketTraining]),'')
							+'|'+ISNULL(convert(nvarchar,[SKAsset]),'')
							+'|'+ISNULL(convert(nvarchar,[SKParentTicket]),'')
							+'|'+ISNULL(convert(nvarchar,[SKTeam]),'')
							+'|'+ISNULL(convert(nvarchar,[SKUser]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketAssignedTo]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketNumber]),'')
							+'|'+ISNULL(convert(nvarchar,[ContactFullName]),'')
							+'|'+ISNULL(convert(nvarchar,[Origin]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketStatus]),'')
							+'|'+ISNULL(convert(nvarchar,[ProcessingStageStatus]),'')
							+'|'+ISNULL(convert(nvarchar,[ShippingStageStatus]),'')
							+'|'+ISNULL(convert(nvarchar,[FinalStatus]),'')
							+'|'+ISNULL(convert(nvarchar,[Priority]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketCancelledDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketClosedDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketOpenDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketOpenedBy]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketResolvedDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketFirstContactEmailDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketThirdContactDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketFourthContactDate]),'')
							+'|'+ISNULL(convert(nvarchar,[NotificationSentToTrainerDate]),'')
							+'|'+ISNULL(convert(nvarchar,[LeasingStatusDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TrainingDate]),'')
							+'|'+ISNULL(convert(nvarchar,[TicketType]),'')
							+'|'+ISNULL(convert(nvarchar,[TrackStatus]),'')
							+'|'+ISNULL(convert(nvarchar,[BusinessHoursId]),'')
							+'|'+ISNULL(convert(nvarchar,[ParentTicketNumber]),'')
							+'|'+ISNULL(convert(nvarchar,[IssueType]),'')
				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTicketTraining] where SKTicketTraining = -1)
	begin
		declare @Hash char(40) = ''

		--set identity_insert DWIRIS.DimAsset on
		begin try
			insert into DWIRIS.DimTicketTraining (
				    	[SKTicketTraining]
					   ,[ADLSBatchID]
					   ,[ADLSTimestamp]
					   ,[LZBatchID]
					   ,[DWBatchID]
					   ,[DWHash]
					   ,[KeyTicketTraining]
					   ,[SKAccount]
					   ,[SKAsset]
					   ,[SKParentTicket]
					   ,[SKTeam]
					   ,[SKUser]
					   ,[TicketAssignedTo]
					   ,[TicketNumber]
					   ,[ContactFullName]
					   ,[Origin]
					   ,[TicketStatus]
					   ,[ProcessingStageStatus]
					   ,[ShippingStageStatus]
					   ,[FinalStatus]
					   ,[Priority]
					   ,[TicketCancelledDateKey]
					   ,[TicketCancelledDate]
					   ,[TicketClosedDateKey]
					   ,[TicketClosedDate]
					   ,[TicketOpenDateKey]
					   ,[TicketOpenDate]
					   ,[TicketOpenedBy]
					   ,[TicketResolvedDateKey]
					   ,[TicketResolvedDate]
					   ,[TicketFirstContactEmailDateKey]
					   ,[TicketFirstContactEmailDate]
					   ,[TicketThirdContactDateKey]
					   ,[TicketThirdContactDate]
					   ,[TicketFourthContactDateKey]
					   ,[TicketFourthContactDate]
					   ,[NotificationSentToTrainerDateKey]
					   ,[NotificationSentToTrainerDate]
					   ,[LeasingStatusDateKey]
					   ,[LeasingStatusDate]
					   ,[TrainingDateKey]
					   ,[TrainingDate]
					   ,[TicketType]
					   ,[TrackStatus]
					   ,[Ticket Net Hrs]
					   ,[Ticket Calendar Hrs]
					   ,[Ticket Aging]
					   ,[Tickets Count]
					   ,[BusinessHoursId]
					   ,[ParentTicketNumber]
					   ,[IssueType]
			)
			values (
					-1					-- SKTicketTraining
				,	-1					-- ADLSBatchID
				,	'19000101'			-- ADLSTimestamp
				,	-1					-- LZBatchID
				,	@BatchID			-- DWBatchID
				,	@Hash				-- DWHash
				,	'N/A'				--[KeyTicketTraining]
				,	-1					--[SKAccount]
				,	-1					--[SKAsset]
				,	-1					--[SKParentTicket]
				,	-1					--[SKTeam]
				,	-1					--[SKUser]
				,	'N/A'				--[TicketAssignedTo]
				,	'N/A'				--[TicketNumber]
				,	'N/A'				--[ContactFullName]
				,	'N/A'				--[Origin]
				,	'N/A'				--[TicketStatus]
				,	'N/A'				--[ProcessingStageStatus]
				,	'N/A'				--[ShippingStageStatus]
				,	'N/A'				--[FinalStatus]
				,	'N/A'				--[Priority]
				,	19000101			--[TicketCancelledDateKey]
				,	'19000101'			--[TicketCancelledDate]
				,	19000101			--[TicketClosedDateKey]
				,	'19000101'			--[TicketClosedDate]
				,	19000101			--[TicketOpenDateKey]
				,	'19000101'			--[TicketOpenDate]
				,	'N/A'				--[TicketOpenedBy]
				,	19000101			--[TicketResolvedDateKey]
				,	'19000101'			--[TicketResolvedDate]
				,	19000101			--[TicketFirstContactEmailDateKey]
				,	'19000101'			--[TicketFirstContactEmailDate]
				,	19000101			--[TicketThirdContactDateKey]
				,	'19000101'			--[TicketThirdContactDate]
				,	19000101			--[TicketFourthContactDateKey]
				,	'19000101'			--[TicketFourthContactDate]
				,	19000101			--[NotificationSentToTrainerDateKey]
				,	'19000101'			--[NotificationSentToTrainerDate]
				,	19000101			--[LeasingStatusDateKey]
				,	'19000101'			--[LeasingStatusDate]
				,	19000101			--[TrainingDateKey]
				,	'19000101'			--[TrainingDate]
				,	'N/A'				--[TicketType]
				,	'N/A'				--[TrackStatus]
				,	0					--[Ticket Net Hrs]
				,	0					--[Ticket Calendar Hrs]
				,	0					--[Ticket Aging]
				,	0					--[Tickets Count]
				,  NULL					--[BusinessHoursId]
				,	'N/A'				--[ParentTicketNumber]
				,	'N/A'				--[IssueType]

			)
		end try
		begin catch
		end catch

	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTicketTraining]
		set
		     [ADLSBatchID] = src.[ADLSBatchID]
			,[ADLSTimestamp] = src.[ADLSTimestamp]
			,[LZBatchID] = src.[LZBatchID]
			,[DWBatchID] = @BatchID
			,[DWHash] = src.[DWHash]
			,[KeyTicketTraining] = src.[KeyTicketTraining]
			,[SKAccount] = src.[SKAccount]
			,[SKAsset] = src.[SKAsset]
			,[SKParentTicket] = src.[SKParentTicket]
			,[SKTeam] = src.[SKTeam]
			,[SKUser] = src.[SKUser]
			,[TicketAssignedTo] = src.[TicketAssignedTo]
			,[TicketNumber] = src.[TicketNumber]
			,[ContactFullName] = src.[ContactFullName]
			,[Origin] = src.[Origin]
			,[TicketStatus] = src.[TicketStatus]
			,[ProcessingStageStatus] = src.[ProcessingStageStatus]
			,[ShippingStageStatus] = src.[ShippingStageStatus]
			,[FinalStatus] = src.[FinalStatus]
			,[Priority] = src.[Priority]
			,[TicketCancelledDateKey] = src.[TicketCancelledDateKey]
			,[TicketCancelledDate] = src.[TicketCancelledDate]
			,[TicketClosedDateKey] = src.[TicketClosedDateKey]
			,[TicketClosedDate] = src.[TicketClosedDate]
			,[TicketOpenDateKey] = src.[TicketOpenDateKey]
			,[TicketOpenDate] = src.[TicketOpenDate]
			,[TicketOpenedBy] = src.[TicketOpenedBy]
			,[TicketResolvedDateKey] = src.[TicketResolvedDateKey]
			,[TicketResolvedDate] = src.[TicketResolvedDate]
			,[TicketFirstContactEmailDateKey] = src.[TicketFirstContactEmailDateKey]
			,[TicketFirstContactEmailDate] = src.[TicketFirstContactEmailDate]
			,[TicketThirdContactDateKey] = src.[TicketThirdContactDateKey]
			,[TicketThirdContactDate] = src.[TicketThirdContactDate]
			,[TicketFourthContactDateKey] = src.[TicketFourthContactDateKey]
			,[TicketFourthContactDate] = src.[TicketFourthContactDate]
			,[NotificationSentToTrainerDateKey] = src.[NotificationSentToTrainerDateKey]
			,[NotificationSentToTrainerDate] = src.[NotificationSentToTrainerDate]
			,[LeasingStatusDateKey] = src.[LeasingStatusDateKey]
			,[LeasingStatusDate] = src.[LeasingStatusDate]
			,[TrainingDateKey] = src.[TrainingDateKey]
			,[TrainingDate] = src.[TrainingDate]
			,[TicketType] = src.[TicketType]
			,[TrackStatus] = src.[TrackStatus]
			,[Ticket Net Hrs] = src.[Ticket Net Hrs]
			,[Ticket Calendar Hrs] = src.[Ticket Calendar Hrs]
			,[Ticket Aging] = src.[Ticket Aging]
			,[Tickets Count] = src.[Tickets Count]
			,[BusinessHoursId] = src.[BusinessHoursId]
			,[ParentTicketNumber] = src.[ParentTicketNumber]
			,[IssueType] = src.[IssueType]

	from #TempDimTicketTraining src
	where [DWIRIS].[DimTicketTraining].SKTicketTraining	=	src.SKTicketTraining
		and [DWIRIS].[DimTicketTraining].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTicketTraining_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketTraining_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTicketTraining] (
						[SKTicketTraining]
				       ,[ADLSBatchID]
					   ,[ADLSTimestamp]
					   ,[LZBatchID]
					   ,[DWBatchID]
					   ,[DWHash]
					   ,[KeyTicketTraining]
					   ,[SKAccount]
					   ,[SKAsset]
					   ,[SKParentTicket]
					   ,[SKTeam]
					   ,[SKUser]
					   ,[TicketAssignedTo]
					   ,[TicketNumber]
					   ,[ContactFullName]
					   ,[Origin]
					   ,[TicketStatus]
					   ,[ProcessingStageStatus]
					   ,[ShippingStageStatus]
					   ,[FinalStatus]
					   ,[Priority]
					   ,[TicketCancelledDateKey]
					   ,[TicketCancelledDate]
					   ,[TicketClosedDateKey]
					   ,[TicketClosedDate]
					   ,[TicketOpenDateKey]
					   ,[TicketOpenDate]
					   ,[TicketOpenedBy]
					   ,[TicketResolvedDateKey]
					   ,[TicketResolvedDate]
					   ,[TicketFirstContactEmailDateKey]
					   ,[TicketFirstContactEmailDate]
					   ,[TicketThirdContactDateKey]
					   ,[TicketThirdContactDate]
					   ,[TicketFourthContactDateKey]
					   ,[TicketFourthContactDate]
					   ,[NotificationSentToTrainerDateKey]
					   ,[NotificationSentToTrainerDate]
					   ,[LeasingStatusDateKey]
					   ,[LeasingStatusDate]
					   ,[TrainingDateKey]
					   ,[TrainingDate]
					   ,[TicketType]
					   ,[TrackStatus]
					   ,[Ticket Net Hrs]
					   ,[Ticket Calendar Hrs]
					   ,[Ticket Aging]
					   ,[Tickets Count]
					   ,[BusinessHoursId]
					   ,[ParentTicketNumber]
					   ,[IssueType]
)
	select 
					[SKTicketTraining]
				   ,[ADLSBatchID]
				   ,[ADLSTimestamp]
				   ,[LZBatchID]
				   ,@BatchID
				   ,[DWHash]
				   ,[KeyTicketTraining]
				   ,[SKAccount]
				   ,[SKAsset]
				   ,[SKParentTicket]
				   ,[SKTeam]
				   ,[SKUser]
				   ,[TicketAssignedTo]
				   ,[TicketNumber]
				   ,[ContactFullName]
				   ,[Origin]
				   ,[TicketStatus]
				   ,[ProcessingStageStatus]
				   ,[ShippingStageStatus]
				   ,[FinalStatus]
				   ,[Priority]
				   ,[TicketCancelledDateKey]
				   ,[TicketCancelledDate]
				   ,[TicketClosedDateKey]
				   ,[TicketClosedDate]
				   ,[TicketOpenDateKey]
				   ,[TicketOpenDate]
				   ,[TicketOpenedBy]
				   ,[TicketResolvedDateKey]
				   ,[TicketResolvedDate]
				   ,[TicketFirstContactEmailDateKey]
				   ,[TicketFirstContactEmailDate]
				   ,[TicketThirdContactDateKey]
				   ,[TicketThirdContactDate]
				   ,[TicketFourthContactDateKey]
				   ,[TicketFourthContactDate]
				   ,[NotificationSentToTrainerDateKey]
				   ,[NotificationSentToTrainerDate]
				   ,[LeasingStatusDateKey]
				   ,[LeasingStatusDate]
				   ,[TrainingDateKey]
				   ,[TrainingDate]
				   ,[TicketType]
				   ,[TrackStatus]
				   ,[Ticket Net Hrs]
				   ,[Ticket Calendar Hrs]
				   ,[Ticket Aging]
				   ,[Tickets Count]
				   ,[BusinessHoursId]
					   ,[ParentTicketNumber]
					   ,[IssueType]

	from #TempDimTicketTraining src
	where not exists(
		select dst.SKTicketTraining 
		from DWIRIS.DimTicketTraining dst 
		where dst.SKTicketTraining = src.SKTicketTraining
	)
	option (label = 'DWIRIS.DimTicketTraining_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.DimTicketTraining_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end --procedure

