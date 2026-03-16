CREATE PROC [DWTOPS].[LoadHubEvent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubEvent
		where SKEvent = -1
	)
	begin
		set identity_insert DWTOPS.HubEvent on
		begin try
			insert into DWTOPS.HubEvent (
					SKEvent
				,	KeyEvent
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
			set identity_insert DWTOPS.HubEvent off;
			throw
		end catch
		set identity_insert DWTOPS.HubEvent off

	end

	insert into DWTOPS.HubEvent (
			KeyEvent
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct 
			convert(varchar(33), event_type) as KeyEvent
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcIDS.tblpuorderstatushistory t
	where t.event_type is not null
		and not exists (
				select *
				from DWTOPS.HubEvent h
				where h.KeyEvent = convert(varchar(33), event_type)
		)
	option (label = 'DWTOPS.LoadHubEvent');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubEvent', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
