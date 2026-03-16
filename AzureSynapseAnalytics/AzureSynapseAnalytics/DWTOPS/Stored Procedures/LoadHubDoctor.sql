CREATE PROC [DWTOPS].[LoadHubDoctor] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubDoctor
		where SKDoctor = -1
	)
	begin
		set identity_insert DWTOPS.HubDoctor on
		begin try
			insert into DWTOPS.HubDoctor (
					SKDoctor
				,	KeyDoctor
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	N'N/A'
				,	-1
				,	'N/A'
				,	@CurrentDate
			)
		end try
		begin catch
			set identity_insert DWTOPS.HubDoctor off;
			throw
		end catch
		set identity_insert DWTOPS.HubDoctor off

	end

	insert into DWTOPS.HubDoctor (
			KeyDoctor
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select	t.DoctorID
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcMESCorp.DC_at_DoctorInformation t
	where t.DoctorID is not null
		and not exists (
			select *
			from DWTOPS.HubDoctor h
			where h.KeyDoctor = convert(varchar(64), t.DoctorID)
		)
	union
	select	t.at_DoctorID_S
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcMESCorp.UDA_Order t
	where t.at_DoctorID_S is not null
		and not exists (
			select *
			from DWTOPS.HubDoctor h
			where h.KeyDoctor = t.at_DoctorID_S
		)
	option (label = 'DWTOPS.LoadHubDoctor');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubDoctor', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
