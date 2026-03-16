CREATE PROC [DW].[LoadHubLead] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubLead
		where SKLead = -1
	)
	begin
		set identity_insert DW.HubLead on
		begin try
			insert into DW.HubLead (
					SKLead
				,	KeyLead
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
			set identity_insert DW.HubLead off;
			throw
		end catch
		set identity_insert DW.HubLead off
	end

	insert into DW.HubLead (
		KeyLead,
		DWBatchID,
		SourceSystemCode,
		InsertDateTime
	)
	select	u.Id
		,	@BatchID
		,	u.SourceSystemCode
		,	@dt 
	from (
		select	Id
			,	'SFDC' as SourceSystemCode
		from SrcSFDC.[Lead] 
		) u
	where	not exists (
				select *
				from DW.HubLead h
				where h.KeyLead = u.Id
		    )
	option (label = 'DW.LoadHubLead');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubLead', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end