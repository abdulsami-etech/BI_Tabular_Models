CREATE PROC [DWTOPS].[LoadHubUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubUser
		where SKUser = -1
	)
	begin
		set identity_insert DWTOPS.HubUser on
		begin try
			insert into DWTOPS.HubUser (
					SKUser
				,	KeyUser
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	'N/A'
				,	@CurrentDate
			)
		end try
		begin catch
			set identity_insert DWTOPS.HubUser off;
			throw
		end catch
		set identity_insert DWTOPS.HubUser off

	end

	insert into DWTOPS.HubUser (
			KeyUser
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct
			t.KeyUser
		,	@BatchId
		,	'MESCorp'
		,	@CurrentDate
	from (
		select convert(varchar(64), user_name) as KeyUser
		from SrcMESCorp.APP_USER
		where Status = 'Normal'
		union all
		select  convert(varchar(64), complete_user_name) 
		from SrcMESCorp.TRACKED_OBJECT_HISTORY
		where complete_user_name is not null
		union all
		select  convert(varchar(64), start_user_name) 
		from SrcMESCorp.TRACKED_OBJECT_HISTORY
		where start_user_name is not null
	) t
	where	not exists (
				select *
				from DWTOPS.HubUser h
				where h.KeyUser = t.KeyUser
			)
	option (label = 'DWTOPS.LoadHubUser');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
