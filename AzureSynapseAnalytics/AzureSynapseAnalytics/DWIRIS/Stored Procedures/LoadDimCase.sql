Create PROC [DWIRIS].[LoadDimCase] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin

	set nocount on
	set xact_abort on
		declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0


	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if not exists (select * from [DWIRIS].DimCase)
		set @IsFullLoad = 1

	if object_id ('[DWIRIS].[Temp_CaseToLoad]', 'U') is not null
		Drop table [DWIRIS].[Temp_CaseToLoad]

	create table [DWIRIS].[Temp_CaseToLoad] (SalesOrderHeaderID Int not null ) with (distribution = round_robin, heap)
	ALTER TABLE [DWIRIS].[Temp_CaseToLoad] ADD CONSTRAINT PK_Temp_CaseToLoad PRIMARY KEY NONCLUSTERED (SalesOrderHeaderID) NOT ENFORCED

	if @IsFullLoad = 0
	begin
		insert into [DWIRIS].[Temp_CaseToLoad] (SalesOrderHeaderID) 
		select sh.SalesOrderHeaderID
		from srcmat.SalesOrdersHeader sh --Header
		where sh.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		and sh.SalesOrderHeaderID is not null
		union
		select ce.OrderHeaderID
		from srcmat.Case_ExtendedInfo ce --HeaderExtended
		where ce.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		and ce.OrderHeaderID is not null
		union
		select sod.SalesOrderHeaderID
		from srcmat.SalesOrdersDetails sod ---OrderDetails
		where sod.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		and sod.SalesOrderHeaderID is not null
		union
		select wo.OrderID
		from  srcmat.WorkOrders wo ---workOrder
		where wo.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		and wo.OrderID is not null
		union
		select cs.SalesOrderHeaderID
		from srcmat.Case_ScanInfo cs				---ScanInfo
		where cs.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		and cs.SalesOrderHeaderID is not null
		union
		select ps.iTeroOrderID
		from SrcImages.Patient_assets ps				---ScanInfo
		where ps.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		and ps.iTeroOrderID is not null
		and ColorScan='True'
	end

	if object_id('DWIRIS.Temp_DimCase') is not null
		drop table [DWIRIS].Temp_DimCase

