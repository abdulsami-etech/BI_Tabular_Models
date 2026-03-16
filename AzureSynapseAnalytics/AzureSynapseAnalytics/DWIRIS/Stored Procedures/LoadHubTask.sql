CREATE PROC [DWIRIS].[LoadHubTask] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubTask
		where [SKTask] = -1
	)
	begin
		set identity_insert DWIRIS.HubTask on
		begin try
			insert into DWIRIS.HubTask (
					[SKTask]
				,	[KeyTask]
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
			set identity_insert DWIRIS.HubTask off;
			throw
		end catch
		set identity_insert DWIRIS.HubTask off
	end   --if statement

	
	--insert new keys to hub
	insert into DWIRIS.HubTask
	(
		[KeyTask],
		[DWBatchID],
		[InsertDateTime]
	)
	select ID, @BatchID, @dt from [SrcSFDC].[Task] where ID not in (select [KeyTask] from DWIRIS.HubTask)
	option (label = 'DWIRIS.LoadHubTask');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTask', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END