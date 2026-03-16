CREATE PROC [DW].[LoadHubAccount] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubAccount
		where SKAccount = -1
	)
	begin
		set identity_insert DW.HubAccount on
		begin try
			insert into DW.HubAccount (
					SKAccount
				,	KeyAccount
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
			set identity_insert DW.HubAccount off;
			throw
		end catch
		set identity_insert DW.HubAccount off
	end

	insert into DW.HubAccount (
		KeyAccount,
		DWBatchID,
		SourceSystemCode,
		InsertDateTime
	)
	select	t.Id
		,	@BatchID
		,	'SFDC'
		,	@dt 
	from (
		select t.Id
		from SrcSFDC.Account t
		union
		select t.AccountId as Id
		from SrcSFDC.Contact t
		where t.AccountId is not null
	) t
	where	not exists (
				select *
				from DW.HubAccount h
				where h.KeyAccount = t.Id
		    )
	option (label = 'DW.LoadHubAccount');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubAccount', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END
