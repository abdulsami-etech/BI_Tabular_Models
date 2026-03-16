CREATE PROC [DW].[LoadHubOrder] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubOrder
		where SKOrder = -1
	)
	begin
		set identity_insert DW.HubOrder on
		begin try
			insert into DW.HubOrder (
					SKOrder
				,	KeyOrder
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	-1
				,	-1
				,	'N/A'
				,	@dt
			)
		end try
		begin catch
			set identity_insert DW.HubOrder off;
			throw
		end catch
		set identity_insert DW.HubOrder off
	end

	insert into DW.HubOrder (
			KeyOrder
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
select top (1) with ties
				KeyOrder
			,	@BatchID
			,	SourceSystemCode
			,	@dt
		from (
			select	jde_order_id as KeyOrder
				,	'IDS' as SourceSystemCode
			from SrcIDS.tblCnPatientOrderMap t1
			where jde_order_id > 0 and not exists (
				select *
				from DW.HubOrder h
				where h.KeyOrder = t1.jde_order_id)
			union all
			select	convert(bigint, SAP_Order_ID__c) as KeyOrder
				,	'SFDC' as SourceSystemCode
			from SrcSFDC.Apttus_Config2__Order__c t2
			where try_convert(bigint, SAP_Order_ID__c) is not null and not exists (
				select *
				from DW.HubOrder h
				where h.KeyOrder = convert(bigint, t2.SAP_Order_ID__c))
			union all
			select	convert(bigint, VBELN) as KeyOrder
				,	'SAP' as SourceSystemCode
			from SrcSAP.VBAK t3
			where try_convert(bigint, VBELN) is not null and not exists (
				select *
				from DW.HubOrder h
				where h.KeyOrder = convert(bigint, t3.VBELN))
			union all
			select	convert(bigint, order_number) as KeyOrder
				,	'MESCorp' as SourceSystemCode
			from SrcMESCorp.Work_Order t4
			where try_convert(bigint, order_number) is not null and not exists (
				select *
				from DW.HubOrder h
				where h.KeyOrder = convert(bigint, t4.order_number))
		) t
		order by row_number() over (partition by KeyOrder order by SourceSystemCode) 
		option (label = 'DW.LoadHubOrder');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubOrder', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
