CREATE PROC [DW].[LoadFactTrainingEvents]  @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit]AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted			int = 0
		,	@RowsUpdated			int = 0
		,	@IsFullLoad				bit = 0
		,	@SQL					varchar(max)
		,	@LastDWBatchIDDimOrder	int
		,	@CurrentDate			datetime2(0) = getdate()

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if not exists (select * from DW.FactTrainingEvents)
		set @IsFullLoad = 1

	if object_id('DW.Temp_FactTrainingEvents') is not null
		drop table DW.Temp_FactTrainingEvents

	set @SQL = 'create table DW.Temp_FactTrainingEvents
	(
		[Id] 							[NVARCHAR](18) 		NOT NULL,
		[DWBatchID] 					[INT] 				NOT NULL,
		[DWHash] 						[CHAR] (40)			NOT NULL,
		[EventID] 						[NCHAR](18) 		NOT NULL,
		[EventName] 					[NVARCHAR](60) 		NULL,
		[EventCity] 					[NVARCHAR](80) 		NULL,
		[EventState] 					[NVARCHAR](80) 		NULL,
		[EventCountry] 					[NVARCHAR](40) 		NULL,
		[SKTrainingEventType] 			[INT] 				NOT NULL,
		-- [CustomerKey] 					[INT] 				NOT NULL,
		[SKAccount] 					[INT] 				NOT NULL,
		[SKContact] 					[INT] 				NOT NULL,
		[EventDate] 					[DATE]				NOT NULL,
		[EventLocationID] 				[NVARCHAR](18) 		NULL,
		[SpeakerName] 					[NVARCHAR](60) 		NULL,
		[CEHours] 						[INT] 				NULL,
		[EventLocationName] 			[NVARCHAR](50) 		NULL,
		[TuitionFee] 					[DECIMAL](15, 2) 	NULL,
		[IsPointsAccrued] 				[NVARCHAR](3) 		NULL,
		[IsPromotionEligible] 			[NVARCHAR](3) 		NULL,
		[IsAttended] 					[INT] 				NULL,
		[LastModifiedDate] 				[DATETIME2](7) 		NOT NULL,
		[StudyClubCode] 				[NVARCHAR](30) 		NULL,
		[CreatedDate] 					[DATETIME2](0)		NOT NULL,
		[ModifiedDate] 					[DATETIME2](0)		NOT NULL
	)'

	if @IsFullLoad = 0
	begin
		set @SQL += 'with (distribution = round_robin, heap)'
	end 
	else 
	begin
		set @SQL += 'with (distribution = hash(Id), clustered columnstore index)'
	end

	exec (@SQL)

	insert into DW.Temp_FactTrainingEvents (
		Id  					
	,	DWBatchID  			
	,	DWHash  				
	,	EventID  				
	,	EventName  			
	,	EventCity  			
	,	EventState  			
	,	EventCountry  			
	,	SKTrainingEventType  	
	-- ,	CustomerKey 
	,	SKAccount
	,	SKContact
	,	EventDate  			
	,	EventLocationID  		
	,	SpeakerName  			
	,	CEHours  				
	,	EventLocationName  	
	,	TuitionFee  			
	,	IsPointsAccrued  		
	,	IsPromotionEligible  	
	,	IsAttended  			
	,	LastModifiedDate  		
	,	StudyClubCode  		
	,	CreatedDate  			
	,	ModifiedDate 				
	)
	select	convert(nvarchar(18), t.Id) as Id
	,	@BatchID as DWBatchID
	,	convert(char(40), '') as DWHash
	,	t.Event__c as EventID
	,	cast(isnull(t.Event_Name__c, t.name) as nvarchar(60)) as EventName
	-- ,	c.Clinician_ID__c as CLINID
	-- ,	c.Contact_ID__c as ContactNumber
	-- ,	cast(c.Account_Number__c as nvarchar(40)) as AccountNumber
	,	coalesce(sc.Event_City__c, t.City__c, 'Unknown')  as EventCity
	,	convert(nvarchar(80), coalesce(sc.Event_State__c, t.State__C, 'Unknown')) as EventState
	,	coalesce(t.Country__c, 'Unknown') as EventCountry
	,	coalesce(te.SKTrainingEventType, -1) as SKTrainingEventType
	-- ,	convert(nvarchar(18), t.Event_Type__c) as TrainingEventTypeId
	-- ,	CustomerKey
	,	ha.SKAccount
	,	hc.SKContact
	,	cast(t.Event_Date__c as date) as EventDate
	,	convert(nvarchar(18), t.Training_Location__c) as EventLocationID	
	,	cast(t.Speaker__c as nvarchar(60)) as SpeakerName	
	,	cast(t.CE_Hours__c as int) as CEHours
	,	convert(nvarchar(50), 
			coalesce(
					sc.Venue_Address__c + N', ' + sc.Event_City__c + ', ' + sc.Event_State__c
				,	t.Location_Description__c
				,	N'Unknown Event Location'
			)
		) as EventLocationName
	,	cast(t.Tuition_Fee__c as decimal(15,2)) as TuitionFee
	,	convert(nvarchar(3), case Is_Points_Accrued__c when 'false' then 'No' else 'Yes' end ) as IsPointsAccrued
	,	convert(nvarchar(3), case Promotion_Eligibility__c when 'false' then 'No' else 'Yes' end ) as IsPromotionEligible
	,   convert(int, Case Training_Status__C when 'Attended' then 1 else 0 end ) as IsAttended
	,	t.LastModifiedDate as LastModifiedDate
	,	isnull(sc.Study_Club_Code__c, N'Unknown') as StudyClubCode
	,	@CurrentDate as InsertDate
	,	@CurrentDate as ModifiedDate
