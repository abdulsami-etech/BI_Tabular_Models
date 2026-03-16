CREATE PROC [DWIRIS].[LoadSatLink_ScannerWand] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS

BEGIN

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0


	IF OBJECT_ID('tempdb..#TmpSatLink_ScannerWandMES') IS NOT NULL DROP TABLE #TmpSatLink_ScannerWandMES

	CREATE TABLE #TmpSatLink_ScannerWandMES WITH (DISTRIBUTION = ROUND_ROBIN)
	AS
	SELECT 		
			CONVERT(binary(32),HASHBYTES('SHA2_256',
						    isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'
						   +isnull(convert(nvarchar,hw.KeyWand),'')))						as [HashScannerWandKey],
			t.[ADLSTimeStamp]																	as [InsertDateTime],
			'MES'																			as [SourceSystem],
			CONVERT(binary(32),HASHBYTES('SHA2_256',
					isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'+
					isnull(convert(nvarchar,hw.KeyWand),'')+N'^'+
					isnull(convert(nvarchar,t.[EventName]),'')+N'^'+
					isnull(convert(nvarchar,t.[EventDate]),'')+N'^'
					))																		as HashDiff,
			
			t.[EventName]																	as [EventName],
			t.[EventDate]																	as [EventDate],
			hs.[KeyScanner]																	as [KeyScanner],
			hw.[KeyWand]																	as [KeyWand],
			hs.[KeyScanner]																	as [SystemKey]
	FROM 
		(
				select	
					[object_name]																as [WandSN],
					[paringUnit]																as [ScannerSN],
					[ADLSTimestamp]																as [ADLSTimestamp],
					'Pairing'																	as [EventName],
					dateadd(hh,-7,[creation_time])												as [EventDate],
					ROW_NUMBER() OVER(PARTITION BY [object_name] ORDER BY [creation_time] ASC)	as num
				from [SrcMES_Itero].[DC_isr_CI_RTH_Paring]
				where 
					isnull(paringUnit,'') <> '' and testStatus = 'Pass'
			) t
		inner join DWIRIS.HubWand hw
			on t.[WandSN] = hw.KeyWand and hw.SourceSystem = 'MES' and t.num = 1
		inner join DWIRIS.HubScanner hs
			on t.[ScannerSN] = hs.KeyScanner and hs.SourceSystem = 'MES'


				INSERT INTO [DWIRIS].[SatLink_ScannerWand]
				(
					[HashScannerWandKey] ,
					[InsertDateTime] ,
					[SourceSystem],
					[HashDiff],
					[EventName],
					[EventDate],
					[KeyScanner],
					[KeyWand],
					[SystemKey]
				)
				SELECT
					t.[HashScannerWandKey] ,
					t.[InsertDateTime] ,
					t.[SourceSystem],
					t.[HashDiff],
					t.[EventName],
					t.[EventDate],
					t.[KeyScanner],
					t.[KeyWand],
					t.[SystemKey]
				FROM #TmpSatLink_ScannerWandMES t
					left outer join [DWIRIS].[SatLink_ScannerWand] sat on t.HashDiff=sat.HashDiff and t.SourceSystem = 'MES'
				where sat.HashDiff is null

-- SFDC
-- Shipment and Installation

IF OBJECT_ID('tempdb..#TmpDOA') IS NOT NULL 
	DROP TABLE #TmpDOA;

-- parent_id list

WITH parent 
     AS (SELECT parentid, 
                pgi_date__c 
         FROM   (SELECT AssOrig.parentid, 
                        AssOrig.pgi_date__c 
                 FROM   [SrcSFDC].[assetrelationship] Rela 
                        INNER JOIN [SrcSFDC].[asset] AssOrig 
                                ON Rela.assetid = AssOrig.id 
                        INNER JOIN [SrcSFDC].[asset] AssRepla 
                                ON Rela.relatedassetid = AssRepla.id 
                 WHERE  AssOrig.asset_type__c <> 'SCANNER' 
                        AND AssRepla.asset_type__c <> 'SCANNER') t 
         GROUP  BY parentid, 
                   pgi_date__c 
         HAVING Count(*) > 1) 
