CREATE PROC [DWTOPS].[LoadDimOperation] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimOperation') is not null
		drop table #TempDimOperation

	create table #TempDimOperation with (distribution = round_robin, heap) as 
	select	h.SKOperation							as SKOperation
		,	t.ADLSBatchID							as ADLSBatchID
		,	t.ADLSTimestamp							as ADLSTimestamp
		,	t.LZBatchID								as LZBatchID
		,	convert(char(40), 
				hashbytes('SHA1', 
					convert(nvarchar, t.op_key)
					+ N'|' + isnull(t.op_name, N'N/A')
					+ N'|' + isnull(t.description, N'N/A')
					+ N'|' + isnull(t.category, N'N/A')
				)
			, 2)									as DWHash
		,	t.op_key								as KeyOperation
		,	convert(varchar(64), t.op_name)			as OperationName
		,	convert(varchar(255), t.description)	as OperationDescription
		,	isnull(convert(varchar(50), t.category), 'Other') as OperationCategory
	from SrcMESCorp.OPERATION t
	inner join DWTOPS.HubOperation h on h.KeyOperation = t.op_key
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimOperation)

	if not exists (select * from DWTOPS.DimOperation where SKOperation = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimOperation (
				SKOperation
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyOperation
			,	OperationName
			,	OperationDescription
			,	OperationCategory
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	-1
			,	'N/A'
			,	null
			,	'N/A'
		)
	end

	update DWTOPS.DimOperation
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	OperationName = src.OperationName
		,	OperationDescription = src.OperationDescription
		,	OperationCategory = src.OperationCategory
	from #TempDimOperation src
	where DWTOPS.DimOperation.SKOperation = src.SKOperation
		and DWTOPS.DimOperation.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimOperation_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimOperation_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimOperation (
			SKOperation
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyOperation
		,	OperationName
		,	OperationDescription
		,	OperationCategory
	)
	select	src.SKOperation
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyOperation
		,	src.OperationName
		,	src.OperationDescription
		,	src.OperationCategory
	from #TempDimOperation src
	where not exists(select * from DWTOPS.DimOperation dst where dst.SKOperation = src.SKOperation)
	option (label = 'DWTOPS.LoadDimOperation_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimOperation_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
