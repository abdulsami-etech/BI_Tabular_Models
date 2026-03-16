CREATE PROC [DWTOPS].[LoadHubRoute] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubRoute
		where SKRoute = -1
	)
	begin
		set identity_insert DWTOPS.HubRoute on
		begin try
			insert into DWTOPS.HubRoute (
					SKRoute
				,	KeyRoute
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	-1
				,	-1
				,	'N/A'
				,	@CurrentDate
			)
		end try
		begin catch
			set identity_insert DWTOPS.HubRoute off;
			throw
		end catch
		set identity_insert DWTOPS.HubRoute off

	end

	insert into DWTOPS.HubRoute (
			KeyRoute
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct
			t.KeyRoute
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from (
		select Route_Key as KeyRoute
		from SrcMESCorp.[ROUTE] 
		union all
		select route_key 
		from SrcMESCorp.tracked_object_status
		where route_key is not null
		union all
		select route_key 
		from SrcMESCorp.TRACKED_OBJECT_HISTORY
		where route_key is not null
	) t
	where	not exists (
				select *
				from DWTOPS.HubRoute h
				where h.KeyRoute = t.KeyRoute
			)
	option (label = 'DWTOPS.LoadHubRoute');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubRoute', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
