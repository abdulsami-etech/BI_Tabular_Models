CREATE PROC [DWTOPS].[LoadDimPart] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimPart') is not null
		drop table #TempDimPart

	create table #TempDimPart with (distribution = round_robin, heap) as 
	select	h.SKPart									as SKPart
		,	t.ADLSBatchID								as ADLSBatchID
		,	t.ADLSTimestamp								as ADLSTimestamp
		,	t.LZBatchID									as LZBatchID
		,	convert(char(40), 
				hashbytes('SHA1', 
							t.part_number
					+ N'|' + t.part_revision
					+ N'|' + isnull(t.description, N'N/A')
					+ N'|' + isnull(t.category, N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.image_key), N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.inst_list_key), N'N/A')
					+ N'|' + isnull(t.bom_name, N'N/A')
					+ N'|' + isnull(t.bom_revision, N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.quantity), N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.consumption_duration), N'N/A')
					+ N'|' + t.consumption_type
					+ N'|' + isnull(convert(nvarchar, t.bom_tracked_mode), N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.revived), N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.shelf_life), N'N/A')
					+ N'|' + convert(nvarchar, t.warranty_period)
					+ N'|' + isnull(t.unit_of_measure, N'N/A')
					+ N'|' + t.part_ext_revision
					+ N'|' + isnull(t.replacement_type, N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.carrier_class_key), N'N/A')
					+ N'|' + isnull(t.logically_empty_quantity, N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.mixing_type), N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.storage_class_enforced), N'N/A')
					+ N'|' + isnull(convert(nvarchar, t.storage_unit_class_key), N'N/A')
				)
			, 2)										as DWHash
		,	convert(varchar(64), t.part_number) + '^' + convert(varchar(64), t.part_revision) as KeyPart
		,	convert(varchar(64), t.part_number)			as PartNumber
		,	convert(varchar(64), t.part_revision)		as PartRevision
		,	convert(varchar(255), t.description)		as PartDescription
		,	convert(varchar(10), t.category)			as PartCategory
		,	t.image_key									as ImageKey
		,	t.inst_list_key								as InstListKey
		,	convert(varchar(64), t.bom_name)			as BOMName
		,	convert(varchar(64), t.bom_revision)		as BOMRevision
		,	t.quantity									as PartQuantity
		,	t.consumption_duration						as ConsumptionDuration
		,	convert(varchar(50), t.consumption_type)	as ConsumptionType
		,	t.bom_tracked_mode							as BOMTrackedMode
		,	t.revived									as Revived
		,	t.shelf_life								as ShelfLife
		,	t.warranty_period							as WarrantyPeriod
		,	convert(varchar(64), t.unit_of_measure)		as UnitOfMeasure
		,	convert(varchar(64), t.part_ext_revision)	as PartExtRevision
		,	convert(varchar(64), t.replacement_type)	as ReplacementType
		,	t.carrier_class_key							as CarrierClassKey
		,	convert(varchar(64), t.logically_empty_quantity) as LogicallyEmptyQuantity
		,	t.mixing_type								as MixingType
		,	t.storage_class_enforced					as StorageClassEnforced
		,	t.storage_unit_class_key					as StorageUnitClassKey
	from SrcMESCorp.Part t
	inner join DWTOPS.HubPart h on h.KeyPart = convert(varchar(64), t.part_number) + '^' + convert(varchar(64), t.part_revision)
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimPart)

	if not exists (select * from DWTOPS.DimPart where SKPart = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.DimPart (
				SKPart
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyPart
			,	PartNumber
			,	PartRevision
			,	PartDescription
			,	PartCategory
			,	ImageKey
			,	InstListKey
			,	BOMName
			,	BOMRevision
			,	PartQuantity
			,	ConsumptionDuration
			,	ConsumptionType
			,	BOMTrackedMode
			,	Revived
			,	ShelfLife
			,	WarrantyPeriod
			,	UnitOfMeasure
			,	PartExtRevision
			,	ReplacementType
			,	CarrierClassKey
			,	LogicallyEmptyQuantity
			,	MixingType
			,	StorageClassEnforced
			,	StorageUnitClassKey
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
			,	'N/A'
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	'N/A'
			,	null
			,	null
			,	-1
			,	-1
			,	null
			,	'N/A'
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
		)
	end

	update DWTOPS.DimPart
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchId
		,	DWHash = src.DWHash
		,	PartNumber = src.PartNumber
		,	PartRevision = src.PartRevision
		,	PartDescription = src.PartDescription
		,	PartCategory = src.PartCategory
		,	ImageKey = src.ImageKey
		,	InstListKey = src.InstListKey
		,	BOMName = src.BOMName
		,	BOMRevision = src.BOMRevision
		,	PartQuantity = src.PartQuantity
		,	ConsumptionDuration = src.ConsumptionDuration
		,	ConsumptionType = src.ConsumptionType
		,	BOMTrackedMode = src.BOMTrackedMode
		,	Revived = src.Revived
		,	ShelfLife = src.ShelfLife
		,	WarrantyPeriod = src.WarrantyPeriod
		,	UnitOfMeasure = src.UnitOfMeasure
		,	PartExtRevision = src.PartExtRevision
		,	ReplacementType = src.ReplacementType
		,	CarrierClassKey = src.CarrierClassKey
		,	LogicallyEmptyQuantity = src.LogicallyEmptyQuantity
		,	MixingType = src.MixingType
		,	StorageClassEnforced = src.StorageClassEnforced
		,	StorageUnitClassKey = src.StorageUnitClassKey
	from #TempDimPart src
	where DWTOPS.DimPart.SKPart = src.SKPart
		and DWTOPS.DimPart.DWHash != src.DWHash
	option (label = 'DWTOPS.LoadDimPart_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimPart_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimPart (
			SKPart
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyPart
		,	PartNumber
		,	PartRevision
		,	PartDescription
		,	PartCategory
		,	ImageKey
		,	InstListKey
		,	BOMName
		,	BOMRevision
		,	PartQuantity
		,	ConsumptionDuration
		,	ConsumptionType
		,	BOMTrackedMode
		,	Revived
		,	ShelfLife
		,	WarrantyPeriod
		,	UnitOfMeasure
		,	PartExtRevision
		,	ReplacementType
		,	CarrierClassKey
		,	LogicallyEmptyQuantity
		,	MixingType
		,	StorageClassEnforced
		,	StorageUnitClassKey
	)
	select	src.SKPart
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyPart
		,	src.PartNumber
		,	src.PartRevision
		,	src.PartDescription
		,	src.PartCategory
		,	src.ImageKey
		,	src.InstListKey
		,	src.BOMName
		,	src.BOMRevision
		,	src.PartQuantity
		,	src.ConsumptionDuration
		,	src.ConsumptionType
		,	src.BOMTrackedMode
		,	src.Revived
		,	src.ShelfLife
		,	src.WarrantyPeriod
		,	src.UnitOfMeasure
		,	src.PartExtRevision
		,	src.ReplacementType
		,	src.CarrierClassKey
		,	src.LogicallyEmptyQuantity
		,	src.MixingType
		,	src.StorageClassEnforced
		,	src.StorageUnitClassKey
	from #TempDimPart src
	where not exists(select * from DWTOPS.DimPart dst where dst.SKPart = src.SKPart)
	option (label = 'DWTOPS.LoadDimPart_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimPart_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
