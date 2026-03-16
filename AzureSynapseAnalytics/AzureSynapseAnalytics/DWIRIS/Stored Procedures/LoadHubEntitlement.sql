CREATE PROC [DWIRIS].[LoadHubEntitlement] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubEntitlement
		where [SKEntitlement] = -1
	)
	begin
		set identity_insert DWIRIS.HubEntitlement on
		begin try
			insert into DWIRIS.HubEntitlement (
					[SKEntitlement]
				,	[KeyEntitlement]
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
			set identity_insert DWIRIS.HubEntitlement off;
			throw
		end catch
		set identity_insert DWIRIS.HubEntitlement off
	end   	--insert new keys to hub
	insert into DWIRIS.HubEntitlement
	(
		[KeyEntitlement],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select ID as KeyCase
		, @BatchID
		, 'SFDC'
		, @dt 
	from srcSFDC.Entitlement
	where ID not in (
		select keyEntitlement
		from DWIRIS.HubEntitlement where [SourceSystemCode]='SFDC'
	)
	option (label = 'DWIRIS.LoadHubEntitlement');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubEntitlement', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
