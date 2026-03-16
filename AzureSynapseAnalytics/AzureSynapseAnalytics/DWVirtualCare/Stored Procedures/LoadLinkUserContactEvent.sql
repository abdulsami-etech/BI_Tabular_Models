CREATE PROC [DWVirtualCare].[LoadLinkUserContactEvent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [int] AS
BEGIN
	set xact_abort on

	declare
		@RowsInserted	int = 0,
		@RowsUpdated	int = 0,
		@dt datetime=getdate()

	Select @IsForceFullLoad  = COALESCE(@IsForceFullLoad, 0)
	
	/*#Enrollment*/
	BEGIN

		if object_id('tempdb..#Enrollment') is not null
		drop table #Enrollment

		Create table #Enrollment
			(
				ClinId nvarchar(50),EnrollDate date,SKContact int
			)
			with (distribution = round_robin, heap)

		INSERT #Enrollment (ClinID,EnrollDate,SKContact)
		Select top 1 with TIES T.[user_name],T.create_date,c.SKContact
		from (
			SELECT
				pd.clinID as user_name,
				pd.EnrollmentDate as create_date
			FROM DW.[FactProductEnrollmentIDS] pd
			where pd.productIDS='virtualCare'

			UNION ALL

			SELECT
				CASE WHEN CHARINDEX ('$',vc.clin_id)>0 THEN SUBSTRING(vc.clin_id,0,CHARINDEX ('$',vc.clin_id))
						ELSE vc.clin_id
					END as [user_name],
				TRY_CONVERT(date,vc.[created_at]) as create_date
			FROM SrcEventHub.VirtualCare vc
			WHERE vc.event_name IN ('terms_and_condistions_popup','terms_and_conditions_popup') and vc.event_category='accept' and vc.event_action='click'
			and TRY_CONVERT(date,vc.[created_at]) IS NOT NULL

			UNION ALL

			SELECT
				CASE WHEN CHARINDEX ('$',vc.clin_id)>0 THEN SUBSTRING(vc.clin_id,0,CHARINDEX ('$',vc.clin_id))
					ELSE vc.clin_id
				END as [user_name],
				TRY_CONVERT(date,vc.[created_at]) as create_date
			FROM [SrcKafkaHeroku].[remote_care_web_event] vc
			where	vc.event_name IN ('terms_and_condistions_popup','terms_and_conditions_popup')
				and vc.event_category='accept'
				and vc.event_action='click'
                and TRY_CONVERT(date,vc.[created_at]) IS NOT NULL
			) as T
		JOIN DW.DimContact c on c.ClinID=T.[user_name]
		Order by ROW_NUMBER() OVER (Partition by T.[user_name] order by T.create_date ASC)

	END
	
	/*T&C*/
	BEGIN

		if object_id('tempdb..#TCResult') is not null
		drop table #TCResult

		Create table #TCResult (Id int,[status] int,created_at datetime, [username] nvarchar(250)) with (distribution = round_robin, heap) 

		INSERT #TCResult (Id ,[status] ,created_at ,[username] )
		SELECT
				[id]						as Id,
				[status]					as [status],
				TRY_CONVERT(date,[created_at])	as [created_at],
				REPLACE(REPLACE([username],'["',''),'"]','')
			FROM [SrcPWA].[program_enrollments]
			WHERE program_id in ( 285,331,332,335,336,337,338,385,386)
			and TRY_CONVERT(date,[created_at]) IS NOT NULL
			and TRY_CONVERT(date,[updated_at]) IS NOT NULL

		INSERT #TCResult (Id ,[status] ,created_at ,[username] )
			SELECT 
				-1 as Id,
				1 as [status],
				TRY_CONVERT(date,[created_at]) as [created_at],
				clin_id as [username]
			FROM SrcEventHub.VirtualCare 
			WHERE	event_name  IN ('terms_and_condistions_popup','terms_and_conditions_popup') 
				and event_category='accept' 
				and event_action='click'
				and TRY_CONVERT(date,[created_at]) IS NOT NULL

		INSERT #TCResult (Id ,[status] ,created_at , [username] )
			SELECT 
				-1 as Id,
				1 as [status],
				TRY_CONVERT(date,[created_at]) as [created_at],
				clin_id as [username]
			FROM [SrcKafkaHeroku].[remote_care_web_event]
			WHERE	event_name  IN ('terms_and_condistions_popup','terms_and_conditions_popup')
				and event_category='accept'
				and event_action='click'
				and TRY_CONVERT(date,[created_at]) IS NOT NULL
		if object_id('tempdb..#TC') is not null
		drop table #TC

		CREATE TABLE #TC (Clinid nvarchar(50),TCDate Date,SKContact int) with (distribution = round_robin, heap) 
		INSERT #TC (Clinid ,TCDate,SKContact )
		SELECT
			c.ClinID,
			MIN(TRY_CONVERT(date,r.[created_at]))			as [created_at],
			c.SKContact
		FROM #TCResult r
		JOIN DW.DimContact c on c.ClinID=r.username
		WHERE r.status=1
		and TRY_CONVERT(date,r.[created_at]) IS NOT NULL
		GROUP BY c.ClinID,c.SKContact
	END

	/* EVENTS */


	if object_id('tempdb..#VirtualCareEvent') is not null
	drop table #VirtualCareEvent

	CREATE TABLE #VirtualCareEvent (
		SKContact 	INT				NOT NULL,
		SKUser 		INT				NOT NULL,
		SKEvent 	INT				NOT NULL,
		EventDate 	Date			NOT NULL
	)
	with (distribution = round_robin, heap) 

	/*Dr invites a patient*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT hu.SKUser,hu.SKContact, de.SKEvent,TRY_CONVERT(date,LEFT(Inv.created_date,10))
	from DWVirtualCare.HubUser hu
	JOIN DWVirtualCare.DictEvent de on de.EventName='Invite'
	JOIN (
		Select patient_id, created_date as created_date
		from SrcEventHub.VirtualCare 
		where app_name='notification-api' and notification_type='invite'

		UNION

		SELECT patient_id, created_date 
		from [SrcKafkaHeroku].[notifications_event]
		where app_name='notification-api' and notification_type='invite'
	) as Inv on Inv.patient_id=hu.KeyUser
	where TRY_CONVERT(date,LEFT(Inv.created_date,10)) IS NOT NULL

	/*Patient installed App and accepted T&C*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT hu.SKUser,hu.SKContact, de.SKEvent,TRY_CONVERT(date,LEFT(Acc.created_date,10))
	from DWVirtualCare.HubUser hu
	JOIN DWVirtualCare.DictEvent de on de.EventName='Accepted'
	JOIN (
		Select uuid as patient_id , COALESCE(created_at,created_date) as created_date
		from SrcEventHub.VirtualCare 
		where COALESCE(app_name,'user-profile-api') IN ('user-profile-api','NULL') 
		and remote_care_accept_terms IN ('accept t & c','a & t')

		UNION

		Select
			patient.uuid as patient_id,
			patient.created_date
		from [SrcKafkaHeroku].[user_profile_event] patient
		where   patient.app_name = 'user-profile-api'
		and patient.remote_care_accept_terms IN ('accept t & c','a & t')

	) as Acc on Acc.patient_id=hu.KeyUser
	where TRY_CONVERT(date,LEFT(Acc.created_date,10)) IS NOT NULL

	/*Patient shares photos with the Dr*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT hu.SKUser,hu.SKContact, de.SKEvent,TRY_CONVERT(date,LEFT(Sha.created_date,10))
	from DWVirtualCare.HubUser hu
	JOIN DWVirtualCare.DictEvent de on de.EventName='Shared'
	JOIN (
		Select patient_id, created_date
		from SrcEventHub.VirtualCare 
		where app_name='events-api' and event_type='share_with_doctor'

		UNION

		SELECT patient_id, created_date
		from [SrcKafkaHeroku].[events_api_event]
		where app_name='events-api' and event_type='share_with_doctor'

	) as Sha on Sha.patient_id=hu.KeyUser
	WHERE TRY_CONVERT(date,LEFT(Sha.created_date,10)) IS NOT NULL

	/*Patient recieved a reiew from the Dr*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT hu.SKUser,hu.SKContact, de.SKEvent,TRY_CONVERT(date,LEFT(rec.created_date,10))
	from DWVirtualCare.HubUser hu
	JOIN DWVirtualCare.DictEvent de on de.EventName='Received'
	JOIN (
		Select patient_id, created_date
		from SrcEventHub.VirtualCare 
		where app_name='events-api' and event_type IN ('on_track','send_instructions')

		UNION

		Select patient_id, created_date
		from [SrcKafkaHeroku].[events_api_event]
		where app_name='events-api' and event_type IN ('on_track','send_instructions')

	) as rec on rec.patient_id=hu.KeyUser
	WHERE TRY_CONVERT(date,LEFT(rec.created_date,10)) IS NOT NULL

	/*
	Patient received appointment, but only if patient is a Virtual Care patient
	This one goes before Invites from User API, because invited patient could be not a Virtual Care patient
	*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT hu.SKUser,hu.SKContact, de.SKEvent,TRY_CONVERT(date,LEFT(rec.created_date,10))
	from DWVirtualCare.HubUser hu
	JOIN DWVirtualCare.DictEvent de on de.EventName='Received'
	JOIN (
		Select patient_id, created_date
		from SrcEventHub.VirtualCare 
		where app_name='events-api' and event_type IN ('appointment','virtual_appointment')

		UNION 

		Select patient_id, created_date
		from [SrcKafkaHeroku].[events_api_event]
		where app_name='events-api' and event_type IN ('appointment','virtual_appointment')
	) as rec on rec.patient_id=hu.KeyUser
	JOIN #VirtualCareEvent vce on vce.SKUser=hu.SKUser
		and vce.SKEvent in (3/*Shared*/)/*Patient has shared*/
	where TRY_CONVERT(date,LEFT(rec.created_date,10)) IS NOT NULL

	/*
		Invites from User API
	*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT hu.SKUser,hu.SKContact, de.SKEvent,TRY_CONVERT(date,LEFT(Inv.created_date,10))
	from DWVirtualCare.HubUser hu
	JOIN DWVirtualCare.DictEvent de on de.EventName='Invite'
	JOIN (
		Select uuid as patient_id , COALESCE(created_at,created_date) as created_date
		from SrcEventHub.VirtualCare 
		where COALESCE(app_name,'user-profile-api') IN ('user-profile-api','NULL') and remote_care_invite_status IN ('accepted','invited')

		UNION 
		
		Select uuid as patient_id, created_date
		from [SrcKafkaHeroku].[user_profile_event]
		where app_name='user-profile-api' and remote_care_invite_status IN ('accepted','invited')

	) as Inv on Inv.patient_id=hu.KeyUser
	where TRY_CONVERT(date,LEFT(Inv.created_date,10)) IS NOT NULL

	/*
		fix missing invites
	*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT Other.SKUser,Other.SKContact, 1 /*Invite*/,MIN(Other.EventDate)
	FROM  #VirtualCareEvent Other 
	LEFT JOIN #VirtualCareEvent Invite 
		on Invite.SKEvent=1 /*Invite*/ and Other.SKUser=Invite.SKUser and Other.SKContact=Invite.SKContact
	where Other.SKEvent in (2/*Accepted*/,3/*Shared*/,4/*Received*/)
	and invite.SKUser is null
	group by Other.SKUser,Other.SKContact

	/*
		fix invites later then any other action
	*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT Other.SKUser,Other.SKContact, 1 /*Invite*/,MIN(Other.EventDate)
	FROM  #VirtualCareEvent Other 
	 JOIN #VirtualCareEvent Invite 
		on Invite.SKEvent=1 /*Invite*/ and Other.SKUser=Invite.SKUser and Other.SKContact=Invite.SKContact
	where Other.SKEvent in (2/*Accepted*/,3/*Shared*/,4/*Received*/)
	and Other.EventDate<Invite.EventDate
	group by Other.SKUser,Other.SKContact

	/*
		fix missing Accepted
	*/

	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT Other.SKUser,Other.SKContact, 2 /*Accepted*/,MIN(Other.EventDate)
	FROM  #VirtualCareEvent Other 
	LEFT JOIN #VirtualCareEvent Accepted 
		on Accepted.SKEvent=2 /*Accepted*/ and Other.SKUser=Accepted.SKUser and Other.SKContact=Accepted.SKContact
	where Other.SKEvent in (3/*Shared*/,4/*Received*/)
	and Accepted.SKUser is null
	group by Other.SKUser,Other.SKContact

	/*
		fix Accepted later then any other action
	*/

	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT Other.SKUser,Other.SKContact, 2 /*Accepted*/,MIN(Other.EventDate)
	FROM  #VirtualCareEvent Other 
	 JOIN #VirtualCareEvent Accepted 
		on Accepted.SKEvent=2 /*Accepted*/ and Other.SKUser=Accepted.SKUser and Other.SKContact=Accepted.SKContact
	where Other.SKEvent in (3/*Shared*/,4/*Received*/)
	and Other.EventDate<Accepted.EventDate
	group by Other.SKUser,Other.SKContact

	/*
	fix missing shared
	*/

	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	SELECT Other.SKUser,Other.SKContact, 3/*Shared*/,MIN(Other.EventDate)
	FROM  #VirtualCareEvent Other 
	LEFT JOIN #VirtualCareEvent Shared 
		on Shared.SKEvent=3/*Shared*/ and Other.SKUser=Shared.SKUser and Other.SKContact=Shared.SKContact
	where Other.SKEvent in (4/*Received*/)
	and Shared.SKUser is null
	group by Other.SKUser,Other.SKContact


	/*
	Enrollment
	*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	Select -1,SKContact,5 /*Dr Enroll*/,EnrollDate
	from #Enrollment
	where EnrollDate IS NOT NULL



	/*missing enrollment*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	Select -1,Other.SKContact,5 /*Dr Enroll*/,MIN(Other.EventDate)
	from #VirtualCareEvent Other
	LEFT JOIN #VirtualCareEvent Enroll on Enroll.SKEvent=5 /*Dr Enroll*/ and Other.SKContact=Enroll.SKContact
	where Other.SKEvent in (1/*Invite*/,2/*Accepted*/,3/*Shared*/,4/*Received*/)
	and Enroll.SKContact is null
	group by Other.SKContact

	/*Enrollment later then other action*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	Select -1,Other.SKContact,5 /*Dr Enroll*/,MIN(Other.EventDate)
	from #VirtualCareEvent Other
	JOIN #VirtualCareEvent Enroll on Enroll.SKEvent=5 /*Dr Enroll*/  and Other.SKContact=Enroll.SKContact
	where  Other.SKEvent in (1/*Invite*/,2/*Accepted*/,3/*Shared*/,4/*Received*/)
	and Enroll.EventDate>Other.EventDate
	group by Other.SKContact

	/*Insert Dr Accepted T&C*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	Select -1,SKContact,6 /*Dr T&C*/,TCDate
	from #TC

	/* Missing T&C*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	Select -1,Other.SKContact,6 /*Dr T&C*/,MIN(Other.EventDate)
	from #VirtualCareEvent Other
	LEFT JOIN #VirtualCareEvent TC on TC.SKEvent=6 /*Dr T&C*/ and Other.SKContact=TC.SKContact
	where Other.SKEvent in (1/*Invite*/,2/*Accepted*/,3/*Shared*/,4/*Received*/)
	and TC.SKContact is null
	group by Other.SKContact

	/*T&C later then other action*/
	INSERT #VirtualCareEvent (SKUser,SKContact, SKEvent, EventDate)
	Select -1,Other.SKContact,6 /*Dr T&C*/,MIN(Other.EventDate)
	from #VirtualCareEvent Other
	JOIN #VirtualCareEvent TC on TC.SKEvent=6 /*Dr T&C*/ and Other.SKContact=TC.SKContact
	where Other.SKEvent in (1/*Invite*/,2/*Accepted*/,3/*Shared*/,4/*Received*/)
	and TC.EventDate>Other.EventDate
	group by Other.SKContact

	if object_id ('DWVirtualCare.LinkUserContactEventNew', 'U') is not null
	drop table DWVirtualCare.LinkUserContactEventNew

	create table DWVirtualCare.LinkUserContactEventNew with (heap, distribution = replicate) as 
	SELECT
		VC.SKUser,
		VC.SKContact,
		VC.SKEvent,
		VC.EventDate,
		@BatchID as DWBatchID,
		@dt as InsertDateTime,
		COALESCE(g.SecRegion,'Unassigned') as RegionGroup
	FROM #VirtualCareEvent VC
	JOIN DW.DimContact DC ON DC.SKContact=VC.SKContact
	LEFT JOIN Custom.GeographyHierarchy g on dc.MailingCountryCode = g.CountryCode
	GROUP BY
		VC.SKUser,
		VC.SKContact,
		VC.SKEvent,
		VC.EventDate,
		COALESCE(g.SecRegion,'Unassigned')

	if object_id ('DWVirtualCare.LinkUserContactEvent', 'U') is not null
	begin
		if object_id ('DWVirtualCare.LinkUserContactEventPrevious', 'U') is not null
			drop table DWVirtualCare.LinkUserContactEventPrevious

		rename object DWVirtualCare.LinkUserContactEvent to LinkUserContactEventPrevious
		rename object DWVirtualCare.LinkUserContactEventNew to LinkUserContactEvent
		drop table DWVirtualCare.LinkUserContactEventPrevious
	end
	else
	begin
		rename object DWVirtualCare.LinkUserContactEventNew to LinkUserContactEvent
	end

	alter table DWVirtualCare.LinkUserContactEvent add constraint PK_DWVirtualCareLinkUserContactEvent primary key nonclustered (SKContact,SKUser,SKEvent,EventDate) not enforced
	create clustered index IX_CL_DWVirtualCareLinkUserContactEvent on DWVirtualCare.LinkUserContactEvent (SKContact,SKUser,SKEvent,EventDate)

	select @RowsInserted = count(*) 
	from DWVirtualCare.LinkUserContactEvent

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated 


END