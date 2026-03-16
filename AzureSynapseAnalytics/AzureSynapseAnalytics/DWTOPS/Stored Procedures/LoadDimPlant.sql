CREATE PROC [DWTOPS].[LoadDimPlant] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimPlant') is not null
		drop table #TempDimPlant

	create table #TempDimPlant with (distribution = round_robin, heap) as 
	select	h.SKPlant								as SKPlant
		,	t.ADLSBatchID							as ADLSBatchID
		,	t.ADLSTimestamp							as ADLSTimestamp
		,	t.LZBatchID								as LZBatchID
		,	convert(char(40), 
				hashbytes('SHA1', 
							isnull(t.description, N'N/A')
					+ N'|' + isnull(t.category, N'N/A')
				)
			, 2)									as DWHash
		,	convert(varchar(64), t.site_name)		as KeyPlant
		,	convert(varchar(255), t.description)	as PlantDescription
		,	convert(varchar(50), t.category)		as PlantCategory
	from SrcMESCorp.[SITE] t
	inner join [DWTOPS].[HubPlant] h on h.KeyPlant = convert(varchar(64), t.site_name)
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimPlant)

	if not exists (select * from DWTOPS.DimPlant where SKPlant = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimPlant (
				SKPlant
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyPlant
			,	PlantDescription
			,	PlantCategory
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	'0000'
			,	'N/A'
			,	'N/A'
		)
	end

	update DWTOPS.DimPlant
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchId
		,	DWHash = src.DWHash
		,	PlantDescription = src.PlantDescription
		,	PlantCategory = src.PlantCategory
	from #TempDimPlant src
	where DWTOPS.DimPlant.SKPlant = src.SKPlant
		and DWTOPS.DimPlant.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimPlant_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimPlant_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimPlant (
			SKPlant
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyPlant
		,	PlantDescription
		,	PlantCategory
	)
	select	src.SKPlant
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyPlant
		,	src.PlantDescription
		,	src.PlantCategory
	from #TempDimPlant src
	where not exists(select * from DWTOPS.DimPlant dst where dst.SKPlant = src.SKPlant)
	option (label = 'DWTOPS.LoadDimPlant_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimPlant_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
