CREATE PROC [DWIRIS].[LoadSATWandMAT] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempSATWandMAT') is not null
		drop table #TempSATWandMAT


-- Get delta rows
	create table #TempSATWandMAT with (distribution = round_robin, heap) as 
	select	
			has.[SKWand]														as [SKWand]
		,	s.ADLSTimestamp														as [ADLSTimestamp]
		,	convert(char(40), '')												as [DWHash]
		,	s.SerialIdentifier													as [KeyWand]
		,	convert(nvarchar(255),Wand.EquipmentCardID)							as [WandID]
		,	s.DateCreated														as [CreatedDate]
		,	Wand.Model															as [WandModel]
from [SrcMAT].[svc_EquipmentCard] s
	inner join [SrcMAT].[Wand] 
			on s.EquipmentCardID = Wand.EquipmentCardID
   inner JOIN [DWIRIS].[HubWand] has
		on has.KeyWand = s.SerialIdentifier and SourceSystem = 'MAT'
   where s.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.Sat_WandMAT) 

   
		
	--update HASH
	update #TempSATWandMAT set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						 convert(nvarchar,ISNULL([KeyWand],''))
					+'|'+convert(nvarchar,ISNULL([WandID],''))
					+'|'+convert(nvarchar,ISNULL([CreatedDate],''))
					+'|'+convert(nvarchar,ISNULL([WandModel],''))
					
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[Sat_WandMAT] where SKWand = -1)
	begin
		declare @Hash char(40) = ''

		--set identity_insert DWIRIS.DimWand on
		insert into [DWIRIS].[Sat_WandMAT] (
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
	insert into [DWIRIS].[Sat_WandMAT] (
	
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

	from #TempSATWandMAT src
	left join [DWIRIS].[Sat_WandMAT] dst 
		on dst.SKWand = src.SKWand and dst.DWHash = src.DWHash
	where dst.SKWand is null
	option (label = 'DWIRIS.LoadSATWandMAT_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadSATWandMAT_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end --procedure