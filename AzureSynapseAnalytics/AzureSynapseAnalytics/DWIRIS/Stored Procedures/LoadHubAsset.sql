CREATE PROC [DWIRIS].[LoadHubAsset] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubAsset
		where [SKAsset] = -1
	)
	begin
		set identity_insert DWIRIS.HubAsset on
		begin try
			insert into DWIRIS.HubAsset (
					   [SKAsset]
					 , [KeyAsset]
					 , [DWBatchID]
					 , [InsertDateTime]
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubAsset off;
			throw
		end catch
		set identity_insert DWIRIS.HubAsset off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubAsset') is not null
		drop table #TempHubAsset
		
	create table #TempHubAsset
		(
			SerialNumber nvarchar(160)
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubAsset (SerialNumber)
	select SerialNumber from 
		(select distinct convert(nvarchar(160),a.[SerialNumber]) as SerialNumber from [SrcSFDC].[Asset] a
		where a.Asset_Type__c = 'SCANNER' 
			UNION
		 select distinct convert(nvarchar(160),s.[SerialIdentifier]) as SerialNumber from [SrcMAT].[svc_EquipmentCard] s
		 inner join [SrcMAT].[Scanner] sc
			on sc.[EquipmentCardID] = s.[EquipmentCardID]
		 ) t



	--insert new keys to hub
	insert into DWIRIS.HubAsset
	(
					 
					   [KeyAsset]
					 , [DWBatchID]
					 , [InsertDateTime]
	)
	select SerialNumber, @BatchID, @dt from #TempHubAsset where SerialNumber not in (select KeyAsset from DWIRIS.HubAsset)
	option (label = 'DWIRIS.LoadHubAsset');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubAsset', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end