SELECT Rela.ADLSTimeStamp, 
       AssOrig.ParentId, 
       AssOrig.serialnumber, 
       AssOrig.pgi_date__c, 
       AssOrig.asset_type__c, 
       Rela.createddate 
INTO   #tmpdoa 
FROM   [SrcSFDC].[Assetrelationship] Rela 
       INNER JOIN [SrcSFDC].[asset] AssOrig 
               ON Rela.assetid = AssOrig.id 
       INNER JOIN [SrcSFDC].[asset] AssRepla 
               ON Rela.relatedassetid = AssRepla.id 
       LEFT JOIN parent p 
              ON p.parentid = AssOrig.parentid 
                 AND AssOrig.pgi_date__c = p.pgi_date__c 
WHERE  p.parentid IS NOT NULL; 


IF OBJECT_ID('tempdb..#TmpSatLink_ScannerWandSFDC') IS NOT NULL DROP TABLE #TmpSatLink_ScannerWandSFDC

CREATE TABLE #TmpSatLink_ScannerWandSFDC WITH (DISTRIBUTION = ROUND_ROBIN)
	AS
	SELECT 		
			CONVERT(binary(32),HASHBYTES('SHA2_256',
						    isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'
						   +isnull(convert(nvarchar,hw.KeyWand),'')))						as [HashScannerWandKey],
			[ADLSTimeStamp]																	as [InsertDateTime],
			'SFDC'																			as [SourceSystem],
			CONVERT(binary(32),HASHBYTES('SHA2_256',
					isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'+
					isnull(convert(nvarchar,hw.KeyWand),'')+N'^'+
					isnull(convert(nvarchar,t.[EventName]),'')+N'^'+
					isnull(convert(nvarchar,t.[EventDate]),'')+N'^'
					))																		as [HashDiff],
			
			t.[EventName]																	as [EventName],
			t.[EventDate]																	as [EventDate],
			hs.[KeyScanner]																	as [KeyScanner],
			hw.[KeyWand]																	as [KeyWand],
			hs.[KeyScanner]																	as [SystemKey]
	FROM 
		(
		/* Shipment */
		    select 
					w.ADLSTimestamp,
					w.SerialNumber														as [WandSN], 
					s.SerialNumber														as [ScannerSN], 
					'Shipped'															as [EventName],
					s.PGI_Date__c														as [EventDate]
			from [SrcSFDC].[Asset] W
			inner join [SrcSFDC].[Asset] S 
				on w.ParentId = s.ParentId
			where 
				w.Asset_Type__c in ('WAND') and s.Asset_Type__c in ('BASEUNIT')
				and (isnull(s.Asset_Kind__c,'') in ('NEW') or isnull(w.Asset_Kind__c,'') in ('NEW'))
			   and s.PGI_Date__c is not null

			UNION ALL
			
		/* DOA */
				select  
					wand.ADLSTimestamp,
					wand.SerialNumber													as [WandSN], 
					scan.SerialNumber													as [ScannerSN],  
					'Replacement'														as EventName,
					wand.CreatedDate													as EventDate
			    from #TmpDOA wand
				JOIN #TmpDOA scan
					on wand.ParentId = scan.ParentId and scan.Asset_Type__c = 'BASEUNIT'
				where wand.Asset_Type__c = 'WAND'

				UNION ALL

		 /* Wand Replacement */

				select 
					Rela.ADLSTimestamp,
					AssOrig.SerialNumber 												as [WandSN], 
					AssReplaBaseUnit.SerialNumber										as [ScannerSN], 
					'Replacement'														as EventName,
					Rela.CreatedDate													as EventDate
				from [SrcSFDC].[AssetRelationship] Rela
				inner join [SrcSFDC].[Asset] AssOrig 
					on Rela.assetid=AssOrig.id
				inner join [SrcSFDC].[Asset] AssRepla 
					on Rela.RelatedAssetId=AssRepla.id
				inner join [SrcSFDC].[Asset] AssReplaBaseUnit
					on AssReplaBaseUnit.ParentId = AssRepla.ParentId
				LEFT JOIN (select distinct ParentID, PGI_Date__c from #TmpDOA ) doa
					on doa.ParentID = AssOrig.ParentID and doa.PGI_Date__c = AssOrig.PGI_Date__c 
				where AssRepla.Asset_Type__c = 'WAND'
				and AssReplaBaseUnit.Asset_Type__c = 'BASEUNIT'
				and doa.ParentID is null

				UNION ALL
				
		/* BaseUnit Replacement */

				select 
					Rela.ADLSTimestamp,
					AssReplaWand.SerialNumber 											as [WandSN], 
					AssOrig.SerialNumber												as [ScannerSN], 
					'Replacement'														as EventName,
					Rela.CreatedDate													as EventDate
				from [SrcSFDC].[AssetRelationship] Rela
				inner join [SrcSFDC].[Asset] AssOrig 
					on Rela.assetid=AssOrig.id
				inner join [SrcSFDC].[Asset] AssRepla 
					on Rela.RelatedAssetId=AssRepla.id
				inner join [SrcSFDC].[Asset] AssReplaWand
					on AssReplaWand.ParentId = AssRepla.ParentId
				LEFT JOIN (select distinct ParentID, PGI_Date__c from #TmpDOA ) doa
					on doa.ParentID = AssOrig.ParentID and doa.PGI_Date__c = AssOrig.PGI_Date__c 
				where AssRepla.Asset_Type__c = 'BASEUNIT'
				and AssReplaWand.Asset_Type__c = 'WAND'
				and doa.ParentID is null
			) t
		inner join DWIRIS.HubWand hw
			on t.[WandSN] = hw.KeyWand and hw.SourceSystem = 'SFDC'
		inner join DWIRIS.HubScanner hs
			on t.[ScannerSN] = hs.KeyScanner and hs.SourceSystem = 'SFDC'
			
INSERT INTO [DWIRIS].[SatLink_ScannerWand]
	(
		[HashScannerWandKey] ,
		[InsertDateTime] ,
		[SourceSystem],
		[HashDiff],
		[EventName],
		[EventDate],
		[KeyScanner],
		[KeyWand],
		[SystemKey]
	)
	SELECT
		t.[HashScannerWandKey] ,
		t.[InsertDateTime] ,
		t.[SourceSystem],
		t.[HashDiff],
		t.[EventName],
		t.[EventDate],
		t.[KeyScanner],
		t.[KeyWand],
		t.[SystemKey]
	FROM #TmpSatLink_ScannerWandSFDC t
		left outer join [DWIRIS].[SatLink_ScannerWand] sat on t.HashDiff=sat.HashDiff and t.SourceSystem = 'SFDC'
	where sat.HashDiff is null


-- MAT
-- Installation

IF OBJECT_ID('tempdb..#TmpSatLink_ScannerWandMAT') IS NOT NULL DROP TABLE #TmpSatLink_ScannerWandMAT;

CREATE TABLE #TmpSatLink_ScannerWandMAT WITH (DISTRIBUTION = ROUND_ROBIN)
	AS
	SELECT 		
			CONVERT(binary(32),HASHBYTES('SHA2_256',
						    isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'
						   +isnull(convert(nvarchar,hw.KeyWand),'')))						as [HashScannerWandKey],

			[ADLSTimeStamp]																	as [InsertDateTime],
			'MAT'																			as [SourceSystem],
			CONVERT(binary(32),HASHBYTES('SHA2_256',
					isnull(convert(nvarchar,hs.KeyScanner),'')+N'^'+
					isnull(convert(nvarchar,hw.KeyWand),'')+N'^'+
					isnull(convert(nvarchar,t.[EventName]),'')+N'^'+
					isnull(convert(nvarchar,t.[EventDate]),'')+N'^'
					))																		as HashDiff,
			
			t.[EventName]																	as [EventName],
			t.[EventDate]																	as [EventDate],
			hs.[KeyScanner]																	as [KeyScanner],
			hw.[KeyWand]																	as [KeyWand],
			hs.[KeyScanner]																	as [SystemKey]
	FROM 
		(
		    select 
					Resc.ADLSTimestamp,
					Base_Unit.EmbeddedHeadSN											as [WandSN], 
					Resc.ResourceName													as [ScannerSN], 
					'Installation'														as [EventName],
					Resc.DateCreated													as [EventDate]
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

INSERT INTO [DWIRIS].[SatLink_ScannerWand]
	(
		[HashScannerWandKey] ,
		[InsertDateTime] ,
		[SourceSystem],
		[HashDiff],
		[EventName],
		[EventDate],
		[KeyScanner],
		[KeyWand],
		[SystemKey]
	)
	SELECT
		t.[HashScannerWandKey] ,
		t.[InsertDateTime] ,
		t.[SourceSystem],
		t.[HashDiff],
		t.[EventName],
		t.[EventDate],
		t.[KeyScanner],
		t.[KeyWand],
		t.[SystemKey]
	FROM #TmpSatLink_ScannerWandMAT t
		left outer join [DWIRIS].[SatLink_ScannerWand] sat on t.HashDiff=sat.HashDiff and t.SourceSystem = 'MAT'
	where sat.HashDiff is null

	BEGIN TRY  
     DROP TABLE [DWIRIS].TmpSatLink_ScannerWand; 
	END TRY  
	BEGIN CATCH  
	END CATCH

	CREATE TABLE [DWIRIS].TmpSatLink_ScannerWand WITH (DISTRIBUTION = ROUND_ROBIN, CLUSTERED INDEX (HashScannerWandKey))
	AS
	SELECT 	
		t.[HashScannerWandKey] ,
		t.[InsertDateTime] ,
		t.[SourceSystem],
		t.[HashDiff],
		t.[EventName],
		t.[EventDate],
		t.[KeyScanner],
		t.[KeyWand],
		t.[SystemKey],
		convert(datetime,NULL) as EventCloseDate,
		convert(nvarchar(255),null) as CurrentStatus
	from [DWIRIS].[SatLink_ScannerWand] t
	where 1=0;

	insert into [DWIRIS].TmpSatLink_ScannerWand
	SELECT 	
		[HashScannerWandKey] ,
		[InsertDateTime] ,
		[SourceSystem],
		[HashDiff],
		[EventName],
		[EventDate],
		[KeyScanner],
		[KeyWand],
		[SystemKey],
		LEAD (EventDate) OVER (PARTITION BY SystemKey ORDER BY EventDate ASC ) as EventCloseDate,
		LAST_VALUE ([EventName])  OVER ( PARTITION BY SystemKey ORDER BY SystemKey ) as CurrentStatus
	from [DWIRIS].[SatLink_ScannerWand]
	
	select count(*) as RowsInserted, @RowsUpdated as RowsUpdated from [DWIRIS].[SatLink_ScannerWand]

	BEGIN TRY  
     	DROP TABLE [DWIRIS].SatLink_ScannerWand1; 
	END TRY  
	BEGIN CATCH  
	END CATCH	

	RENAME OBJECT [DWIRIS].[SatLink_ScannerWand] TO [SatLink_ScannerWand1];

	RENAME OBJECT [DWIRIS].TmpSatLink_ScannerWand TO [SatLink_ScannerWand];

	drop table [DWIRIS].[SatLink_ScannerWand1];


end