CREATE PROC [DWIRIS].[LoadHubTracker] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubTracker
		where [SKTracker] = -1
	)
	begin
		set identity_insert DWIRIS.HubTracker on
		begin try
			insert into DWIRIS.HubTracker (
					[SKTracker]
				,	[KeyTracker]
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
			set identity_insert DWIRIS.HubTracker off;
			throw
		end catch
		set identity_insert DWIRIS.HubTracker off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubTracker') is not null
		drop table #TempHubTracker
		
	create table #TempHubTracker with (distribution = round_robin, heap) as

	select KeyTracker
		, min(SourceSystemCode) as SourceSystemCode
	from (
		select Id as KeyTracker
			, 'SFDC' as SourceSystemCode 
		from SrcSFDC.Tracker__c
	) z
	group by KeyTracker
		

	--insert new keys to hub
	insert into DWIRIS.HubTracker
	(
		[KeyTracker],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select KeyTracker
		, @BatchID
		, SourceSystemCode
		, @dt 
	from #TempHubTracker
	where KeyTracker not in (
		select KeyTracker
		from DWIRIS.HubTracker
	)
	option (label = 'DWIRIS.LoadHubTracker');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTracker', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end