CREATE TABLE [DWIRIS].[Temp_DimCase]
(
	[SKCase] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NOT NULL,
	[KeyCase] [int] not null,
	[CaseCode] [varchar](12) NULL,
	[CaseTypeId] [smallint]  NULL,
	[CaseTypeName] [nvarchar](64) NULL,
	[IsIDX] [nchar](3) NOT NULL DEFAULT (N'No'),
	[IsIDE] [nchar](3) NOT NULL DEFAULT (N'No'),
	[IsInactive] [nchar](3) NOT NULL DEFAULT (N'No'),
	[IsWithoutMilling] [nchar](3) NOT NULL DEFAULT (N'No'),
	[IsDigital] [nvarchar](20) NOT NULL DEFAULT (N'Unknown'),
	[ScannerID] [int]  NULL,
	[ITeroVersion] [nvarchar](50)  NULL,
	[IsScannerKnown] [nchar](3)  NULL,
	[NumberOfModels] [tinyint]  NULL,
	[CaseDateCreated] [datetime]  NULL,
	[MillingSiteID] [int]  NULL,
	[InterpretationSiteID] [int]  NULL,
	[ModelingSiteID] [int]  NULL,
	[InitiatorPartnerID] [int] NULL,
	[InitiatorContactID] [int]  NULL,
	[ScanArrivalDate] [datetime] NULL,
	[CurrentBillOfWork] [int] NULL,
	[ProductTypeID] [tinyint] NULL,
	[DueDate] [datetime] NULL,
	[MaxDateUpdated] [datetime] NULL,
	[PartnerLabID] [int]  NULL,
	[InstrCode] [nvarchar](50)  NULL,
	[AnteriorPosterior] [nvarchar](9) NULL,
	[BaseUnitSN] varchar(50) NULL,
	[WandSN] varchar(50) NULL,
	[IsDirectToLab] varchar(10) NULL,
	[IsColorScan] char(3) NULL,
	[TotalColorScans] int
)
WITH
(
	DISTRIBUTION = HASH ( [SKCase] ),
	CLUSTERED COLUMNSTORE INDEX
)	
insert into DWIRIS.Temp_DimCase (
       [SKCase]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[DWHash]
	  ,[KeyCase]
      ,[CaseCode]
      ,[CaseTypeId]
      ,[CaseTypeName]
      ,[IsIDX]
      ,[IsIDE]
      ,[IsInactive]
      ,[IsWithoutMilling]
      ,[IsDigital]
      ,[ScannerID]
      ,[ITeroVersion]
      ,[IsScannerKnown]
      ,[NumberOfModels]
      ,[CaseDateCreated]
      ,[MillingSiteID]
      ,[InterpretationSiteID]
      ,[ModelingSiteID]
      ,[InitiatorPartnerID]
      ,[InitiatorContactID]
      ,[ScanArrivalDate]
      ,[CurrentBillOfWork]
      ,[ProductTypeID]
      ,[DueDate]
      ,[MaxDateUpdated]
      ,[PartnerLabID]
      ,[InstrCode]
      ,[AnteriorPosterior]
	  ,[BaseUnitSN]
	  ,[WandSN]
	  ,[IsDirectToLab]
	  ,[IsColorScan]
	  ,[TotalColorScans]
	  )
	  select 
	   [SKCase]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[DWHash]
	  ,[KeyCase]
      ,[CaseCode]
      ,[CaseTypeId]
      ,[CaseTypeName]
      ,[IsIDX]
      ,[IsIDE]
      ,[IsInactive]
      ,[IsWithoutMilling]
      ,[IsDigital]
      ,[ScannerID]
      ,[ITeroVersion]
      ,[IsScannerKnown]
      ,[NumberOfModels]
      ,[CaseDateCreated]
      ,[MillingSiteID]
      ,[InterpretationSiteID]
      ,[ModelingSiteID]
      ,[InitiatorPartnerID]
      ,[InitiatorContactID]
      ,[ScanArrivalDate]
      ,[CurrentBillOfWork]
      ,[ProductTypeID]
      ,[DueDate]
      ,[MaxDateUpdated]
      ,[PartnerLabID]
      ,[InstrCode]
      ,[AnteriorPosterior]
	  ,[BaseUnitSN]
	  ,[WandSN]
	  ,[IsDirectToLab]
	  ,[IsColorScan]
	  ,[TotalColorScans]
