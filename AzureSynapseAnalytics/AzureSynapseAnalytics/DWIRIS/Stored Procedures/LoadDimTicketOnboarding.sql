CREATE PROC [DWIRIS].[LoadDimTicketOnboarding] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
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




	if object_id('tempdb..#TempDimTicketOnboarding') is not null
		drop table #TempDimTicketOnboarding

-- Get delta rows
	create table #TempDimTicketOnboarding with (distribution = round_robin, heap) as 
	select 
			ht.SKTicketOnboarding					as SKTicketOnboarding
		,	c.ADLSBatchID							as ADLSBatchID
		,	c.ADLSTimestamp							as ADLSTimestamp
		,	c.LZBatchID								as LZBatchID
		,	convert(char(40), '')					as DWHash,
			ht.KeyTicketOnboarding					as KeyTicketOnboarding,
		   hac.SKAccount							as SKAccount, -- lookup 
		   ha.SKAsset								as SKAsset, -- lookup in HubAsset
		   ht_p.SKSalesContract						as SKParentTicket,
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
		   convert(int, convert(varchar(8), c.Next_Onboarding_Contact_Date__c, 112))			as [OnboardingDateKey],
		   c.Next_Onboarding_Contact_Date__c													as [OnboardingDate],	
		   c.Ticket_Type__c							as TicketType,
		   c.Track_status__c						as TrackStatus,
   		   /* Facts */
		   NULL										as [Ticket Net Hrs], 
		   datediff(hh, c.CreatedDate,isnull(c.ClosedDate, getdate())) as [Ticket Calendar Hrs],
		   NULL as [Ticket Aging],
		   1 as [Tickets Count],
		   c.[BusinessHoursId],
		   case when gr.Id is not null then 1 else 0 end as [IsInvalid]
	from SrcSFDC.[Case] c
			join [DWIRIS].[HubTicketOnboarding] ht
				on ht.KeyTicketOnboarding = convert(nchar(18),c.Id)
			join [DWIRIS].HubSalesContract ht_p
				on ht_p.KeySalesContract = convert(nchar(18),c.ParentId)
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
			left join SrcSFDC.[Group] gr
				on gr.Id = c.OwnerID and gr.[Name] = 'Invalid Tickets'
			where rt.Name in ('iTero Onboarding','EU iTero Onboarding')
			and c.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTicket)


	if object_id('tempdb..#TempDuration') is not null
		drop table #TempDuration

	select 
		t.SKTicketOnboarding,
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
			SKTicketOnboarding as SKTicketOnboarding,
			'First' as date_order,
			DATENAME(weekday, TicketOpenDate) as date_name, 
			TicketOpenDate as start_Date,
			BusinessHoursId
			from #TempDimTicketOnboarding
		UNION ALL
		select
			SKTicketOnboarding,
			'Between' as date_order,
			DayNameLong,
			convert(datetime,KeyDate),
			BusinesshoursID
		from #TempDimTicketOnboarding dmt 
			join DW.DimDate dd
		on convert(datetime,dd.KeyDate) > dmt.TicketOpenDate and convert(datetime,dd.KeyDate) < isnull(dmt.TicketClosedDate,getdate())
		--on convert(datetime,dd.KeyDate) > dmt.TicketOpenDate and dd.KeyDate < convert(date,dmt.TicketClosedDate)
		UNION all
		select
			SKTicketOnboarding,
			'Last' as date_order,
			DATENAME(weekday,isnull(TicketClosedDate,getdate())), 
			TicketClosedDate,
			BusinesshoursID
		from #TempDimTicketOnboarding
	) t
	inner join #schedule	sc
		on t.BusinessHoursID = sc.[Id] and t.date_name = sc.datename
	group by 
		t.SKTicketOnboarding

	update #TempDimTicketOnboarding 
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
		where #TempDuration.SKTicketOnboarding = #TempDimTicketOnboarding.SKTicketOnboarding
	)


