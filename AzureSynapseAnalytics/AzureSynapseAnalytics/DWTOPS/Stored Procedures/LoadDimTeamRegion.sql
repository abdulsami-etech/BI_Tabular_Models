CREATE PROC [DWTOPS].[LoadDimTeamRegion] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimTeamRegion') is not null
		drop table #TempDimTeamRegion

	create table #TempDimTeamRegion with (distribution = round_robin, heap) as 
	select top (1) with ties
			h.SKTeamRegion							as SKTeamRegion
		,	t.ADLSBatchID							as ADLSBatchID
		,	t.ADLSTimestamp							as ADLSTimestamp
		,	t.LZBatchID								as LZBatchID
		,	convert(char(40), 
				hashbytes('SHA1', 
					replace(replace(t.atr_name, 'Super ', ''), '_BI', '')
				)
			, 2)									as DWHash
		,	convert(varchar(80), t.RegionName_S)	as KeyTeamRegion
		,	convert(varchar(64), replace(replace(t.atr_name, 'Super ', ''), '_BI', '')) as GroupRegion
	from SrcMESCorp.AT_at_SuperRegion t
	inner join DWTOPS.HubTeamRegion h on h.KeyTeamRegion = convert(varchar(80), t.RegionName_S)
	where t.RegionName_S is not null
		and t.atr_name like '%_BI%'
	order by row_number() over (partition by t.RegionName_S order by t.last_modified_time_u desc)

	if not exists (select * from DWTOPS.DimTeamRegion where SKTeamRegion = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', 'N/A'), 2)

		insert into DWTOPS.DimTeamRegion (
				SKTeamRegion
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyTeamRegion
			,	GroupRegion
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	'N/A'
			,	'N/A'
		)
	end

	update DWTOPS.DimTeamRegion
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchId
		,	DWHash = src.DWHash
		,	GroupRegion = src.GroupRegion
	from #TempDimTeamRegion src
	where DWTOPS.DimTeamRegion.SKTeamRegion = src.SKTeamRegion
		and DWTOPS.DimTeamRegion.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimTeamRegion_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimTeamRegion_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimTeamRegion (
			SKTeamRegion
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyTeamRegion
		,	GroupRegion
	)
	select	src.SKTeamRegion
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyTeamRegion
		,	src.GroupRegion
	from #TempDimTeamRegion src
	where not exists(select * from DWTOPS.DimTeamRegion dst where dst.SKTeamRegion = src.SKTeamRegion)
	option (label = 'DWTOPS.LoadDimTeamRegion_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimTeamRegion_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
