CREATE PROC [DWIRIS].[LoadHubOpportunity] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubOpportunity
		where [SKOpportunity] = -1
	)
	begin
		set identity_insert DWIRIS.HubOpportunity on
		begin try
			insert into DWIRIS.HubOpportunity (
					[SKOpportunity]
				,	[KeyOpportunity]
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
			set identity_insert DWIRIS.HubOpportunity off;
			throw
		end catch
		set identity_insert DWIRIS.HubOpportunity off
	end   --if statement

	
	--insert new keys to hub
	insert into DWIRIS.HubOpportunity
	(
		[KeyOpportunity],
		[DWBatchID],
		[InsertDateTime]
	)
	select ID, @BatchID, @dt from [SrcSFDC].[Opportunity] where ID not in (select [KeyOpportunity] from DWIRIS.HubOpportunity)
	option (label = 'DWIRIS.LoadHubOpportunity');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubOpportunity', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END