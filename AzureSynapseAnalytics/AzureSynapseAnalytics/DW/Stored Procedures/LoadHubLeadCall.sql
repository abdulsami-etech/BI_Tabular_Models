CREATE PROC [DW].[LoadHubLeadCall] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubLeadCall
		where SKLeadCall = -1
	)
	begin
		set identity_insert DW.HubLeadCall on
		begin try
			insert into DW.HubLeadCall (
					SKLeadCall
				,	KeyLeadCall
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
			set identity_insert DW.HubLeadCall off;
			throw
		end catch
		set identity_insert DW.HubLeadCall off
	end

	insert into DW.HubLeadCall (
		KeyLeadCall,
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
		from SrcSFDC.[ringdna105__Call__c] 
		) u
	where	not exists (
				select *
				from DW.HubLeadCall h
				where h.KeyLeadCall = u.Id
		    )
	option (label = 'DW.LoadHubLeadCall');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubLeadCall', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

