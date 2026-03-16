CREATE PROC [DWTOPS].[LoadHubCompleteReason] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubCompleteReason
		where SKCompleteReason = -1
	)
	begin
		set identity_insert DWTOPS.HubCompleteReason on
		begin try
			insert into DWTOPS.HubCompleteReason (
					SKCompleteReason
				,	KeyCompleteReason
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
			set identity_insert DWTOPS.HubCompleteReason off;
			throw
		end catch
		set identity_insert DWTOPS.HubCompleteReason off

	end

	insert into DWTOPS.HubCompleteReason (
			KeyCompleteReason
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select	convert(varchar(64), t.Complete_Reason)
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcMESCorp.TRACKED_OBJECT_HISTORY t
	where t.Complete_Reason is not null
		and not exists (
			select *
			from DWTOPS.HubCompleteReason h
			where h.KeyCompleteReason = convert(varchar(64), t.Complete_Reason)
		)
	union
	select	t.reason
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcMESCorp.tracked_object_status t
	where t.reason is not null
		and not exists (
			select *
			from DWTOPS.HubCompleteReason h
			where h.KeyCompleteReason = t.reason
		)
	option (label = 'DWTOPS.LoadHubCompleteReason');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubCompleteReason', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
