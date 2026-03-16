CREATE PROC [DWTOPS].[LoadHubExpediteScope] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@CurrentDate	datetime = getdate()

	if not exists (
		select *
		from DWTOPS.HubExpediteScope
		where SKExpediteScope = -1
	)
	begin
		set identity_insert DWTOPS.HubExpediteScope on
		begin try
			insert into DWTOPS.HubExpediteScope (
					SKExpediteScope
				,	KeyExpediteScope
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	-1
				,	-1
				,	'N/A'
				,	@CurrentDate
			)
		end try
		begin catch
			set identity_insert DWTOPS.HubExpediteScope off;
			throw
		end catch
		set identity_insert DWTOPS.HubExpediteScope off

	end

	insert into DWTOPS.HubExpediteScope (
			KeyExpediteScope
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select distinct 
			convert(varchar(50), t.at_expedite_scope_S) as KeyExpediteScope
		,	@BatchID
		,	'MESCorp'
		,	@CurrentDate
	from SrcMESCorp.uda_order t
	where t.at_expedite_scope_S is not null
		and not exists (
				select *
				from DWTOPS.HubExpediteScope h
				where h.KeyExpediteScope = convert(varchar(50), t.at_expedite_scope_S)
		)
	option (label = 'DWTOPS.LoadHubExpediteScope');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadHubExpediteScope', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
