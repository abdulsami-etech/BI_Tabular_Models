CREATE PROC [DWTOPS].[LoadHubTeamRegion] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubTeamRegion
		where SKTeamRegion = -1
	)
	begin
		set identity_insert DWTOPS.HubTeamRegion on
		begin try
			insert into DWTOPS.HubTeamRegion (
					SKTeamRegion
				,	KeyTeamRegion
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
			set identity_insert DWTOPS.HubTeamRegion off;
			throw
		end catch
		set identity_insert DWTOPS.HubTeamRegion off

	end

	insert into DWTOPS.HubTeamRegion (
			KeyTeamRegion
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select top (1) with ties
			convert(varchar(80), t.RegionName_S)
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcMESCorp.AT_at_SuperRegion t
	where t.RegionName_S is not null
		and t.atr_name like '%[_]BI%'
	and	not exists (
			select *
			from DWTOPS.HubTeamRegion h
			where h.KeyTeamRegion = convert(varchar(80), t.RegionName_S)
		)
	order by row_number() over (partition by t.RegionName_S order by t.last_modified_time_u desc)
	option (label = 'DWTOPS.LoadHubTeamRegion');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubTeamRegion', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
