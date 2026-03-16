CREATE PROC [DW].[LoadHubUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubUser
		where SKUser = -1
	)
	begin
		set identity_insert DW.HubUser on
		begin try
			insert into DW.HubUser (
					SKUser
				,	KeyUser
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
			set identity_insert DW.HubUser off;
			throw
		end catch
		set identity_insert DW.HubUser off
	end

	insert into DW.HubUser (
		KeyUser,
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
		from SrcSFDC.[User] 
		union all
		select	convert(nvarchar(18), ContactID) as Id
			,	'MAT' as SourceSystemCode
		from SrcMAT.Contact
	) u
	where	not exists (
				select *
				from DW.HubUser h
				where h.KeyUser = u.Id
		    )
	option (label = 'DW.LoadHubUser');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

