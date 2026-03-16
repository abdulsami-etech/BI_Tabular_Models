CREATE PROC [DWTOPS].[LoadDimRouteStep] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimRouteStep') is not null
		drop table #TempDimRouteStep

	create table #TempDimRouteStep with (distribution = round_robin, heap) as 
	select	h.SKRouteStep							as SKRouteStep
		,	t.ADLSBatchID							as ADLSBatchID
		,	t.ADLSTimestamp							as ADLSTimestamp
		,	t.LZBatchID								as LZBatchID
		,	convert(char(40), 
				hashbytes('SHA1', 
							t.route_step_name
					+ N'|' + isnull(t.route_step_type, N'N/A')
					+ N'|' + isnull(t.category, N'N/A')
				)
			, 2)									as DWHash
		,	t.route_step_key						as KeyRouteStep
		,	convert(varchar(64), t.route_step_name)	as RouteStepName
		,	convert(varchar(50), t.route_step_type)	as RouteStepType
		,	convert(varchar(50), t.category)		as RouteStepCategory
	from SrcMESCorp.ROUTE_STEP t
	inner join [DWTOPS].[HubRouteStep] h on h.KeyRouteStep = t.route_step_key
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimRouteStep)

	if not exists (select * from DWTOPS.DimRouteStep where SKRouteStep = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimRouteStep (
				SKRouteStep
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyRouteStep
			,	RouteStepName
			,	RouteStepType
			,	RouteStepCategory
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
			,	'N/A'
			,	'N/A'
		)
	end

	update DWTOPS.DimRouteStep
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchId
		,	DWHash = src.DWHash
		,	RouteStepName = src.RouteStepName
		,	RouteStepType = src.RouteStepType
		,	RouteStepCategory = src.RouteStepCategory
	from #TempDimRouteStep src
	where DWTOPS.DimRouteStep.SKRouteStep = src.SKRouteStep
		and DWTOPS.DimRouteStep.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimRouteStep_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimRouteStep_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimRouteStep (
			SKRouteStep
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyRouteStep
		,	RouteStepName
		,	RouteStepType
		,	RouteStepCategory
	)
	select	src.SKRouteStep
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyRouteStep
		,	src.RouteStepName
		,	src.RouteStepType
		,	src.RouteStepCategory
	from #TempDimRouteStep src
	where not exists(select * from DWTOPS.DimRouteStep dst where dst.SKRouteStep = src.SKRouteStep)
	option (label = 'DWTOPS.LoadDimRouteStep_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimRouteStep_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
