CREATE PROC [DWTOPS].[LoadHubOperation] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubOperation
		where SKOperation = -1
	)
	begin
		set identity_insert DWTOPS.HubOperation on
		begin try
			insert into DWTOPS.HubOperation (
					SKOperation
				,	KeyOperation
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
			set identity_insert DWTOPS.HubOperation off;
			throw
		end catch
		set identity_insert DWTOPS.HubOperation off

	end

	insert into DWTOPS.HubOperation (
			KeyOperation
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct t.op_key
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from (
		select op_key
		from SrcMESCorp.OPERATION
		union all
		select op_key
		from SrcMESCorp.tracked_object_status
		where op_key is not null
		union all
		select op_key
		from SrcMESCorp.TRACKED_OBJECT_HISTORY 
		where op_key is not null
	) t
	where	not exists (
				select *
				from DWTOPS.HubOperation h
				where h.KeyOperation = t.op_key
			)
	option (label = 'DWTOPS.LoadHubOperation');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubOperation', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
