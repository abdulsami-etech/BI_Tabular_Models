CREATE PROC [DWIRIS].[LoadLinkScannerWand] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS

BEGIN

-- MES increment
	declare @RowsInserted int =0, @RowsUpdated int =0

if object_id('tempdb..#TempLinkScannerWandMES') is not null
		drop table #TempLinkScannerWandMES

	create table #TempLinkScannerWandMES WITH (DISTRIBUTION = ROUND_ROBIN) as 
	SELECT 			
			
			CONVERT(binary(32),HASHBYTES('SHA2_256',
						    isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'
						   +isnull(convert(nvarchar,hw.KeyWand),'')))					as [HashScannerWandKey],
			t.ADLSTimestamp																as [ADLSTimestamp],
			'MES'																		as [SourceSystem],
			hs.SKScanner																as [SKScanner],
			hw.SKWand																	as [SKWand],
			hs.KeyScanner																as [KeyScanner],
			hw.KeyWand																	as [KeyWand]
	
	FROM 
		   (
				select	
					[object_name]																as [WandSN],
					[paringUnit]																as [ScannerSN],
					[ADLSTimestamp]																as [ADLSTimestamp],
					ROW_NUMBER() OVER(PARTITION BY [object_name] ORDER BY [creation_time] ASC)	as num
				from [SrcMES_Itero].[DC_isr_CI_RTH_Paring]
				where 
					isnull(paringUnit,'') <> '' and testStatus = 'Pass'
			) t
		inner join DWIRIS.HubWand hw
			on t.[WandSN] = hw.KeyWand and hw.SourceSystem = 'MES' and t.num = 1
		inner join DWIRIS.HubScanner hs
			on t.[ScannerSN] = hs.KeyScanner and hs.SourceSystem = 'MES'
		left join [DWIRIS].[LinkScannerWand] lsq 
			on (t.[ScannerSN] = lsq.[KeyScanner] and t.[WandSN] = lsq.[KeyWand]) and lsq.[SourceSystem] = 'MES'
	WHERE lsq.[HashScannerWandKey] IS NULL

-- insert into link MES

	INSERT INTO [DWIRIS].[LinkScannerWand]
		(
			[HashScannerWandKey],
			[DWBatchID],
			[ADLSTimestamp],
			[SourceSystem],
			[SKScanner] ,
			[SKWand],
			[KeyScanner],
			[KeyWand]	
		)
	SELECT	
			[HashScannerWandKey],
			@BatchID,
			[ADLSTimestamp],
			[SourceSystem],
			[SKScanner],
			[SKWand],
			[KeyScanner],
			[KeyWand]
	from #TempLinkScannerWandMES


-- SFDC increment 

if object_id('tempdb..#TempLinkScannerWandSFDC') is not null
		drop table #TempLinkScannerWandSFDC;

	create table #TempLinkScannerWandSFDC with (distribution = round_robin) as 
	SELECT 			
			CONVERT(binary(32),HASHBYTES('SHA2_256',
						    isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'
						   +isnull(convert(nvarchar,hw.KeyWand),'')))					as [HashScannerWandKey],
			t.ADLSTimestamp																as [ADLSTimestamp],
			'SFDC'																		as [SourceSystem],
			hs.SKScanner																as [SKScanner],
			hw.SKWand																	as [SKWand],
			hs.KeyScanner																as [KeyScanner],
			hw.KeyWand																	as [KeyWand]
	
	FROM 
		   (
		    select distinct
					w.ADLSTimestamp,
					w.SerialNumber				as [WandSN], 
					s.SerialNumber 				as [ScannerSN] 
			from [SrcSFDC].[Asset] W
			inner join [SrcSFDC].[Asset] S 
				on w.ParentId = s.ParentId
			where 
				w.Asset_Type__c in ('WAND') and s.Asset_Type__c in ('BASEUNIT') 
			) t
		inner join DWIRIS.HubWand hw
			on t.[WandSN] = hw.KeyWand and hw.SourceSystem = 'SFDC'
		inner join DWIRIS.HubScanner hs
			on t.[ScannerSN] = hs.KeyScanner and hs.SourceSystem = 'SFDC'
		left join [DWIRIS].[LinkScannerWand] lsq 
			on (t.[ScannerSN] = lsq.[KeyScanner] and t.[WandSN] = lsq.[KeyWand])
	WHERE lsq.[HashScannerWandKey] IS NULL
	
	
-- insert into link SDFC
	INSERT INTO [DWIRIS].[LinkScannerWand]
		(
			[HashScannerWandKey],
			[DWBatchID],
			[ADLSTimestamp],
			[SourceSystem],
			[SKScanner] ,
			[SKWand],
			[KeyScanner],
			[KeyWand]	
		)
	SELECT	
			[HashScannerWandKey],
			@BatchID,
			[ADLSTimestamp],
			[SourceSystem],
			[SKScanner],
			[SKWand],
			[KeyScanner],
			[KeyWand]
	from #TempLinkScannerWandSFDC	





	-- MAT increment 

	if object_id('tempdb..#TempLinkScannerWandMAT') is not null
		drop table #TempLinkScannerWandMAT;

	create table #TempLinkScannerWandMAT with (distribution = round_robin) as 
	SELECT 			
			CONVERT(binary(32),HASHBYTES('SHA2_256',
						    isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'
						   +isnull(convert(nvarchar,hw.KeyWand),'')))					as [HashScannerWandKey],
			t.ADLSTimestamp																as [ADLSTimestamp],
			'MAT'																		as [SourceSystem],
			hs.SKScanner																as [SKScanner],
			hw.SKWand																	as [SKWand],
			hs.KeyScanner																as [KeyScanner],
			hw.KeyWand																	as [KeyWand]
	
	FROM 
		   (
		   select 
					Resc.ADLSTimestamp													as [ADLSTimestamp],
					Base_Unit.EmbeddedHeadSN											as [WandSN], 
					Resc.ResourceName													as [ScannerSN]
			from [SrcMAT].[Resources] Resc
			inner join [SrcMAT].[svc_EquipmentCard] EqiCard 
				on Resc.ResourceName=EqiCard.SerialIdentifier
			inner join [SrcMAT].[Scanner] Base_Unit 
				on EqiCard.EquipmentCardID=Base_Unit.EquipmentCardID
			where Resc.RowStatusID in (1,4) and isnull(Base_Unit.EmbeddedHeadSN,'')<> '' 
			) t
		inner join DWIRIS.HubWand hw
			on t.[WandSN] = hw.KeyWand and hw.SourceSystem = 'MAT'
		inner join DWIRIS.HubScanner hs
			on t.[ScannerSN] = hs.KeyScanner and hs.SourceSystem = 'MAT'
		left join [DWIRIS].[LinkScannerWand] lsq 
			on (t.[ScannerSN] = lsq.[KeyScanner] and t.[WandSN] = lsq.[KeyWand])
	WHERE lsq.[HashScannerWandKey] IS NULL


	-- insert into link MAT
	INSERT INTO [DWIRIS].[LinkScannerWand]
		(
			[HashScannerWandKey],
			[DWBatchID],
			[ADLSTimestamp],
			[SourceSystem],
			[SKScanner] ,
			[SKWand],
			[KeyScanner],
			[KeyWand]	
		)
	SELECT	
			[HashScannerWandKey],
			@BatchID,
			[ADLSTimestamp],
			[SourceSystem],
			[SKScanner],
			[SKWand],
			[KeyScanner],
			[KeyWand]
	from #TempLinkScannerWandMAT	
	option (label = 'DWIRIS.LoadLinkScannerWand_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadLinkScannerWand_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated



END