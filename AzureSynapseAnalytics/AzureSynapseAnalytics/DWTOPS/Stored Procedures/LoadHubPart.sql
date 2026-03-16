CREATE PROC [DWTOPS].[LoadHubPart] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubPart
		where SKPart = -1
	)
	begin
		set identity_insert DWTOPS.HubPart on
		begin try
			insert into DWTOPS.HubPart (
					SKPart
				,	KeyPart
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
			set identity_insert DWTOPS.HubPart off;
			throw
		end catch
		set identity_insert DWTOPS.HubPart off

	end

	insert into DWTOPS.HubPart (
			KeyPart
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select	t.KeyPart
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from (
		select convert(varchar(64), part_number) + '^' + convert(varchar(64), part_revision) as KeyPart
		from SrcMESCorp.Part 
		union
		select convert(varchar(64), part_number) + '^' + convert(varchar(64), part_revision)
		from SrcMESCorp.Lot
	) t
	where	not exists (
				select *
				from DWTOPS.HubPart h
				where h.KeyPart = t.KeyPart
			)
	option (label = 'DWTOPS.LoadHubPart');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubPart', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
