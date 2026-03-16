CREATE PROC [DWIRIS].[LoadSATWandSFDC] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempSATWandSFDC') is not null
		drop table #TempSATWandSFDC

	
-- Get delta rows
	create table #TempSATWandSFDC with (distribution = round_robin, heap) as 
	select	
			has.SKWand															as [SKWand]
		,	a.ADLSTimestamp														as [ADLSTimestamp]
		,	convert(char(40), '')												as [DWHash]
		,	a.SerialNumber														as [KeyWand]
		,	a.Id																as [WandID]
		,	a.CreatedDate														as [CreatedDate]
		,	convert(nvarchar(255), NULL)										as [WandModel]
from [SrcSFDC].[Asset]  a
	inner JOIN [DWIRIS].[HubWand] has
		on has.KeyWand = a.SerialNumber and has.SourceSystem = 'SFDC'
	where 
			a.ID is not null 
		and a.Asset_Type__c = 'WAND' 
		and a.Asset_Kind__c = 'NEW'
		and isnull(a.SerialNumber,'') <> ''
		and a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from [DWIRIS].[Sat_WandSFDC])

		
	--update HASH
	update #TempSATWandSFDC set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						 convert(nvarchar,ISNULL([KeyWand],''))
					+'|'+convert(nvarchar,ISNULL([WandID],''))
					+'|'+convert(nvarchar,ISNULL([CreatedDate],''))
					+'|'+convert(nvarchar,ISNULL([WandModel],''))
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[Sat_WandSFDC] where SKWand = -1)
	begin
		declare @Hash char(40) = ''

		--set identity_insert DWIRIS.DimWand on
		insert into [DWIRIS].[Sat_WandSFDC] (
				[SKWand],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyWand],
				[WandID],
				[CreatedDate],
				[WandModel]
		)
		values (
				-1					-- SKWand
			,	'19000101'			-- ADLSTimestamp
			,	@Hash				-- DWHash
			,	-1					-- DWBatchID
			,	'N/A'				-- KeyWand
			,	'N/A'				-- WandID
			,	'19000101'			-- CreatedDate
			,	'N/A'				-- WandModel

		)
		--set identity_insert DWIRIS.DimWand off;
	end
	--  End  createing unknow element

	
	--INSERT new rows
	insert into [DWIRIS].[Sat_WandSFDC] (
	
				[SKWand]
			,	[ADLSTimestamp]
			,	[DWHash]
			,	[DWBatchID]
			,	[KeyWand]
			,	[WandID]
			,	[CreatedDate]
			,	[WandModel]
		   )
	select 
				src.[SKWand]
			,	src.[ADLSTimestamp]
			,	src.[DWHash]
			,	@BatchID
			,	src.[KeyWand]
			,	src.[WandID]
			,	src.[CreatedDate]
			,	src.[WandModel]

	from #TempSATWandSFDC src
	left join [DWIRIS].[Sat_WandSFDC] dst
		on dst.SKWand = src.SKWand and dst.DWHash = src.DWHash
	where dst.SKWand is null
	option (label = 'DWIRIS.LoadSATWandSFDC_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadSATWandSFDC_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end --procedure