CREATE PROC [DWIRIS].[LoadHubCase] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubCase
		where [SKCase] = -1
	)
	begin
		set identity_insert DWIRIS.HubCase on
		begin try
			insert into DWIRIS.HubCase (
					[SKCase]
				,	[KeyCase]
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
			set identity_insert DWIRIS.HubCase off;
			throw
		end catch
		set identity_insert DWIRIS.HubCase off
	end   	--insert new keys to hub
	insert into DWIRIS.HubCase
	(
		[KeyCase],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select SalesOrderHeaderID as KeyCase
		, @BatchID
		, 'MAT'
		, @dt 
	from srcmat.SalesOrdersHeader
	where SalesOrderHeaderID not in (
		select keyCase
		from DWIRIS.HubCase where [SourceSystemCode]='MAT'
	)
	option (label = 'DWIRIS.LoadHubTeam');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTeam', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end



