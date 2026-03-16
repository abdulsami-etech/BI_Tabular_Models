CREATE PROC [DWIRIS].[LoadDimVirtualProduct] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin

set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimVirtualProduct') is not null
		drop table #TempDimVirtualProduct

-- Get delta rows
	create table #TempDimVirtualProduct with (distribution = round_robin, heap) as 
	select 
	distinct
			hvp.SKVirtualProduct															as SKVirtualProduct
		,	vp.ADLSBatchID																	as ADLSBatchID
		,	vp.ADLSTimestamp																as ADLSTimestamp
		,	vp.LZBatchID																	as LZBatchID
		,	convert(char(40), '')															as DWHash
		,	ha.SKAsset																		as SKAsset
		,	vp.VirtualProductID																as KeyVirtualProduct
		,	vp.StartDate																	as StartDate
		,	convert(int, convert(char(8), vp.StartDate, 112))								as SKStartDate
		,	vp.ExpiryDate																	as ExpiryDate
		,	convert(int, convert(char(8), vp.ExpiryDate, 112))								as SKExpiryDate
		,	convert(smallint, vp.AutoRenewal)												as AutoRenewal
		,	vp.SerialCode																	as SerialCode
		,	cat.ItemCategoryGenericDescription												as Category
		,	isnull(items.ItemGenericDescription,'') + ' ' + isnull(i1.ItemGenericDescription,'') 	as TypeName
		,	isnull(i1.ItemGenericDescription,'')											as [Description]

	from (
				select top 1 with ties el.VirtualProductID, el.EquipmentCardID
				from SrcMAT.svc_VirtualProduct_EquipmentLink el (nolock)
				where el.rowstatusid = 1
				order by row_number() over (partition by el.VirtualProductID order by el.DateUpdated desc)
		 ) el
	inner join SrcMAT.svc_VirtualProduct vp on vp.virtualProductid = el.virtualProductid
	inner join (
				select ItemID as BundleItemID, ItemID 
				from SrcMAT.Items 
				union
				select BundleItemID, ItemID 
				from SrcMAT.BundleItem_ItemLink
				where RowStatusID = 1
			  ) c on c.BundleItemID = vp.ItemID
	inner join DWIRIS.HubVirtualProduct hvp
		on hvp.KeyVirtualProduct = vp.VirtualProductID
	LEFT JOIN SrcMAT.Items
	  ON Items.ItemID = vp.ItemID
	LEFT JOIN SrcMAT.Items i1
	  ON i1.ItemID = c.ItemID and i1.ItemCategoryID = 3300
	LEFT JOIN SrcMAT.ItemCategories cat
		on cat.ItemCategoryID = items.ItemCategoryID
	LEFT JOIN SrcMAT.svc_EquipmentCard ec
		on ec.EquipmentCardID = el.EquipmentCardID
	left join DWIRIS.HubAsset ha
		on ha.KeyAsset = convert(nvarchar(160), ec.SerialIdentifier)
	where vp.rowstatusid = 1
	
	
	-- update HASH
	update #TempDimVirtualProduct set DWHash=
		convert(char(40),
			hashbytes('SHA1',
								 convert(nvarchar,ISNULL(SKAsset,''))
							+'|'+convert(nvarchar,ISNULL(KeyVirtualProduct,''))
							+'|'+convert(nvarchar,ISNULL(StartDate,''))
							+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),SKStartDate),''))
							+'|'+convert(nvarchar,ISNULL(ExpiryDate,''))
							+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),SKExpiryDate),''))
							+'|'+convert(nvarchar,ISNULL(AutoRenewal,''))
							+'|'+convert(nvarchar,ISNULL(SerialCode,''))
							+'|'+convert(nvarchar,ISNULL(Category,''))
							+'|'+convert(nvarchar,ISNULL(TypeName,''))
							+'|'+convert(nvarchar,ISNULL([Description],''))
				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimVirtualProduct] where SKVirtualProduct = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWIRIS.DimVirtualProduct (
				 [SKVirtualProduct]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[SKAsset]
				,[KeyVirtualProduct]
				,[StartDate]
				,[SKStartDate]
				,[ExpiryDate]
				,[SKExpiryDate]
				,[AutoRenewal]
				,[SerialCode]
				,[Category]
				,[TypeName]
				,[Description]
		)
		values (
				-1					-- SKVirtualProduct
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash

			,	-1					-- SKAsset
			,	-1					-- KeyVirtualProduct
			,	'19000101'			-- StartDate
			,	19000101			-- SKStartDate
			,	'19000101'			-- ExpiryDate
			,	19000101			-- SKExpiryDate
			,	0					-- AutoRenewal
			,	N''					-- SerialCode
			,	N''					-- Category
			,	N''					-- TypeName
			,	N''					-- Description
		)
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimVirtualProduct]
	set
		   [ADLSBatchID] = src.[ADLSBatchID]
		,  [ADLSTimestamp] = src.[ADLSTimestamp]
		,  [LZBatchID] = src.[LZBatchID]
		,  [DWBatchID] = @BatchID
		,  [DWHash] = src.[DWHash]
		,  [SKAsset] = src.[SKAsset]
		,  [KeyVirtualProduct] = src.[KeyVirtualProduct]
		,  [StartDate] = src.[StartDate]
		,  [SKStartDate] = src.[SKStartDate]
		,  [ExpiryDate] = src.[ExpiryDate]
		,  [SKExpiryDate] = src.[SKExpiryDate]
		,  [AutoRenewal] = src.[AutoRenewal]
		,  [SerialCode] = src.[SerialCode]
		,  [Category] = src.[Category]
		,  [TypeName] = src.[TypeName]
		,  [Description] = src.[Description]
	from #TempDimVirtualProduct src
	where [DWIRIS].[DimVirtualProduct].SKVirtualProduct= src.SKVirtualProduct
	and [DWIRIS].[DimVirtualProduct].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimVirtualProduct_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimVirtualProduct_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimVirtualProduct] (
			[SKVirtualProduct]
           ,[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,[DWBatchID]
           ,[DWHash]
           ,[SKAsset]
           ,[KeyVirtualProduct]
           ,[StartDate]
           ,[SKStartDate]
           ,[ExpiryDate]
           ,[SKExpiryDate]
           ,[AutoRenewal]
           ,[SerialCode]
           ,[Category]
           ,[TypeName]
		   ,[Description]
	)
	select 
			[SKVirtualProduct]
		,	[ADLSBatchID]
		,	[ADLSTimestamp]
		,	[LZBatchID]
		,	@BatchID
		,	[DWHash]
		,	[SKAsset]
		,	[KeyVirtualProduct]
		,	[StartDate]
        ,	[SKStartDate]
        ,	[ExpiryDate]
        ,	[SKExpiryDate]
        ,	[AutoRenewal]
        ,	[SerialCode]
        ,	[Category]
        ,	[TypeName]
		,	[Description]

	from #TempDimVirtualProduct src
	where not exists(select dst.SKVirtualProduct from DWIRIS.DimVirtualProduct dst where dst.SKVirtualProduct = src.SKVirtualProduct)
	option (label = 'DWIRIS.LoadDimVirtualProduct_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimVirtualProduct_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure