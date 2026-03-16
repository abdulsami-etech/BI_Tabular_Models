CREATE PROC [DWTOPS].[LoadDimExpediteScope] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimExpediteScope') is not null
		drop table #TempDimExpediteScope

	create table #TempDimExpediteScope with (distribution = round_robin, heap) as 
	select	max(t.ADLSBatchID)		as ADLSBatchID
		,	max(t.ADLSTimestamp)	as ADLSTimestamp
		,	max(t.LZBatchID)		as LZBatchID
		,	convert(char(40), hashbytes('SHA1', h.KeyExpediteScope), 2) as DWHash
		,	h.KeyExpediteScope		as KeyExpediteScope
		,	h.SKExpediteScope		as SKExpediteScope
	from SrcMESCorp.uda_order t
	inner join DWTOPS.HubExpediteScope h on h.KeyExpediteScope = convert(varchar(50), t.at_expedite_scope_S)
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimExpediteScope)
	group by h.KeyExpediteScope, h.SKExpediteScope

	if not exists (select * from DWTOPS.DimExpediteScope where SKExpediteScope = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimExpediteScope (
				SKExpediteScope
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyExpediteScope
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	'N/A'
		)
	end

	insert into DWTOPS.DimExpediteScope (
			SKExpediteScope
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyExpediteScope
	)
	select	src.SKExpediteScope
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyExpediteScope
	from #TempDimExpediteScope src
	where not exists(select * from DWTOPS.DimExpediteScope dst where dst.SKExpediteScope = src.SKExpediteScope)
	option (label = 'DWTOPS.LoadDimExpediteScope_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimExpediteScope_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
