CREATE PROC [DW].[LoadHubLeadConversation] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubLeadConversation
		where SKLeadConversation = -1
	)
	begin
		set identity_insert DW.HubLeadConversation on
		begin try
			insert into DW.HubLeadConversation (
					SKLeadConversation
				,	KeyLeadConversation
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
			set identity_insert DW.HubLeadConversation off;
			throw
		end catch
		set identity_insert DW.HubLeadConversation off
	end

	insert into DW.HubLeadConversation (
		KeyLeadConversation,
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
		from SrcSFDC.[Lead_Conversation__c] 
		) u
	where	not exists (
				select *
				from DW.HubLeadConversation h
				where h.KeyLeadConversation = u.Id
		    )
	option (label = 'DW.LoadHubLeadConversation');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubLeadConversation', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

