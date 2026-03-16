CREATE PROC [DW].[LoadHubTerritory] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubTerritory
		where SKTerritory = -1
	)
	begin
		set identity_insert DW.HubTerritory on
		begin try
			insert into DW.HubTerritory (
					SKTerritory
				,	KeyTerritory
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	'N/A'
				,	@dt
			)
		end try
		begin catch
			set identity_insert DW.HubTerritory off;
			throw
		end catch
		set identity_insert DW.HubTerritory off
	end

	insert into DW.HubTerritory (
		KeyTerritory,
		DWBatchID,
		SourceSystemCode,
		InsertDateTime
	)
	select	t.Id
		,	@BatchID
		,	'SFDC'
		,	@dt 
	from SrcSFDC.Territory2 t
	where	not exists (
				select *
				from DW.HubTerritory h
				where h.KeyTerritory = t.Id
		    )
	option (label = 'DW.LoadHubTerritory');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubTerritory', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