from SrcSFDC.Training_Records__c t 
inner join SrcSFDC.Contact c on t.ContactID__c = c.Id
inner join DW.HubContact hc on c.Id = hc.KeyContact
inner join SrcSFDC.account a on c.AccountId = a.Id
inner join DW.HubAccount ha on a.Id = ha.KeyAccount
left join DW.DimTrainingEventTypes te on convert(nvarchar(18), t.Event_Type__c) = te.TrainingEventTypeCode
left join SrcSFDC.Study_club__c sc on sc.id = t.Study_Club__c
where t.Event_Date__c is not null 
	and t.Event__c is not null
	and t.LastModifiedDate >= '20150101'
	and (
			@IsFullLoad = 1
			or t.LastModifiedDate >= isnull(@LastSuccessfullDWTimestamp,'1900-01-01')
		)

	update DW.Temp_FactTrainingEvents 
		set	DWHash =
				convert(char(40),
					hashbytes('SHA1',
								 isnull(convert(nvarchar, EventID), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventName), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventCity), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventState), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventCountry), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SKTrainingEventType), N'N/A')
						-- + N'|' + isnull(convert(nvarchar, CustomerKey), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SKAccount), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SKContact), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventLocationID), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SpeakerName), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CEHours), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventLocationName), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TuitionFee), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsPointsAccrued), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsPromotionEligible), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsAttended), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastModifiedDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, StudyClubCode), N'N/A')
					)
				, 2)

	if @IsFullLoad = 0
	begin
		update DW.FactTrainingEvents 
			set	DWBatchID = src.DWBatchID
			,	DWHash = src.DWHash
			,	EventID = src.EventID
			,	EventName = src.EventName
			,	EventCity = src.EventCity
			,	EventState = src.EventState
			,	EventCountry = src.EventCountry
			,	SKTrainingEventType = src.SKTrainingEventType
			-- ,	CustomerKey = src.CustomerKey
			,	SKAccount = src.SKAccount
			,	SKContact = src.SKContact
			,	EventDate = src.EventDate
			,	EventLocationID = src.EventLocationID
			,	SpeakerName = src.SpeakerName
			,	CEHours = src.CEHours
			,	EventLocationName = src.EventLocationName
			,	TuitionFee = src.TuitionFee
			,	IsPointsAccrued = src.IsPointsAccrued
			,	IsPromotionEligible = src.IsPromotionEligible
			,	IsAttended = src.IsAttended
			,	LastModifiedDate = src.LastModifiedDate
			,	StudyClubCode = src.StudyClubCode
			,	ModifiedDate = @CurrentDate
		from DW.Temp_FactTrainingEvents src
		where DW.FactTrainingEvents.Id = src.Id
			and DW.FactTrainingEvents.DWHash != src.DWHash
		option (label = 'DW.LoadFactTrainingEvents_Update');
	
		exec CTRL.GetLastRowCount @Label = 'DW.LoadFactTrainingEvents_Update', @rc = @RowsUpdated out

		insert into DW.FactTrainingEvents (
				 	Id  					
				,	DWBatchID  			
				,	DWHash  				
				,	EventID  				
				,	EventName  			
				,	EventCity  			
				,	EventState  			
				,	EventCountry  			
				,	SKTrainingEventType  	
				-- ,	CustomerKey  
				,	SKAccount
				,	SKContact
				,	EventDate  			
				,	EventLocationID  		
				,	SpeakerName  			
				,	CEHours  				
				,	EventLocationName  	
				,	TuitionFee  			
				,	IsPointsAccrued  		
				,	IsPromotionEligible  	
				,	IsAttended  			
				,	LastModifiedDate  		
				,	StudyClubCode  		
				,	CreatedDate  			
				,	ModifiedDate 		
		)
		select		src.Id  					
				,	src.DWBatchID  			
				,	src.DWHash  				
				,	src.EventID  				
				,	src.EventName  			
				,	src.EventCity  			
				,	src.EventState  			
				,	src.EventCountry  			
				,	src.SKTrainingEventType  	
				-- ,	src.CustomerKey
				,	src.SKAccount
				,	src.SKContact
				,	src.EventDate  			
				,	src.EventLocationID  		
				,	src.SpeakerName  			
				,	src.CEHours  				
				,	src.EventLocationName  	
				,	src.TuitionFee  			
				,	src.IsPointsAccrued  		
				,	src.IsPromotionEligible  	
				,	src.IsAttended  			
				,	src.LastModifiedDate  		
				,	src.StudyClubCode  		
				,	src.CreatedDate  			
				,	src.ModifiedDate 	
				-- ,	@CurrentDate
				-- ,	@CurrentDate
		from DW.Temp_FactTrainingEvents src
		where not exists (
			select * 
			from DW.FactTrainingEvents f
			where f.Id = src.Id
		)
		option (label = 'DW.LoadFactTrainingEvents_Insert');
	
		exec CTRL.GetLastRowCount @Label = 'DW.LoadFactTrainingEvents_Insert', @rc = @RowsInserted out
	end
	else
	begin --full load
		--we need to save initial CreatedDate dates
		if object_id('tempdb..#TempFactTrainingEventsDateCreated') is not null
			drop table #TempFactTrainingEventsDateCreated

		create table #TempFactTrainingEventsDateCreated (
				Id				nvarchar(18)		not null
			,	CreatedDate		datetime2(0)		not null
			,	constraint PK_Temp_FactTrainingEventsDateCreated primary key nonclustered (Id) not enforced
		) 
		with (distribution = round_robin, heap)
		
		insert into #TempFactTrainingEventsDateCreated (
				Id
			,	CreatedDate
		)
		select	Id
			,	CreatedDate
		from DW.FactTrainingEvents

		if object_id ('DW.FactTrainingEventsPrevious', 'U') is not null
			drop table DW.FactTrainingEventsPrevious

		rename object DW.FactTrainingEvents to FactTrainingEventsPrevious
		rename object DW.Temp_FactTrainingEvents to FactTrainingEvents
		drop table DW.FactTrainingEventsPrevious

		alter table DW.FactTrainingEvents add constraint PK_FactTrainingEvents primary key nonclustered (Id) not enforced

		--update initial CreatedDate dates
		update DW.FactTrainingEvents
			set CreatedDate = temp.CreatedDate
		from #TempFactTrainingEventsDateCreated temp
		where temp.Id = DW.FactTrainingEvents.Id

		select @RowsInserted = count(*)
		from DW.FactTrainingEvents
	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end