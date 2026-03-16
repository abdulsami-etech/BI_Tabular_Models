CREATE PROC [DWTOPS].[LoadDimRoute] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimRoute') is not null
		drop table #TempDimRoute

	create table #TempDimRoute with (distribution = round_robin, heap) as 
	select	h.SKRoute								as SKRoute
		,	t.ADLSBatchID							as ADLSBatchID
		,	t.ADLSTimestamp							as ADLSTimestamp
		,	t.LZBatchID								as LZBatchID
		,	convert(char(40), 
				hashbytes('SHA1', 
					t.Route_Name
				)
			, 2)									as DWHash
		,	t.Route_Key								as KeyRoute
		,	convert(varchar(64), t.Route_Name)		as RouteName
	from SrcMESCorp.[ROUTE] t
	inner join [DWTOPS].[HubRoute] h on h.KeyRoute = t.Route_Key
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimRoute)

	if not exists (select * from DWTOPS.DimRoute where SKRoute = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimRoute (
				SKRoute
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyRoute
			,	RouteName
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
		)
	end

	update DWTOPS.DimRoute
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchId
		,	DWHash = src.DWHash
		,	RouteName = src.RouteName
	from #TempDimRoute src
	where DWTOPS.DimRoute.SKRoute = src.SKRoute
		and DWTOPS.DimRoute.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimRoute_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimRoute_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimRoute (
			SKRoute
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyRoute
		,	RouteName
	)
	select	src.SKRoute
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyRoute
		,	src.RouteName
	from #TempDimRoute src
	where not exists(select * from DWTOPS.DimRoute dst where dst.SKRoute = src.SKRoute)
	option (label = 'DWTOPS.LoadDimRoute_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimRoute_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
