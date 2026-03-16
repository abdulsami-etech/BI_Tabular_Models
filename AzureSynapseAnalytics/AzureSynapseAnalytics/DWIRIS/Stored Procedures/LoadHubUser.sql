CREATE PROC [DWIRIS].[LoadHubUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubUser
		where [SKUser] = -1
	)
	begin
		set identity_insert DWIRIS.HubUser on
		begin try
			insert into DWIRIS.HubUser (
					[SKUser]
				,	[KeyUser]
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	'N/A'
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubUser off;
			throw
		end catch
		set identity_insert DWIRIS.HubUser off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubUser') is not null
		drop table #TempHubUser
		
	create table #TempHubUser 
		(
			UserID nchar(18), 
			SourceSystemCode varchar(10)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubUser (UserID, SourceSystemCode)
	select UserID, 'MAT' as SourceSystemCode from 
		(select  convert(nchar(18),[CreatedByUserID]) as UserID from [SrcMAT].[svc_Ticket_History]
			UNION
		 select  convert(nchar(18),[UpdatedByUserID]) as UserID from [SrcMAT].[svc_Ticket_History]
		 	UNION
		 select  convert(nchar(18),[TicketAssignedToContactID]) as UserID from [SrcMAT].[svc_Ticket]) a

	insert into #TempHubUser (UserID, SourceSystemCode)
	select distinct [ID] as UserID, 'SFDC' as SourceSystemCode from [SrcSFDC].[User]
	UNION 
	select distinct [OwnerID] as UserID, 'SFDC' as SourceSystemCode from [SrcSFDC].[Case]
	UNION 
	select distinct g.[Id] as UserID, 'SFDC' as SourceSystemCode from [SrcSFDC].[Group] g
		inner join SrcSFDC.[Case] c
			on c.OwnerId = g.Id
		inner join SrcSFDC.RecordType rt
			on rt.Id=c.RecordTypeId
		where g.Type = 'Queue' and rt.Name in ('iTero RMA','iTero Support','iTero Complaint','iTero Onboarding','iTero Training')
		

	--insert new keys to hub
	insert into DWIRIS.HubUser
	(
		[KeyUser],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select UserId, @BatchID, SourceSystemCode, @dt from #TempHubUser where UserID not in (select KeyUser from DWIRIS.HubUser)
	option (label = 'DWIRIS.LoadHubUser');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END

