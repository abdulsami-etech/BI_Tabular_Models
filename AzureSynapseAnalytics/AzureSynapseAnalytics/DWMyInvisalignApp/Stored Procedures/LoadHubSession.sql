CREATE PROC [DWMyInvisalignApp].[LoadHubSession] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN

	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWMyInvisalignApp.HubSession
		where SKSession = -1
	)
	begin
		set identity_insert DWMyInvisalignApp.HubSession on
		begin try
			insert into DWMyInvisalignApp.HubSession (
					   SKSession
					 , KeyTrace
					 , KeyUser
					 , DWBatchID
					 , InsertDateTime
			)
			values (
					-1
				,	-1
				,	'-1'
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWMyInvisalignApp.HubSession off;
			throw
		end catch
		set identity_insert DWMyInvisalignApp.HubSession off
	end   --if statement

	   
		
	-- Pull all business keys to temp table

	if object_id('tempdb..#TempHubSession') is not null
		drop table #TempHubSession
		
	create table #TempHubSession
		(
			KeyTrace			int					NOT NULL,
			KeyUser				nvarchar(50)		NOT NULL
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubSession (KeyTrace,KeyUser)
	Select
		s.event_params_ga_session_id,
		s.user_pseudo_id
	from SrcGoogleBigQuery.MyInvisalignAppOther s
	where s.event_name='session_start'
	and s.event_params_ga_session_id IS NOT NULL
	and s.user_pseudo_id IS NOT NULL
	and s.ADLSTimestamp>=@LastSuccessfullDWTimestamp
	group by s.event_params_ga_session_id,	s.user_pseudo_id

	--insert new keys to hub
	insert into DWMyInvisalignApp.HubSession
	(
		KeyTrace
		,KeyUser
		, DWBatchID
		, InsertDateTime
	)
	select 
		T.KeyTrace
		,T.KeyUser
		, @BatchID
		, @dt 
	from #TempHubSession  T
	LEFT JOIN DWMyInvisalignApp.HubSession H on H.KeyTrace=T.KeyTrace and  H.KeyUser=T.KeyUser
	where H.KeyTrace IS NULL
	option (label = 'DWMyInvisalignApp.LoadHubSession');

	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadHubSession', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end