--update HASH
	update #TempDimTicketOnboarding set DWHash=
		convert(char(40),
			hashbytes('SHA1',
								 ISNULL(convert(nvarchar(255),[SKAccount]),'')
							+'|'+ISNULL(convert(nvarchar(255),[KeyTicketOnboarding]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[SKAsset]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[SKParentTicket]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[SKTeam]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[SKUser]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[TicketAssignedTo]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[TicketNumber]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[ContactFullName]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[Origin]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[TicketStatus]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[ProcessingStageStatus]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[ShippingStageStatus]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[FinalStatus]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[Priority]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[TicketCancelledDate]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[TicketClosedDate]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[TicketOpenDate]),'') 
							+'|'+ISNULL(convert(nvarchar(255),[TicketOpenedBy]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketResolvedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketFirstContactEmailDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketThirdContactDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketFourthContactDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[NotificationSentToTrainerDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[LeasingStatusDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[OnboardingDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TrackStatus]),'')
							+'|'+ISNULL(convert(nvarchar(255),[BusinessHoursId]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsInvalid]),'')
				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTicketOnboarding] where SKTicketOnboarding = -1)
	begin
		declare @Hash char(40) = ''

		--set identity_insert DWIRIS.DimAsset on
		begin try
			insert into DWIRIS.DimTicketOnboarding (
				    	[SKTicketOnboarding]
					   ,[ADLSBatchID]
					   ,[ADLSTimestamp]
					   ,[LZBatchID]
					   ,[DWBatchID]
					   ,[DWHash]
					   ,[KeyTicketOnboarding]
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
					   ,[OnboardingDateKey]
					   ,[OnboardingDate]
					   ,[TicketType]
					   ,[TrackStatus]
					   ,[Ticket Net Hrs]
					   ,[Ticket Calendar Hrs]
					   ,[Ticket Aging]
					   ,[Tickets Count]
					   ,[BusinessHoursId]
					   ,[IsInvalid]
			)
			values (
					-1					-- SKTicketOnboarding
				,	-1					-- ADLSBatchID
				,	'19000101'			-- ADLSTimestamp
				,	-1					-- LZBatchID
				,	@BatchID			-- DWBatchID
				,	@Hash				-- DWHash
				,	'N/A'				--[KeyTicketOnboarding]
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
				,	19000101			--[OnboardingDateKey]
				,	'19000101'			--[OnboardingDate]
				,	'N/A'				--[TicketType]
				,	'N/A'				--[TrackStatus]
				,	0					--[Ticket Net Hrs]
				,	0					--[Ticket Calendar Hrs]
				,	0					--[Ticket Aging]
				,	0					--[Tickets Count]
				,  NULL					--[BusinessHoursId]
				,	0					--[IsInvalid]
			)
		end try
		begin catch
		end catch

	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTicketOnboarding]
		set
		     [ADLSBatchID] = src.[ADLSBatchID]
			,[ADLSTimestamp] = src.[ADLSTimestamp]
			,[LZBatchID] = src.[LZBatchID]
			,[DWBatchID] = @BatchID
			,[DWHash] = src.[DWHash]
			,[KeyTicketOnboarding] = src.[KeyTicketOnboarding]
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
			,[OnboardingDateKey] = src.[OnboardingDateKey]
			,[OnboardingDate] = src.[OnboardingDate]
			,[TicketType] = src.[TicketType]
			,[TrackStatus] = src.[TrackStatus]
			,[Ticket Net Hrs] = src.[Ticket Net Hrs]
			,[Ticket Calendar Hrs] = src.[Ticket Calendar Hrs]
			,[Ticket Aging] = src.[Ticket Aging]
			,[Tickets Count] = src.[Tickets Count]
			,[BusinessHoursId] = src.[BusinessHoursId]
			,[IsInvalid] = src.[IsInvalid]

	from #TempDimTicketOnboarding src
	where [DWIRIS].[DimTicketOnboarding].SKTicketOnboarding	=	src.SKTicketOnboarding
		and [DWIRIS].[DimTicketOnboarding].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTicketOnboarding_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketOnboarding_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTicketOnboarding] (
						[SKTicketOnboarding]
				       ,[ADLSBatchID]
					   ,[ADLSTimestamp]
					   ,[LZBatchID]
					   ,[DWBatchID]
					   ,[DWHash]
					   ,[KeyTicketOnboarding]
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
					   ,[OnboardingDateKey]
					   ,[OnboardingDate]
					   ,[TicketType]
					   ,[TrackStatus]
					   ,[Ticket Net Hrs]
					   ,[Ticket Calendar Hrs]
					   ,[Ticket Aging]
					   ,[Tickets Count]
					   ,[BusinessHoursId]
					   ,[IsInvalid]
)
	select 
					[SKTicketOnboarding]
				   ,[ADLSBatchID]
				   ,[ADLSTimestamp]
				   ,[LZBatchID]
				   ,@BatchID
				   ,[DWHash]
				   ,[KeyTicketOnboarding]
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
				   ,[OnboardingDateKey]
				   ,[OnboardingDate]
				   ,[TicketType]
				   ,[TrackStatus]
				   ,[Ticket Net Hrs]
				   ,[Ticket Calendar Hrs]
				   ,[Ticket Aging]
				   ,[Tickets Count]
				   ,[BusinessHoursId]
				   ,[IsInvalid]

	from #TempDimTicketOnboarding src
	where not exists(
		select dst.SKTicketOnboarding 
		from DWIRIS.DimTicketOnboarding dst 
		where dst.SKTicketOnboarding = src.SKTicketOnboarding
	)
	option (label = 'DWIRIS.DimTicketOnboarding_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.DimTicketOnboarding_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure