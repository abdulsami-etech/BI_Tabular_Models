CREATE PROC [DWMyInvisalignApp].[LoadHubAPIUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN

	declare
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element

	if not exists (
		select *
		from DWMyInvisalignApp.HubAPIUser
		where SKAPIUser = -1
	)
	begin
		set identity_insert DWMyInvisalignApp.HubAPIUser on
		begin try
			insert into DWMyInvisalignApp.HubAPIUser (
					   SKAPIUser
					 , KeyAPIUser
					 , DWBatchID
					 , InsertDateTime
			)
			values (
					-1
				,	'-1'
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWMyInvisalignApp.HubAPIUser off;
			throw
		end catch
		set identity_insert DWMyInvisalignApp.HubAPIUser off
	end   --if statement



	-- Pull all business keys to temp table

	if object_id('tempdb..#TempHubAPIUser') is not null
		drop table #TempHubAPIUser

	create table #TempHubAPIUser with (distribution = round_robin, heap) AS
    Select
		s.uuid AS KeyAPIUser
	from SrcAvro.UserProfileAPI s
	where s.uuid IS NOT NULL
	and s.ADLSTimestamp>=@LastSuccessfullDWTimestamp
	group by s.uuid
	UNION
    Select s.uuid
    from SrcKafkaHeroku.user_profile_event s
    where s.uuid IS NOT NULL
      and app_name='user-profile-api'
      and s.ADLSTimestamp >= @LastSuccessfullDWTimestamp
    group by s.uuid

	--insert new keys to hub
	insert into DWMyInvisalignApp.HubAPIUser
	(
        KeyAPIUser
		, DWBatchID
		, InsertDateTime
	)
	select
        T.KeyAPIUser
		, @BatchID
		, @dt
	from #TempHubAPIUser  T
	LEFT JOIN DWMyInvisalignApp.HubAPIUser H on H.KeyAPIUser=T.KeyAPIUser
	where H.KeyAPIUser IS NULL
	option (label = 'DWMyInvisalignApp.LoadHubAPIUser');

	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadHubAPIUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end