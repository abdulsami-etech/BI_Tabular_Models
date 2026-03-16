CREATE PROC [DWIRIS].[LoadHubProposal] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubProposal
		where [SKProposal] = -1
	)
	begin
		set identity_insert DWIRIS.HubProposal on
		begin try
			insert into DWIRIS.HubProposal (
					[SKProposal]
				,	[KeyProposal]
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
			set identity_insert DWIRIS.HubProposal off;
			throw
		end catch
		set identity_insert DWIRIS.HubProposal off
	end   --if statement

	   
		
	-- Pull all business keys to temp table 

	if object_id('tempdb..#TempHubProposal') is not null
		drop table #TempHubProposal
		
	create table #TempHubProposal
		(
			ID nchar(255)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubProposal (ID)
	select 
		 pr.[Id] + isnull(li.Id,'') as ID
	from [SrcSFDC].[Apttus_Proposal__Proposal__c]  pr
	left join [SrcSFDC].[Apttus_Proposal__Proposal_Line_Item__c] li
	on pr.Id = li.[Apttus_Proposal__Proposal__c] 

	
	--insert new keys to hub
	insert into DWIRIS.HubProposal
	(
		[KeyProposal],
		[DWBatchID],
		[InsertDateTime]
	)
	select ID, @BatchID, @dt from #TempHubProposal where ID not in (select [KeyProposal] from DWIRIS.HubProposal)
	option (label = 'DWIRIS.LoadHubProposal');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubProposal', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
