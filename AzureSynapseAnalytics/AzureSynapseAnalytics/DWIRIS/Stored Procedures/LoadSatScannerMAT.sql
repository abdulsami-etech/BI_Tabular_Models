CREATE PROC [DWIRIS].[LoadSATScannerMAT] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempSATScannerMAT') is not null
		drop table #TempSATScannerMAT


-- Get delta rows
	create table #TempSATScannerMAT with (distribution = round_robin, heap) as 
	select	
			has.[SKScanner]														as [SKScanner]
		,	s.ADLSTimestamp														as [ADLSTimestamp]
		,	convert(char(40), '')												as [DWHash]
		,	s.SerialIdentifier													as [KeyScanner]
		,	convert(nvarchar(255),Scanner.EquipmentCardID)						as [ScannerID]
		,	s.DateCreated														as [CreatedDate]
		,	sm.ScannerModelDescription											as [ScannerModel]
		,	isnull(holder.BusinessPartnerID, 0)									as [HolderID]
		,	isnull(holder.BusinessPartnerName, '')								as [HolderName]
		,	isnull(ownr.BusinessPartnerID, 0)									as [OwnerID]
		,	isnull(ownr.BusinessPartnerName, 'N/A')								as [OwnerName]
		,	isnull(lastreg.RegisteredToId,0)									as [RegisteredToId]
		,	isnull(lastreg.RegisteredToName, 'N/A')								as [RegisteredToName]
		,	lastreg.RegistrationDate											as [RegistrationDate]

