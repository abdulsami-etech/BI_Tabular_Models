CREATE PROC [DWTOPS].[LoadHubPlant] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubPlant
		where SKPlant = -1
	)
	begin
		set identity_insert DWTOPS.HubPlant on
		begin try
			insert into DWTOPS.HubPlant (
					SKPlant
				,	KeyPlant
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
			set identity_insert DWTOPS.HubPlant off;
			throw
		end catch
		set identity_insert DWTOPS.HubPlant off

	end

	insert into DWTOPS.HubPlant (
			KeyPlant
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct
			t.KeyPlant
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from (
		select convert(varchar(64), site_name) as KeyPlant
		from SrcMESCorp.[SITE] 
		union all
		select at_ActualPlant_S
		from SrcMESCorp.uda_lot
		where at_ActualPlant_S is not null
		union all
		select at_Plant_S
		from SrcMESCorp.uda_lot
		where at_Plant_S is not null
	) t
	where	not exists (
				select *
				from DWTOPS.HubPlant h
				where h.KeyPlant = t.KeyPlant
			)
	option (label = 'DWTOPS.LoadHubPlant');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubPlant', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
