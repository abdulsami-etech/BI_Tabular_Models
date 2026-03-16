CREATE PROC [DW].[LoadDimTerritory] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimTerritory') is not null
		drop table #TempDimTerritory

	create table #TempDimTerritory with (distribution = round_robin, heap) as 
	select	hub.SKTerritory				as SKTerritory
		,	t.ADLSBatchID				as ADLSBatchID
		,	t.ADLSTimestamp				as ADLSTimestamp
		,	t.LZBatchID					as LZBatchID
		,	convert(char(40), '')		as DWHash
		,	t.Id						as KeyTerritory
		,	t.Territory_ID__c			as TerritoryName
		,	t.Name						as TerritoryLabel
		,	tp.MasterLabel				as TerritoryType
		,	isnull(hubUser.SKUser, -1)	as SKUserOwner
		,	hubParent.SKTerritory		as SKTerritoryParentTerritory
	from SrcSFDC.Territory2 t
	inner join DW.HubTerritory hub on hub.KeyTerritory = t.Id
	left join DW.HubTerritory hubParent on hubParent.KeyTerritory = t.ParentTerritory2Id
	inner join SrcSFDC.Territory2Type tp on tp.Id = t.Territory2TypeId
	left join (
		select top (1) with ties
				Territory2Id
			,	UserId
		from SrcSFDC.UserTerritory2Association
		where isnull(RoleInTerritory2, N'') not in ('Delegated', 'Delegated TM')
		order by row_number() over (partition by Territory2Id order by IsActive desc, SystemModStamp desc)
	) usr on usr.Territory2Id = t.Id
	left join DW.HubUser hubUser on hubUser.KeyUser = usr.UserId
	--where t.ADLSTimestamp >= @LastSuccessfullDWTimestamp--(select isnull(max(ADLSTimestamp), '19000101') from DW.DimTerritory)

	update #TempDimTerritory set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						 isnull(convert(nvarchar, TerritoryName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryLabel), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TerritoryType), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKUserOwner), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKTerritoryParentTerritory), N'N/A')
			)
		, 2)

	if not exists (select * from DW.DimTerritory where SKTerritory = -1)
	begin
		declare @Hash char(40) = ''

		insert into DW.DimTerritory (
				SKTerritory
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyTerritory
			,	TerritoryName
			,	TerritoryLabel
			,	TerritoryType
			,	SKUserOwner
			,	SKTerritoryParentTerritory
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	null
		)
	end

	update DW.DimTerritory
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	TerritoryName = src.TerritoryName
		,	TerritoryLabel = src.TerritoryLabel
		,	TerritoryType = src.TerritoryType
		,	SKUserOwner = src.SKUserOwner
		,	SKTerritoryParentTerritory = src.SKTerritoryParentTerritory
	from #TempDimTerritory src
	where DW.DimTerritory.SKTerritory = src.SKTerritory
		and DW.DimTerritory.DWHash != src.DWHash
	option (label = 'DW.LoadDimTerritory_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimTerritory_Update', @rc = @RowsUpdated out

	insert into DW.DimTerritory (
			SKTerritory
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyTerritory
		,	TerritoryName
		,	TerritoryLabel
		,	TerritoryType
		,	SKUserOwner
		,	SKTerritoryParentTerritory
	)
	select	src.SKTerritory
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyTerritory
		,	src.TerritoryName
		,	src.TerritoryLabel
		,	src.TerritoryType
		,	src.SKUserOwner
		,	src.SKTerritoryParentTerritory
	from #TempDimTerritory src
	where not exists (select * from DW.DimTerritory dst where dst.SKTerritory = src.SKTerritory)
	option (label = 'DW.LoadDimTerritory_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimTerritory_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
