CREATE PROC [DWIRIS].[LoadHubScanner] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubScanner
		where [SKScanner] = -1
	)
	begin
		set identity_insert DWIRIS.HubScanner on
		begin try
			insert into DWIRIS.HubScanner (
					   [SKScanner]
					 , [KeyScanner]
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
			set identity_insert DWIRIS.HubScanner off;
			throw
		end catch
		set identity_insert DWIRIS.HubScanner off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC and MES

	if object_id('tempdb..#TempHubScanner') is not null
		drop table #TempHubScanner
		
	create table #TempHubScanner
		(
			SerialNumber nvarchar(160),
			SourceSystem char(40)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubScanner (SerialNumber, SourceSystem)
	select SerialNumber, SourceSystem from 
		(select distinct convert(nvarchar(160),a.[SerialNumber]) as SerialNumber, 'SFDC' as SourceSystem from [SrcSFDC].[Asset] a
		where a.Asset_Type__c = 'BASEUNIT' 
			UNION
		 select distinct convert(nvarchar(160),s.[SerialIdentifier]) as SerialNumber, 'MAT' as SourceSystem from [SrcMAT].[svc_EquipmentCard] s
		 inner join [SrcMAT].[Scanner] sc
			on sc.[EquipmentCardID] = s.[EquipmentCardID]
		  UNION
		 select distinct convert(nvarchar(160),s.[paringUnit]) as SerialNumber, 'MES' as SourceSystem from [SrcMES_Itero].[DC_isr_CI_RTH_Paring] s
		 where isnull(paringUnit,'') <> '' and testStatus = 'Pass'
		 ) t

	--insert new keys to hub
	insert into DWIRIS.HubScanner
	(
					 
					   [KeyScanner]
					 , [SourceSystem]
					 , [DWBatchID]
					 , [InsertDateTime]
	)
	select tt.SerialNumber, tt.SourceSystem,@BatchId, @dt from #TempHubScanner tt
	
	left join DWIRIS.HubScanner hs
		on hs.[KeyScanner] = tt.SerialNumber and hs.SourceSystem = tt.SourceSystem
	where hs.[KeyScanner] is null and tt.SerialNumber is not null

	option (label = 'DWIRIS.LoadHubScanner');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubScanner', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end