from
	  (
		select	
		hc.SKCase,
		soh.ADLSBatchID
		,	soh.ADLSTimestamp
		,	soh.LZBatchID
		,   @BatchID as DWBatchID
		,	convert(char(40), '')									as DWHash 
		,   hc.KeyCase
		,	soh.SalesOrderHeaderCode	as CaseCode
		, 	cct.CaseTypeID			as CaseTypeId
		, 	convert(nvarchar(64), cct.CaseTypeGenericDescription) as CaseTypeName
		,	case when det.isIdx = 1	then N'Yes'	else N'No' end as isIdx
		,	case when det.isIde = 1	then N'Yes'	else N'No' end as isIde		
		,	case when soh.RowStatusID in (2, 3, 6) 	then N'Yes'	else N'No' end as isInactive
		,	case when cei.NumModelsForLab = 0 and isnull(det.MaxMillingDate, '19000101') <= isnull(cei.ArrivalDate, '99991231')
			then N'Yes' else N'No' end as isWithoutMilling	
		,	case when det.isDigital = 1 then N'Digital' when det.isConventional = 1 then N'Conventional' else N'Unknown' end as isDigital
		,	ISNULL(scan.EquipmentCardID, -1) as ScannerID
		,	ISNULL(convert(nvarchar(50), scan.iTeroVersion), N'') as iTeroVersion
		,	case when ISNULL(scan.EquipmentCardID, -1) = -1 then N'No' else N'Yes' end	as isScannerKnown
		,	cei.NumModelsForLab as NumberOfModels
		,	soh.DateCreated as CaseDateCreated
		,	isnull(isnull(partners.MillingSitePartnerID, cei.MillingSitePartnerID), -1) as MillingSiteID
		,	isnull(isnull(partners.InterpretationSitePartnerID, cei.InterpretationSitePartnerID), -1) as InterpretationSiteID
		,	isnull(partners.ModelingPartnerID, -1) as ModelingSiteID
		,	soh.InitiatorPartnerID	
		,	isnull(case when soh.InitiatorContactID = 0 then -1 else soh.InitiatorContactID end, -1) as InitiatorContactID
		,	nullif(cei.ArrivalDate, '19000101') as ScanArrivalDate
		,	cubow.BillOfWorkID as CurrentBillOfWork
		,	convert(tinyint,
				case when cct.CaseTypeID in (1, 2, 4, 6, 20, 21, 22, 23, 24)
					then 0 --iTero
					else cct.CaseTypeID
				end	
			) as ProductTypeID
		,	nullif(det.DueDate, '19000101')	as DueDate	
		,	case when soh.DateUpdated >= cei.DateUpdated
				then 
					case when soh.DateUpdated <= cei.LastWorkOrderDateUpdated
						then cei.LastWorkOrderDateUpdated
						else soh.DateUpdated
					end
				else
					case when cei.DateUpdated <= cei.LastWorkOrderDateUpdated
						then cei.LastWorkOrderDateUpdated
						else cei.DateUpdated
					end
			end MaxDateUpdated		
		,	isnull(lab.ShipToPartnerID, -1) as PartnerLabID
		,	isnull(cei.InstrCode, N'') as InstrCode
		,	isnull(ant_post.AnteriorPosterior, N'Unknown') as AnteriorPosterior
		,   isnull(scan.CartSN,'') as BaseUnitSN
		,	isnull(scan.EmbeddedHeadSN,'') as  WandSN
		,   isnull(cei.IsDirectToLab,'') as IsDirectToLab
		,   ROW_NUMBER() OVER(PARTITION BY soh.SalesOrderHeaderID ORDER BY soh.DateCreated DESC) as rn
		,   case when ps.iTeroOrderId is not null then 'Yes' else 'No' end as IsColorScan
		,   ps.TotalColorScans as TotalColorScans
	from srcMAT.SalesOrdersHeader soh 
	inner join srcMAT.Case_ExtendedInfo cei 
		on cei.OrderHeaderID = soh.SalesOrderHeaderID
	inner join srcMAT.Case_CaseTypes cct 
		on cei.CaseTypeID = cct.CaseTypeID
	inner join DWIRIS.HubCase hc on hc.keycase = cast(soh.SalesOrderHeaderID as nvarchar) and hc.sourcesystemCode='MAT' 
	left join (
		select	sod.SalesOrderHeaderID
			,	max(case when wo.BillOfWorkID = 100 then 1 else 0 end)
				as isDigital
			,	max(case when wo.BillOfWorkID = 210 then 1 else 0 end)
				as isConventional
			,	max(case when wo.BillOfWorkID = 513 then 1 else 0 end)
				as isIdx
			,	max(case when wo.BillOfWorkID in (517, 518) then 1 else 0 end)
				as isIde
			,	max(isnull(sod.DueDate, '19000101'))
				as DueDate
			,	max(case when wo.BillOfWorkID = 600 and wo.WorkOrderStatusID = 4 
						 then wo.DateUpdated end)
				as MaxMillingDate
			,	max(case when sod.ItemID in (300, 301) then 1 end)
				as ExportType
		from srcMAT.SalesOrdersDetails sod (nolock)
		left join srcMAT.WorkOrders wo (nolock) 
			on wo.SalesOrderDetailsID = sod.SalesOrderDetailsID
	    where (@IsFullLoad = 1 or sod.SalesOrderHeaderID in (select SalesOrderHeaderID from [DWIRIS].[Temp_CaseToLoad]))
		group by SalesOrderHeaderID
	) det on soh.SalesOrderHeaderID = det.SalesOrderHeaderID

	/*	ScannerID	*/
	left join (
		select 
			  SalesOrderHeaderID
			, EquipmentCardID
			, iTeroVersion
			, CartSN 
			, EmbeddedHeadSN 
		from srcmat.Case_ScanInfo si (nolock)
		left join srcmat.svc_EquipmentCard eq (nolock) 
			on si.CartSN = eq.SerialIdentifier
		where (@IsFullLoad = 1 or si.SalesOrderHeaderID in (select SalesOrderHeaderID from [DWIRIS].[Temp_CaseToLoad]))
	) scan 
		on soh.SalesOrderHeaderID = scan.SalesOrderHeaderID

	/*	AnteriorPosterior	*/
	left join (
		select	OrderHeaderID
			,	case when Anteriors > 0 and TotalUnits > Anteriors then N'Both' 
					 when Anteriors > 0 then N'Anterior' 
					 when TotalUnits > anteriors then N'Posterior'  
					 end as AnteriorPosterior
		from (
			select	cu.OrderHeaderID
				,	SUM(case when (cu.AdaID between 6 and 11) or (cu.AdaID between 22 and 7) then 1 else 0 end) 
					as Anteriors
				,	COUNT(*) as TotalUnits
			from  srcMAT.Case_Units cu (nolock)
			where cu.UnitTypeID in (2,3,4,5,6,7,8,12)
			and (@IsFullLoad = 1 or cu.OrderHeaderID in (select SalesOrderHeaderID from [DWIRIS].[Temp_CaseToLoad]))
			group by cu.OrderHeaderID
		) s
	) ant_post
		on soh.SalesOrderHeaderID = ant_post.OrderHeaderID

	/*	Lab Partner	*/
	left join (
		select top (1) with ties
			det2.SalesOrderHeaderID, det2.ShipToPartnerID
		from srcMAT.SalesOrdersDetails det2 (nolock) 
		inner join srcMAT.Items i2 (nolock) on i2.ItemID = det2.ItemID
		where i2.itemcategoryID = 4100
		and (@IsFullLoad = 1 or det2.SalesOrderHeaderID in (select SalesOrderHeaderID from [DWIRIS].[Temp_CaseToLoad]))

	--	and det2.SalesOrderHeaderID >= @minCaseID
		order by row_number() over(
			partition by det2.SalesOrderHeaderID
			order by det2.DateUpdated desc
		)
	) lab
		on lab.SalesOrderHeaderID = soh.SalesOrderHeaderID

	/*	CurrentBillOfWork	*/
	left join (
		select top (1) with ties
			wo.OrderID, wo.BillOfWorkID
		from srcMAT.WorkOrders wo (nolock)
		where (@IsFullLoad = 1 or wo.OrderID in (select SalesOrderHeaderID from [DWIRIS].[Temp_CaseToLoad]))
		--where wo.OrderID >= @minCaseID
		order by row_number() over(
			partition by wo.OrderID
			order by wo.DateCreated desc, wo.WorkOrderID desc
		)
	) cubow
		on cubow.OrderID = soh.SalesOrderHeaderID

	/*	Partners	*/
	left join (
		select OrderID
			, max(case when BillOfWorkID = 540 then ResourcePartnerID end) as MillingSitePartnerID
			, max(case when BillOfWorkID = 500 then ResourcePartnerID end) as InterpretationSitePartnerID
			, max(case when BillOfWorkID in (110,112) then ResourcePartnerID end) as ModelingPartnerID
		from (
			select top (1) with ties 
				wo.OrderID, wo.BillOfWorkID, wo.ResourcePartnerID
			from srcMAT.WorkOrders wo (nolock) 
			where wo.BillOfWorkID in (540, 500, 110, 112)
			--and wo.OrderID >= @minCaseID
			and (@IsFullLoad = 1 or wo.OrderID in (select SalesOrderHeaderID from [DWIRIS].[Temp_CaseToLoad]))
		order by row_number() over(
				partition by wo.OrderID
					, case when wo.BillOfWorkID = 540 then 1
						   when wo.BillOfWorkID = 500 then 2
						   when wo.BillOfWorkID in (110,112) then 3 end
				order by case when wo.WorkOrderStatusID in (1, 3, 4) then 1 else 0 end desc
						 ,wo.DateCreated desc
			)
		) zz
		group by OrderID
	) partners
		on partners.OrderID = soh.SalesOrderHeaderID
	left join (
				select iTeroOrderId,count(1) as TotalColorScans
					FROM SrcImages.Patient_assets
					where iteroOrderID is not null and  ColorScan='True'
					group by iTeroOrderId
				) ps on soh.SalesOrderHeaderID = ps.iTeroOrderId 

	--left join srcMAT.RxForm rx on cei.RxID = rx.ID

	where (@IsFullLoad = 1 or soh.SalesOrderHeaderID in (select SalesOrderHeaderID from [DWIRIS].[Temp_CaseToLoad]))


	) t 
	where t.rn = 1
	union all




	select	-1				as [SKCase]
		,	-1				as ADLSBatchID
		,	'19000101'		as ADLSTimestamp
		,	-1				as LZBatchID
		,	@BatchID		as DWBatchID
		,	''				as DWHash
		,	-1				as KeyCase
		,   'N/A'           as CaseCode
		,   -1              as CaseTypeId
		,   'No'            as CaseTypeName
		,   'No'            as IsIDX
		,   'No'            as IsIDE
		,   'No'            as IsInactive
		,   'No'            as IsWithoutMilling
		,   'Unknown'       as IsDigital
		,   -1              as 	ScannerID
		,   'N/A'           as 	ITeroVersion
		,   'N/A'           as 	IsScannerKnown
		,   1              as 	NumberOfModels
		,   '19000101'      as 	CaseDateCreated
		,   -1              as 	MillingSiteID
		,   -1              as 	InterpretationSiteID
		,   -1              as 	ModelingSiteID
		,   -1              as 	InitiatorPartnerID
		,   -1              as 	InitiatorContactID
		,   '19000101'      as 	ScanArrivalDate
		,   -1              as 	CurrentBillOfWork
		,   1              as 	ProductTypeID
		,   '19000101'      as 	DueDate
		,   '19000101'      as 	MaxDateUpdated
		,   -1              as 	PartnerLabID
		,   'N/A'           as 	InstrCode
		,   'N/A'           as 	AnteriorPosterior
		,   'N/A'           as  BaseUnitSN
		,   'N/A'			as  WandSN
		,   0			    as  IsDirectToLab
		,	'N/A'		    as [IsColorScan]
		,	0			    as [TotalColorScans]

	update DWIRIS.Temp_DimCase set DWHash =
		convert(char(40),
			hashbytes('SHA1',
				N'|' + isnull(convert(nvarchar, CaseTypeId), N'N/A')
				+ N'|' + isnull(convert(nvarchar, CaseTypeName), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsIDX), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsIDE), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsInactive), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsWithoutMilling), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsDigital), N'N/A')
				+ N'|' + isnull(convert(nvarchar, ScannerID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, ITeroVersion), N'N/A')
				+ N'|' + isnull(convert(nvarchar, NumberOfModels), N'N/A')
				+ N'|' + isnull(convert(nvarchar, CaseDateCreated), N'N/A')
				+ N'|' + isnull(convert(nvarchar, MillingSiteID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, InterpretationSiteID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, ModelingSiteID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, InitiatorPartnerID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, InitiatorContactID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, ScanArrivalDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, CurrentBillOfWork), N'N/A')
				+ N'|' + isnull(convert(nvarchar, ProductTypeID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, DueDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, MaxDateUpdated), N'N/A')
				+ N'|' + isnull(convert(nvarchar, PartnerLabID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, InstrCode), N'N/A')
				+ N'|' + isnull(convert(nvarchar, AnteriorPosterior), N'N/A')
				+ N'|' + isnull(convert(nvarchar, BaseUnitSN), N'N/A')
				+ N'|' + isnull(convert(nvarchar, WandSN), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsDirectToLab), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsColorScan), N'N/A')
				+ N'|' + isnull(convert(nvarchar, TotalColorScans), N'N/A')

			)
		, 2)
	where SKCase != -1

	if @IsFullLoad = 0
	begin
		update DWIRIS.DimCase
			set	
			    KeyCase = src.KeyCase
			,   ADLSBatchID = src.ADLSBatchID
			,	ADLSTimestamp = src.ADLSTimestamp
			,	LZBatchID = src.LZBatchID
			,	DWBatchID = @BatchID
			,	[CaseCode] = src.[CaseCode]
			,	[CaseTypeId] = src.[CaseTypeId]
			,	[CaseTypeName] = src.[CaseTypeName]
			,	[IsIDX] = src.[IsIDX]
			,	[IsIDE] = src.[IsIDE]
			,	[IsInactive] = src.[IsInactive]
			,	[IsWithoutMilling] = src.[IsWithoutMilling]
			,	[IsDigital] = src.[IsDigital]
			,	[ScannerID] = src.[ScannerID]
			,	[ITeroVersion] = src.[ITeroVersion]
			,	[IsScannerKnown] = src.[IsScannerKnown]
			,	[NumberOfModels] = src.[NumberOfModels]
			,	[CaseDateCreated] = src.[CaseDateCreated]
			,	[MillingSiteID] = src.[MillingSiteID]
			,	[InterpretationSiteID] = src.[InterpretationSiteID]
			,	[ModelingSiteID] = src.[ModelingSiteID]
			,	[InitiatorPartnerID] = src.[InitiatorPartnerID]
			,	[InitiatorContactID] = src.[InitiatorContactID]
			,	[ScanArrivalDate] = src.[ScanArrivalDate]
			,	[CurrentBillOfWork] = src.[CurrentBillOfWork]
			,	[ProductTypeID] = src.[ProductTypeID]
			,	[DueDate] = src.[DueDate]      
			,	[MaxDateUpdated] = src.[MaxDateUpdated]
			,	[PartnerLabID] = src.[PartnerLabID]
			,	[InstrCode] = src.[InstrCode]
			,	[AnteriorPosterior] = src.[AnteriorPosterior]
			,   [BaseUnitSN] = src.[BaseUnitSN]
			,	[WandSN]=src.[WandSN]
		    ,	[IsDirectToLab] = src.[IsDirectToLab]
			,   [TotalColorScans]	=src.[TotalColorScans]
			,   [IsColorScan] = src.[IsColorScan]
		from DWIRIS.Temp_DimCase src
		where DWIRIS.DimCase.SKCase = src.SKCase
			and DWIRIS.DimCase.DWHash != src.DWHash
		option (label = 'DWIRIS.LoadDimCase_Update');
	
		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimCase_Update', @rc = @RowsUpdated out

		insert into DWIRIS.DimCase (
	    [SKCase]
	  ,[KeyCase]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[DWHash]
      ,[CaseCode]
      ,[CaseTypeId]
      ,[CaseTypeName]
      ,[IsIDX]
      ,[IsIDE]
	  ,[IsInactive]
      ,[IsWithoutMilling]
      ,[IsDigital]
      ,[ScannerID]
      ,[ITeroVersion]
      ,[IsScannerKnown]
      ,[NumberOfModels]
      ,[CaseDateCreated]
      ,[MillingSiteID]
      ,[InterpretationSiteID]
      ,[ModelingSiteID]
      ,[InitiatorPartnerID]
      ,[InitiatorContactID]
      ,[ScanArrivalDate]
      ,[CurrentBillOfWork]
      ,[ProductTypeID]
      ,[DueDate]
      ,[MaxDateUpdated]
      ,[PartnerLabID]
      ,[InstrCode]
      ,[AnteriorPosterior]
	  ,[BaseUnitSN]
	  ,[WandSN]
	  ,[IsDirectToLab]
	  ,[IsColorScan]
	  ,[TotalColorScans]
	  )
		select	 [SKCase]
		,[KeyCase]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[DWHash]
      ,[CaseCode]
      ,[CaseTypeId]
      ,[CaseTypeName]
      ,[IsIDX]
      ,[IsIDE]
      ,[IsInactive]
      ,[IsWithoutMilling]
      ,[IsDigital]
      ,[ScannerID]
      ,[ITeroVersion]
      ,[IsScannerKnown]
      ,[NumberOfModels]
      ,[CaseDateCreated]
      ,[MillingSiteID]
      ,[InterpretationSiteID]
      ,[ModelingSiteID]
      ,[InitiatorPartnerID]
      ,[InitiatorContactID]
      ,[ScanArrivalDate]
      ,[CurrentBillOfWork]
      ,[ProductTypeID]
      ,[DueDate]
      ,[MaxDateUpdated]
      ,[PartnerLabID]
      ,[InstrCode]
      ,[AnteriorPosterior]
	  ,[BaseUnitSN]
	  ,[WandSN]
	  ,[IsDirectToLab]
	  ,[IsColorScan]
	  ,[TotalColorScans]
		from DWIRIS.Temp_DimCase src
		where not exists (select * from DWIRIS.DimCase dst where dst.SKCase = src.SKCase)
		option (label = 'DWIRIS.LoadDimCase_Insert');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimCase_Insert', @rc = @RowsInserted out

		drop table DWIRIS.Temp_DimCase
	end
	else
	begin --full load
		if object_id ('DWIRIS.DimCasePrevious', 'U') is not null
			drop table DWIRIS.DimCasePrevious

		rename object DWIRIS.DimCase to DimCasePrevious
		rename object DWIRIS.Temp_DimCase to DimCase
		drop table DWIRIS.DimCasePrevious

		create index IX_DimCase_KeyOrder on DWIRIS.DimCase (KeyCase)

		select @RowsInserted = count(*)
		from DWIRIS.DimCase

	end

	If object_id ('[DWIRIS].[Temp_CaseToLoad]', 'U') is not null
	Drop table [DWIRIS].[Temp_CaseToLoad];
	
	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end