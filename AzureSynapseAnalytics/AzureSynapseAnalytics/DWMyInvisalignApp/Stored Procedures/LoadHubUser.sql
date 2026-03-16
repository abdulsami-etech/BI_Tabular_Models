CREATE PROC [DWMyInvisalignApp].[LoadHubUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN

	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWMyInvisalignApp.HubUser
		where SKUser = -1
	)
	begin
		set identity_insert DWMyInvisalignApp.HubUSer on
		begin try
			insert into DWMyInvisalignApp.HubUser (
					   SKUser
					 , KeyUser
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
			set identity_insert DWMyInvisalignApp.HubUser off;
			throw
		end catch
		set identity_insert DWMyInvisalignApp.HubUser off
	end   --if statement

	   
		
	-- Pull all business keys to temp table

	if object_id('tempdb..#TempHubUser') is not null
		drop table #TempHubUser
		
	create table #TempHubUser
		(
			KeyUser				nvarchar(100)		NOT NULL
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubUser (KeyUser)
    Select
		s.user_pseudo_id
	from SrcGoogleBigQuery.MyInvisalignAppOther s
	where s.user_pseudo_id IS NOT NULL
	and s.ADLSTimestamp>=@LastSuccessfullDWTimestamp
	group by s.user_pseudo_id

	--insert new keys to hub
	insert into DWMyInvisalignApp.HubUser
	(
        KeyUser
		, DWBatchID
		, InsertDateTime
	)
	select 
        T.KeyUser
		, @BatchID
		, @dt 
	from #TempHubUser  T
	LEFT JOIN DWMyInvisalignApp.HubUser H on H.KeyUser=T.KeyUser
	where H.KeyUser IS NULL
	option (label = 'DWMyInvisalignApp.LoadHubUser');

	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadHubUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end