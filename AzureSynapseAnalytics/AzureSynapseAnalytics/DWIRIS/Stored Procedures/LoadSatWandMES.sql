CREATE PROC [DWIRIS].[LoadSATWandMES] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempSATWandMES') is not null
		drop table #TempSATWandMES


-- Get delta rows
	create table #TempSATWandMES with (distribution = round_robin, heap) as 
	select	
			has.[SKWand]														as [SKWand]
		,	a.ADLSTimestamp														as [ADLSTimestamp]
		,	convert(char(40), '')												as [DWHash]
		,	a.[SerialNumber]													as [KeyWand]
		,	convert(nvarchar(255),a.[UnitKey])									as [WandID]
		,	a.[CreationTime]													as [CreatedDate]
		,	a.ManufacturingCountry												as [ManufacturingCountry]
		,	a.Product															as [WandModel]
	FROM [SrcMES_Itero].[SrcFactWandStatus] as a 
	inner JOIN [DWIRIS].[HubWand] has
			on has.KeyWand = a.[SerialNumber] and SourceSystem = 'MES'
   where 
      a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.Sat_WandMES) 
		
	--update HASH
	update #TempSATWandMES set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						 convert(nvarchar,ISNULL([KeyWand],''))
					+'|'+convert(nvarchar,ISNULL([WandID],''))
					+'|'+convert(nvarchar,ISNULL([CreatedDate],''))
					+'|'+convert(nvarchar,ISNULL([ManufacturingCountry],''))
					+'|'+convert(nvarchar,ISNULL([WandModel],''))
				)
			,2)

			

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[Sat_WandMES] where SKWand = -1)
	begin
		declare @Hash char(40) = ''

		--set identity_insert DWIRIS.DimWand on
		insert into [DWIRIS].[Sat_WandMES] (
				[SKWand],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyWand],
				[WandID],
				[CreatedDate],
				[ManufacturingCountry],
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
			,	'N/A'				-- ManufacturingCountry
			,	'N/A'				-- WandModel

		)
		--set identity_insert DWIRIS.DimWand off;
	end
	--  End  createing unknow element



	--INSERT new rows
	insert into [DWIRIS].[Sat_WandMES] (
	
				[SKWand]
			,	[ADLSTimestamp]
			,	[DWHash]
			,	[DWBatchID]
			,	[KeyWand]
			,	[WandID]
			,	[CreatedDate]
			,	[ManufacturingCountry]
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
			,	src.[ManufacturingCountry]
			,	src.[WandModel]
	from #TempSATWandMES src
	left join [DWIRIS].[Sat_WandMES] dst 
		on dst.SKWand = src.SKWand and src.DWHash = dst.DWHash
	where dst.SKWand is null
	option (label = 'DWIRIS.LoadSATWandMES_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadSATWandMES_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end --procedure