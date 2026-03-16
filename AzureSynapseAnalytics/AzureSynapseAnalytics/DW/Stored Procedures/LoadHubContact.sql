CREATE PROC [DW].[LoadHubContact] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubContact
		where [SKContact] = -1
	)
	begin
		set identity_insert DW.HubContact on
		begin try
			insert into DW.HubContact (
					SKContact
				,	KeyContact
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
			set identity_insert DW.HubContact off;
			throw
		end catch
		set identity_insert DW.HubContact off
	end

	insert into DW.HubContact
	(
		[KeyContact],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select	t.Id
		,	@BatchID
		,	'SFDC'
		,	@dt 
	from SrcSFDC.Contact t
	where   not exists (
				select *
				from DW.HubContact h
				where h.KeyContact = t.Id
		    )
	option (label = 'DW.LoadHubContact');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubContact', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END
