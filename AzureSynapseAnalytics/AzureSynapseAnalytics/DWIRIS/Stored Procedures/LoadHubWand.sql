CREATE PROC [DWIRIS].[LoadHubWand] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()


	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubWand
		where [SKWand] = -1
	)
	begin
		set identity_insert DWIRIS.HubWand on
		begin try
			insert into DWIRIS.HubWand (
					   [SKWand]
					 , [KeyWand]
					 , [SourceSystem]
					 , [DWBatchID]
					 , [InsertDateTime]
			)
			values (
					-1
				,	'N/A'
				,	'N/A'
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubWand off;
			throw
		end catch
		set identity_insert DWIRIS.HubWand off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubWand') is not null
		drop table #TempHubWand
		
	create table #TempHubWand
		(
			SerialNumber nvarchar(160),
			SourceSystem char (40)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubWand (SerialNumber, SourceSystem)
	select SerialNumber,SourceSystem from 
		(select distinct convert(nvarchar(160),a.[SerialNumber]) as SerialNumber, 'SFDC' as SourceSystem from [SrcSFDC].[Asset] a
		where a.Asset_Type__c = 'WAND' 
			UNION
		 select distinct convert(nvarchar(160),s.[SerialIdentifier]) as SerialNumber, 'MAT' as SourceSystem from [SrcMAT].[svc_EquipmentCard] s
		 inner join [SrcMAT].[Wand] sc
			on sc.[EquipmentCardID] = s.[EquipmentCardID]
		where isnull(convert(nvarchar(160),s.[SerialIdentifier]),'') <>''
			UNION
		select distinct convert(nvarchar(160),[SerialNumber]), 'MES' as SourceSystem FROM [SrcMES_Itero].[SrcFactWandStatus]
		 ) t

	
	

	--insert new keys to hub
	insert into DWIRIS.HubWand
	(
					 
					   [KeyWand]
					 , [SourceSystem]
					 , DWBatchID
					 , [InsertDateTime]
	)
	select #TempHubWand.SerialNumber, #TempHubWand.[SourceSystem], @BatchID, @dt from #TempHubWand 
	left join DWIRIS.HubWand hw
		on hw.KeyWand = #TempHubWand.SerialNumber and hw.SourceSystem = #TempHubWand.SourceSystem
	where hw.KeyWand is null and #TempHubWand.SerialNumber is not null
	option (label = 'DWIRIS.LoadHubWand');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubWand', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end