from [SrcMAT].[svc_EquipmentCard] s
	inner join [SrcMAT].[Scanner] 
			on s.EquipmentCardID = Scanner.EquipmentCardID
	left join [SrcMAT].[ScannerModels] sm
		on [Scanner].ScannerModelId = sm.ScannerModelId
    inner JOIN [DWIRIS].[HubScanner] has
		on has.KeyScanner = s.SerialIdentifier and SourceSystem = 'MAT'
	/* holder */
	left join SrcMAT.BusinessPartner holder 
		on holder.BusinessPartnerID = s.HolderBusinessPartnerID
	/* owner */
	left join SrcMAT.BusinessPartner ownr 
		on ownr.BusinessPartnerID = s.SoldToBusinessPartnerID
	/* register */
	left join (
		select 
			ResourceSerialIdentifier,
			RegistrationDate,
			RegisteredToId,
			RegisteredToName
			 from (
		select		  res.ResourceSerialIdentifier
					, RegistrationDate = res.DateCreated
					, RegisteredToName = bp1.BusinessPartnerName1
					, RegisteredToId = bp1.BusinessPartnerID
					, row_number() OVER(PARTITION BY res.ResourceSerialIdentifier ORDER BY res.DateCreated DESC) as rnum
			from SrcMAT.Resources res
			join SrcMAT.BusinessPartner_BusinessPartnerTypeLink typ
				on res.ResourcePartnerID = typ.BusinessPartnerID
			join SrcMAT.BusinessPartner bp1
				on bp1.BusinessPartnerID = typ.BusinessPartnerID
				where BusinessPartnerTypeID in (/*100,*/ 200)	-- Orthodontic Office
	/* check with Rotem*/
			and res.RowStatusID = 1	
		) 	 t
		where t.rnum = 1
		) lastreg
		on s.SerialIdentifier = lastReg.ResourceSerialIdentifier


   where s.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.Sat_ScannerMAT) 

   
		
	--update HASH
	update #TempSATScannerMAT set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						 convert(nvarchar,ISNULL([KeyScanner],''))
					+'|'+convert(nvarchar,ISNULL([ScannerID],''))
					+'|'+convert(nvarchar,ISNULL([CreatedDate],''))
					+'|'+convert(nvarchar,ISNULL([ScannerModel],''))
					+'|'+convert(nvarchar,ISNULL([HolderID],''))
					+'|'+convert(nvarchar,ISNULL([HolderName],''))
					+'|'+convert(nvarchar,ISNULL([OwnerID],''))
					+'|'+convert(nvarchar,ISNULL([OwnerName],''))
					+'|'+convert(nvarchar,ISNULL([RegisteredToId],''))
					+'|'+convert(nvarchar,ISNULL([RegisteredToName],''))
					+'|'+convert(nvarchar,ISNULL([RegistrationDate],''))
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[Sat_ScannerMAT] where SKScanner = -1)
	begin
		declare @Hash char(40) = ''


		--set identity_insert DWIRIS.DimWand on
		insert into [DWIRIS].[Sat_ScannerMAT] (
				[SKScanner],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyScanner],
				[ScannerID],
				[CreatedDate],
				[ScannerModel],
				[HolderID],
				[HolderName],
				[OwnerID],
				[OwnerName],
				[RegisteredToId],
				[RegisteredToName],
				[RegistrationDate]
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
			,	-1					-- HolderID
			,	'N/A'				-- HolderName
			,	-1					-- OwnerID
			,	'N/A'				-- OwnerName
			,	-1					-- RegisteredToID
			,	'N/A'				-- RegisteredToName
			,	'19000101'			-- RegistrationDate
		)
		--set identity_insert DWIRIS.DimWand off;
	end
	--  End  createing unknow element

	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	
	
	
	insert into [DWIRIS].[Sat_ScannerMAT] (
				[SKScanner],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyScanner],
				[ScannerID],
				[CreatedDate],
				[ScannerModel],
				[HolderID],
				[HolderName],
				[OwnerID],
				[OwnerName],
				[RegisteredToId],
				[RegisteredToName],
				[RegistrationDate]
		)

		select 
				src.[SKScanner],
				src.[ADLSTimestamp],
				src.[DWHash],
				@BatchID,
				src.[KeyScanner],
				src.[ScannerID],
				src.[CreatedDate],
				src.[ScannerModel],
				src.[HolderID],
				src.[HolderName],
				src.[OwnerID],
				src.[OwnerName],
				src.[RegisteredToId],
				src.[RegisteredToName],
				src.[RegistrationDate]

	from #TempSATScannerMAT src
	left join [DWIRIS].[Sat_ScannerMAT] dst
		on dst.SKScanner = src.SKScanner and dst.DWHash = src.DWHash
	where dst.SKScanner is null
	option (label = 'DWIRIS.LoadSATScannerMAT_Insert');
		
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadSATScannerMAT_Insert', @rc = @RowsInserted out
	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

	CREATE TABLE #TempSATScannerMAT_result WITH (DISTRIBUTION = ROUND_ROBIN)
	AS
	SELECT 	
				[SKScanner],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyScanner],
				[ScannerID],
				[CreatedDate],
				[ScannerModel],
				[HolderID],
				[HolderName],
				[OwnerID],
				[OwnerName],
				[RegisteredToId],
				[RegisteredToName],
				[RegistrationDate],
				row_number() OVER ( PARTITION BY [KeyScanner] ORDER BY [RegistrationDate] DESC, [ADLSTimestamp] DESC ) as RegistrationOrder
	from [DWIRIS].[Sat_ScannerMAT]

	truncate table [DWIRIS].[Sat_ScannerMAT]
	insert into [DWIRIS].[Sat_ScannerMAT]
	(
		[SKScanner],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyScanner],
				[ScannerID],
				[CreatedDate],
				[ScannerModel],
				[HolderID],
				[HolderName],
				[OwnerID],
				[OwnerName],
				[RegisteredToId],
				[RegisteredToName],
				[RegistrationDate],
				[RegistrationOrder]
	)
	SELECT 	
		[SKScanner],
				[ADLSTimestamp],
				[DWHash],
				[DWBatchID],
				[KeyScanner],
				[ScannerID],
				[CreatedDate],
				[ScannerModel],
				[HolderID],
				[HolderName],
				[OwnerID],
				[OwnerName],
				[RegisteredToId],
				[RegisteredToName],
				[RegistrationDate],
				[RegistrationOrder]
	from #TempSATScannerMAT_result

end --procedure