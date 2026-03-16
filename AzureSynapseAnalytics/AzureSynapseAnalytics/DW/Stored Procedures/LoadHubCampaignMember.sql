CREATE PROC [DW].[LoadHubCampaignMember] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubCampaignMember
		where SKCampaignMember = -1
	)
	begin
		set identity_insert DW.HubCampaignMember on
		begin try
			insert into DW.HubCampaignMember (
					SKCampaignMember
				,	KeyCampaignMember
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
			set identity_insert DW.HubCampaignMember off;
			throw
		end catch
		set identity_insert DW.HubCampaignMember off
	end

	insert into DW.HubCampaignMember (
		KeyCampaignMember,
		DWBatchID,
		SourceSystemCode,
		InsertDateTime
	)
	select	u.Id
		,	@BatchID
		,	u.SourceSystemCode
		,	@dt 
	from (
		select	Id
			,	'SFDC' as SourceSystemCode
		from SrcSFDC.[CampaignMember] 
		) u
	where	not exists (
				select *
				from DW.HubCampaignMember h
				where h.KeyCampaignMember = u.Id
		    )
	option (label = 'DW.LoadHubCampaignMember');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubCampaignMember', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

