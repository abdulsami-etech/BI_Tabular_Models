CREATE PROC [DWIRIS].[LoadHubEvent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubEvent
		where [SKEvent] = -1
	)
	begin
		set identity_insert DWIRIS.HubEvent on
		begin try
			insert into DWIRIS.HubEvent (
					[SKEvent]
				,	[KeyEvent]
				,	DWBatchID
				,	InsertDateTime
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubEvent off;
			throw
		end catch
		set identity_insert DWIRIS.HubEvent off
	end   --if statement

	
	--insert new keys to hub
	insert into DWIRIS.HubEvent
	(
		[KeyEvent],
		[DWBatchID],
		[InsertDateTime]
	)
	select ID, @BatchID, @dt from [SrcSFDC].[Event] where ID not in (select [KeyEvent] from DWIRIS.HubEvent)
	option (label = 'DWIRIS.LoadHubEvent');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubEvent', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END