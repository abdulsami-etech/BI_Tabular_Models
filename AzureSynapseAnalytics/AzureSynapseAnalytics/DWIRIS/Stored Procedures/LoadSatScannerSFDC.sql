CREATE PROC [DWIRIS].[LoadSATScannerSFDC] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempSATScannerSFDC') is not null
		drop table #TempSATScannerSFDC


-- Get delta rows
	create table #TempSATScannerSFDC with (distribution = round_robin, heap) as 
	select	
			has.[SKScanner]														as [SKScanner]
		,	a.ADLSTimestamp														as [ADLSTimestamp]
		,	convert(char(40), '')												as [DWHash]
		,	a.SerialNumber														as [KeyScanner]
		,	a.Id																as [ScannerID]
		,	a.CreatedDate														as [CreatedDate]
		,	convert(nvarchar(255), pr.[Name])									as [ScannerModel]
from [SrcSFDC].[Asset] a
	inner JOIN [DWIRIS].[HubScanner] has
		on has.KeyScanner = a.SerialNumber and has.SourceSystem = 'SFDC'
	left join SrcSFDC.Product2 pr
		on pr.Id = a.Product2Id
   where 
		a.ID is not null 
		and a.Asset_Type__c = 'BASEUNIT' 
		and a.Asset_Kind__c = 'NEW'
		and isnull(a.SerialNumber,'') <> ''
		and a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.Sat_ScannerSFDC)
   	
	--update HASH
	update #TempSATScannerSFDC set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						 convert(nvarchar,ISNULL([KeyScanner],''))
					+'|'+convert(nvarchar,ISNULL([ScannerID],''))
					+'|'+convert(nvarchar,ISNULL([CreatedDate],''))
					+'|'+convert(nvarchar,ISNULL([ScannerModel],''))
					
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[Sat_ScannerSFDC] where SKScanner = -1)
	begin
		declare @Hash char(40) = ''


		--set identity_insert DWIRIS.DimWand on
		insert into [DWIRIS].[Sat_ScannerSFDC] (
				[SKScanner],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyScanner],
				[ScannerID],
				[CreatedDate],
				[ScannerModel]
		)
		values (
				-1					-- SKScanner
			,	'19000101'			-- ADLSTimestamp
			,	@Hash				-- DWHash
			,	-1					-- DWBatchID
			,	'N/A'				-- KeyScanner
			,	'N/A'				-- ScannerID
			,	'19000101'			-- CreatedDate
			,	'N/A'				-- ScannerModel

		)
		--set identity_insert DWIRIS.DimWand off;
	end
	--  End  createing unknow element


	--INSERT new rows (new SKScanner appeared)
	insert into [DWIRIS].[Sat_ScannerSFDC] (
	
				[SKScanner]
			,	[ADLSTimestamp]
			,	[DWHash]
			,	[DWBatchID]
			,	[KeyScanner]
			,	[ScannerID]
			,	[CreatedDate]
			,	[ScannerModel]
		   )
	select 
				src.[SKScanner]
			,	src.[ADLSTimestamp]
			,	src.[DWHash]
			,	@BatchID
			,	src.[KeyScanner]
			,	src.[ScannerID]
			,	src.[CreatedDate]
			,	src.[ScannerModel]

	from #TempSATScannerSFDC src
	left join [DWIRIS].[Sat_ScannerSFDC] dst
		on dst.SKScanner = src.SKScanner and dst.DWHash = src.DWHash
	where dst.SKScanner is null
	option (label = 'DWIRIS.LoadSATScannerSFDC_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadSATScannerSFDC_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure