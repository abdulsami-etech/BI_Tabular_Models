CREATE PROC [DW].[LoadHubCampaign] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubCampaign
		where SKCampaign = -1
	)
	begin
		set identity_insert DW.HubCampaign on
		begin try
			insert into DW.HubCampaign (
					SKCampaign
				,	KeyCampaign
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
			set identity_insert DW.HubCampaign off;
			throw
		end catch
		set identity_insert DW.HubCampaign off
	end

	insert into DW.HubCampaign (
		KeyCampaign,
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
		from SrcSFDC.[Campaign] 
		) u
	where	not exists (
				select *
				from DW.HubCampaign h
				where h.KeyCampaign = u.Id
		    )
	option (label = 'DW.LoadHubCampaign');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubCampaign', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

