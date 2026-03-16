CREATE PROC [DW].[LoadHubTrainingEventTypes] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubTrainingEventTypes
		where SKTrainingEventType = -1
	)
	begin
		set identity_insert DW.HubTrainingEventTypes on
		begin try
			insert into DW.HubTrainingEventTypes (
					SKTrainingEventType
				,	KeyTrainingEventType
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
			set identity_insert DW.HubTrainingEventTypes off;
			throw
		end catch
		set identity_insert DW.HubTrainingEventTypes off
	end

	insert into DW.HubTrainingEventTypes (
		KeyTrainingEventType,
		DWBatchID,
		SourceSystemCode,
		InsertDateTime
	)
	select	t.Id
		,	@BatchID
		,	'SFDC'
		,	@dt 
	from SrcSFDC.Event__c t
	where	not exists (
				select *
				from DW.HubTrainingEventTypes h
				where h.KeyTrainingEventType = t.Id
		    )
	option (label = 'DW.LoadHubTrainingEventTypes');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubTrainingEventTypes', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END
