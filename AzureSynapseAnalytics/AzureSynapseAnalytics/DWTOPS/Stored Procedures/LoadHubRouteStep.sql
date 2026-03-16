CREATE PROC [DWTOPS].[LoadHubRouteStep] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubRouteStep
		where SKRouteStep = -1
	)
	begin
		set identity_insert DWTOPS.HubRouteStep on
		begin try
			insert into DWTOPS.HubRouteStep (
					SKRouteStep
				,	KeyRouteStep
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
			set identity_insert DWTOPS.HubRouteStep off;
			throw
		end catch
		set identity_insert DWTOPS.HubRouteStep off

	end

	insert into DWTOPS.HubRouteStep (
			KeyRouteStep
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct 
			t.KeyRouteStep
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from (
		select route_step_key as KeyRouteStep
		from SrcMESCorp.ROUTE_STEP
		union all
		select route_step_key as KeyRouteStep
		from SrcMESCorp.TRACKED_OBJECT_HISTORY
		where route_step_key is not null
		union all
		select route_step_key as KeyRouteStep
		from SrcMESCorp.tracked_object_status
		where route_step_key is not null
	) t
	where	not exists (
				select *
				from DWTOPS.HubRouteStep h
				where h.KeyRouteStep = t.KeyRouteStep
			)
	option (label = 'DWTOPS.LoadHubRouteStep');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubRouteStep', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
