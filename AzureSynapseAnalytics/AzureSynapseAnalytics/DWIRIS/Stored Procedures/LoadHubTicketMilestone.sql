CREATE PROC [DWIRIS].[LoadHubTicketMilestone] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknown element
	
	if not exists (
		select *
		from DWIRIS.HubTicketMilestone
		where [SKTicketMilestone] = -1
	)
	begin
		set identity_insert DWIRIS.HubTicketMilestone on
		begin try
			insert into DWIRIS.HubTicketMilestone (
					   [SKTicketMilestone]
					 , [KeyTicketMilestone]
					 , [SourceSystemCode]
					 , [DWBatchID]
					 , [InsertDateTime]
			)
			values (
					-1
				,	N'N/A'
				,	'System'
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubTicketMilestone off;
			throw
		end catch
		set identity_insert DWIRIS.HubTicketMilestone off
	end   --if statement

		
	--insert new keys to hub
	insert into DWIRIS.HubTicketMilestone (
		[KeyTicketMilestone]
		, [SourceSystemCode]
		, [DWBatchID]
		, [InsertDateTime]
	)
	select Id as [KeyTicketMilestone]
		, 'SFDC' as [SourceSystemCode]
		, @BatchID as [DWBatchID]
		, @dt as [InsertDateTime]
	from [SrcSFDC].[CaseMileStone]
	where Id not in (
		select KeyTicketMilestone
		from DWIRIS.HubTicketMilestone
	)
	option (label = 'DWIRIS.LoadHubTicketMilestone');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTicketMilestone', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
