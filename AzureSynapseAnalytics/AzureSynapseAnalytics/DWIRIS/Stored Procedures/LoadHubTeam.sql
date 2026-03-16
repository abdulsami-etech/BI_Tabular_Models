CREATE PROC [DWIRIS].[LoadHubTeam] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubTeam
		where [SKTeam] = -1
	)
	begin
		set identity_insert DWIRIS.HubTeam on
		begin try
			insert into DWIRIS.HubTeam (
					[SKTeam]
				,	[KeyTeam]
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
			set identity_insert DWIRIS.HubTeam off;
			throw
		end catch
		set identity_insert DWIRIS.HubTeam off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubTeam') is not null
		drop table #TempHubTeam
		
	create table #TempHubTeam with (distribution = round_robin, heap) as

	select KeyTeam
		, min(SourceSystemCode) as SourceSystemCode
	from (
		select ContactTeamGenericDescription as KeyTeam
			, 'MAT' as SourceSystemCode 
		from SrcMAT.svc_Team
		union
		select Team_Function__c as KeyTeam
			, 'SFDC' as SourceSystemCode 
		from SrcSFDC.[Case]
	) z
	group by KeyTeam
		

	--insert new keys to hub
	insert into DWIRIS.HubTeam
	(
		[KeyTeam],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select KeyTeam
		, @BatchID
		, SourceSystemCode
		, @dt 
	from #TempHubTeam
	where KeyTeam not in (
		select KeyTeam
		from DWIRIS.HubTeam
	)
	option (label = 'DWIRIS.LoadHubTeam');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubTeam', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
