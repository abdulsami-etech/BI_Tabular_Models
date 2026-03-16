CREATE PROC [DWIRIS].[LoadDimAsset] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimAssetSFDC') is not null
		drop table #TempDimAssetSFDC

-- Get delta rows
	create table #TempDimAssetSFDC with (distribution = round_robin, heap) as 
	select	
			has.SKAsset															as SKAsset
		,	a.ADLSBatchID														as ADLSBatchID
		,	a.ADLSTimestamp														as ADLSTimestamp
		,	a.LZBatchID															as LZBatchID
		,	convert(char(40), '')												as DWHash
		,	a1.Account_Number__c												as AccountNumber
		,	isnull(ha.[SKAccount], -1)											as SKAccount
		,	CAST(convert(varchar(8), a.CreatedDate, 112) AS INT)				as [CreatedDateKey]
		,	a.CreatedDate														as [CreatedDate]
		,	a.[Description]														as [Description]
		,	NULL																as [EquipmentCardID]
		,	a.Id																as Id
		,	CAST(convert(varchar(8), a.InstallDate, 112) AS INT)				as [InstallDateKey]
		,	a.InstallDate														as [InstallDate]
		,	pr2.IsActive														as IsActive
		,	CAST(convert(varchar(8), a.LastReferencedDate, 112) AS INT)			as [LastReferencedDateKey]
		,	a.LastReferencedDate												as [LastReferencedDate]
		,	CONVERT(nvarchar(50),NULL)											as MATDescription
		,	a.ParentID															as ParentId
		,	-1																	as SKParent
		,	pr2.Id																as ProductId
		,	CAST(convert(varchar(8), a.PurchaseDate, 112) AS INT)				as [PurchaseDateKey]
		,	a.PurchaseDate														as [PurchaseDate]
		,	a.SerialNumber														as SerialNumber
		,	pr2.StockKeepingUnit												as StockKeepingUnit
		,	CAST(convert(varchar(8), a.UsageEndDate, 112) AS INT)				as [UsageEndDateKey]
		,	a.UsageEndDate														as [UsageEndDate]
		,	(select 
				TOP 1 SerialNumber 
			from [SrcSFDC].[Asset] aa 
			where aa.ParentId = a.Id 
			and aa.Asset_Type__c = 'WAND'
			and aa.Status = 'Installed'
			Order by LastModifiedDate desc)  									as WandNumber
		,	CAST(convert(varchar(8), a.InstallDate, 112) AS INT)				as [FirstRegistrationDateKey]
		,	a.InstallDate														as [FirstRegistrationDate]
		,	NULL																as [LastRegistrationDateKey]
		,	NULL																as [LastRegistrationDate]
		
		,	a.Asset_Type__c														as [AssetType]
		,	a.Asset_Kind__c														as [AssetKind]
		,	a.[Name]															as [AssetName]
		,	a.Scanner_Software_Type__c											as [ScannerSoftwareType]
		,	a.Software_End_Date__c												as [SoftwareEndDate]
		,	'SFDC'																as [SourceSystem]
		,   a.[Status]															as [Status]
		,   a.[Installed_At__c]													as [InstalledAccount]

		,   a.[PGI_Date__c]														as [PGIDate]
		,   a.[Bill_To_Account__c]												as [BillToAccount]
		,   a.[Ship_To_Account__c]  											as [ShipToAccount]
		,   a.[Term_months__c]													as [TermMonths]
		,   a.[SAP_Sales_Order_Text__c]											as [SAPSalesOrder]
		,	o.[Opportunity_Number__c]											as [OpportunityNumber]
		,	a.[Payer_Account__c]												as [PayerAccount]

		
from (
	select top (1) with ties
		Id, ADLSTimestamp, ADLSBatchID, LZBatchID
		, CreatedDate, InstallDate, LastReferencedDate, PurchaseDate, UsageEndDate
		, Asset_Type__c, SerialNumber, [Status], [Description], ParentID
		, AccountId, Product2Id,Asset_Kind__c,[Name],Scanner_Software_Type__c,Software_End_Date__c
		, Installed_At__c
		, Ticket_Number__c
		, PGI_Date__c
		, Bill_To_Account__c
		, SAP_Sales_Order_Text__c
		, Ship_To_Account__c
		, Term_months__c
		, Payer_Account__c
	from [SrcSFDC].[Asset] 
	order by row_number() over(
		partition by SerialNumber
		order by LastModifiedDate desc
	)
) a
	inner JOIN [DWIRIS].[HubAsset] has
		on has.KeyAsset = a.SerialNumber
	LEFT JOIN [SrcSFDC].[Account] a1
		on a1.Id = a.AccountID
	LEFT JOIN [SrcSFDC].[Product2] pr2
		on pr2.Id = a.Product2id
	LEFT JOIN [DW].[HubAccount] ha
		on ha.[KeyAccount] = a1.[ID]
	LEFT JOIN [SrcSFDC].[Case] c
		on c.Id = a.[Ticket_Number__c]
	left join [SrcSFDC].[Opportunity] o
		on o.[Id] = c.Opportunity__c
	where a.ID is not null
		and a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimAsset where [SourceSystem] = 'SFDC')
		and a.Asset_Type__c in ('SCANNER','BASEUNIT','WAND','SOFTWARE PACKAGE') and isnull(a.SerialNumber,'') <> '' and a.Status in ('Installed','Shipped')
		--and a.InstallDate is not null

if object_id('tempdb..#TempDimAsset') is not null
		drop table #TempDimAsset

		create table #TempDimAsset with (distribution = round_robin, heap) as 
		select 
			SKAsset
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWHash
		,	AccountNumber
		,	SKAccount
		,	[CreatedDateKey]
		,	[CreatedDate]
		,	[Description]
		,	[EquipmentCardID]
		,	Id
		,	[InstallDateKey]
		,	[InstallDate]
		,	IsActive
		,	[LastReferencedDateKey]
		,	[LastReferencedDate]
		,	MATDescription
		,	ParentId
		,	SKParent
		,	ProductId
		,	[PurchaseDateKey]
		,	[PurchaseDate]
		,	SerialNumber
		,	StockKeepingUnit
		,	[UsageEndDateKey]
		,	[UsageEndDate]
		,	WandNumber
		,	[FirstRegistrationDateKey]
		,	[FirstRegistrationDate]
		,	[LastRegistrationDateKey]
		,	[LastRegistrationDate] 

		,	AssetKind
		,	AssetType
		,	AssetName
		,	ScannerSoftwareType
		,	SoftwareEndDate
		,	SourceSystem
		,	[Status]
		,	InstalledAccount

		,	[PGIDate]
		,   [BillToAccount]
		,   [ShipToAccount]
		,   [TermMonths]
		,   [SAPSalesOrder]
		,	[OpportunityNumber]
		,	[PayerAccount]

from #TempDimAssetSFDC	
union all
select	
			has.SKAsset															as SKAsset
		,	s.ADLSBatchID														as ADLSBatchID
		,	s.ADLSTimestamp														as ADLSTimestamp
		,	s.LZBatchID															as LZBatchID
		,	convert(char(40), '')												as DWHash
		,	bps.[SalesforceAccountNum]											as AccountNumber
		,	isnull(ha.SKAccount, -1)											as SKAccount
		,	CAST(convert(varchar(8), s.DateCreated, 112) AS INT)				as [CreatedDateKey]
		,	s.DateCreated														as [CreatedDate]
		,	s.[Notes]															as [Description]
		,	s.EquipmentCardID													as [EquipmentCardID]
		,	NULL																as Id
		,	NULL																as [InstallDateKey]
		,	NULL																as [InstallDate]
		,	s.RowStatusID														as IsActive
		,	NULL																as [LastReferencedDateKey]
		,	NULL																as [LastReferencedDate]
		,	sm.ScannerModelDescription											as MATDescription
		,	NULL																as ParentId
		,	-1																	as SKParent
		,	NULL																as ProductId
		,	NULL																as [PurchaseDateKey]
		,	NULL																as [PurchaseDate]
		,	s.SerialIdentifier													as SerialNumber
		,	NULL																as StockKeepingUnit
		,	CAST(convert(varchar(8), lastreg.UsageEndDate, 112) AS INT)			as [UsageEndDateKey]
		,	lastreg.UsageEndDate												as [UsageEndDate]
		,	sc.[EmbeddedHeadSN]  												as WandNumber
		,	CAST(convert(varchar(8), firstreg.DateCreated, 112) AS INT)			as [FirstRegistrationDateKey]
		,	firstreg.DateCreated												as [FirstRegistrationDate]
		,	CAST(convert(varchar(8), lastreg.DateCreated, 112) AS INT)			as [LastRegistrationDateKey]
		,	lastreg.DateCreated													as [LastRegistrationDate]

		,	NULL																as [AssetType]
		,	NULL																as [AssetKind]
		,	NULL																as [AssetName]
		,	NULL																as [ScannerSoftwareType]
		,	NULL																as [SoftwareEndDate]
		,	'MAT'																as [SourceSystem]
		,   convert(nvarchar(40), NULL)											as [Status]
		,   convert(nvarchar(18), NULL)											as [InstalledAccount]

		,   convert(datetime2(7), NULL)											as [PGIDate]
		,   convert(nvarchar(255), NULL)											as [BillToAccount]
		,   convert(nvarchar(255), NULL)											as [ShipToAccount]
		,   convert(nvarchar(255), NULL)											as [TermMonths]
		,   convert(nvarchar(255), NULL)											as [SAPSalesOrder]
		,	convert(nvarchar(255), NULL)											as [OpportunityNumber]
		,	convert(nvarchar(255), NULL)										    as [PayerAccount]
from [SrcMAT].[svc_EquipmentCard] s
	inner join [SrcMAT].[Scanner] sc
		on sc.[EquipmentCardID] = s.[EquipmentCardID]
    inner JOIN [DWIRIS].[HubAsset] has
		on has.KeyAsset = s.SerialIdentifier
	left join [SrcMAT].[BusinessPartnerSalesforceLink] bps
		on s.[HolderBusinessPartnerID] = bps.[BusinessPartnerId] and bps.RowStatusID <> 5
	LEFT JOIN [SrcMAT].[ScannerModels] sm
		on sm.ScannerModelId = sc.ScannerModelID
    LEFT JOIN 
		(
		 select ResourceSerialIdentifier, DateCreated, UsageEndDate from
			(select		  
					res.ResourceSerialIdentifier
				 , res.DateCreated
				 , res.InvalidateDate as UsageEndDate
				 , rnum = row_number() OVER(PARTITION BY res.ResourceSerialIdentifier ORDER BY res.DateCreated DESC) 
			  from SrcMAT.Resources res
			  where res.RowStatusID = 1	
			 ) t
			where t.rnum = 1
		) lastreg
			on lastreg.ResourceSerialIdentifier = s.SerialIdentifier
	LEFT JOIN 
		(
		 select ResourceSerialIdentifier, DateCreated from
			(select		  
					res.ResourceSerialIdentifier
				 , res.DateCreated
				 , rnum = row_number() OVER(PARTITION BY res.ResourceSerialIdentifier ORDER BY res.DateCreated ASC) 
			  from SrcMAT.Resources res
			  where res.RowStatusID = 1	
			 ) t
			where t.rnum = 1
		) firstreg
			on firstreg.ResourceSerialIdentifier = s.SerialIdentifier
	left join (select 
					t.BusinessPartnerId, 
					a.Id  
				from [SrcMAT].[BusinessPartnerSalesforceLink] t
				left join  [SrcSFDC].[Account] a
					on  a.Account_Number__c = t.[SalesforceAccountNum] and  try_convert(int, a.MAT_ID__c) = t.BusinessPartnerId and t.RowStatusID <> 5
				where a.Id is not null
				) a1
		on  a1.BusinessPartnerId = bps.BusinessPartnerId 	 
	left join [DW].HubAccount ha
		on ha.[KeyAccount] = a1.[ID]
	where s.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimAsset where [SourceSystem] = 'MAT') 
		and has.SKAsset not in (select SKAsset from #TempDimAssetSFDC)



		
	--update HASH
	update #TempDimAsset set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         
						 ISNULL(convert(nvarchar,[AccountNumber]),'')
					+'|'+ISNULL(convert(nvarchar,[SKAccount]),'')
					+'|'+ISNULL(convert(nvarchar,[CreatedDateKey]),'')
					+'|'+ISNULL(convert(nvarchar,[CreatedDate]),'')
					+'|'+ISNULL(convert(nvarchar,[Description]),'')
					+'|'+ISNULL(convert(nvarchar,[EquipmentCardID]),'')
					+'|'+ISNULL(convert(nvarchar,[Id]),'')
					+'|'+ISNULL(convert(nvarchar,[InstallDateKey]),'')
					+'|'+ISNULL(convert(nvarchar,[InstallDate]),'')
					+'|'+ISNULL(convert(nvarchar,[IsActive]),'')
					+'|'+ISNULL(convert(nvarchar,[LastReferencedDateKey]),'')
					+'|'+ISNULL(convert(nvarchar,[LastReferencedDate]),'')
					+'|'+ISNULL(convert(nvarchar,[MATDescription]),'')
					+'|'+ISNULL(convert(nvarchar,[ParentId]),'')
					+'|'+ISNULL(convert(nvarchar,[SKParent]),'')
					+'|'+ISNULL(convert(nvarchar,[ProductId]),'')
					+'|'+ISNULL(convert(nvarchar,[PurchaseDateKey]),'')
					+'|'+ISNULL(convert(nvarchar,[PurchaseDate]),'')
					+'|'+ISNULL(convert(nvarchar,[StockKeepingUnit]),'')
					+'|'+ISNULL(convert(nvarchar,[UsageEndDateKey]),'')
					+'|'+ISNULL(convert(nvarchar,[UsageEndDate]),'')
					+'|'+ISNULL(convert(nvarchar,[WandNumber]),'')
					+'|'+ISNULL(convert(nvarchar,[FirstRegistrationDateKey]),'')
					+'|'+ISNULL(convert(nvarchar,[FirstRegistrationDate]),'')
					+'|'+ISNULL(convert(nvarchar,[LastRegistrationDateKey]),'')
					+'|'+ISNULL(convert(nvarchar,[LastRegistrationDate]),'')
					+'|'+ISNULL(convert(nvarchar,AssetType),'')
					+'|'+ISNULL(convert(nvarchar,AssetKind),'')
					+'|'+ISNULL(convert(nvarchar,AssetName),'')
					+'|'+ISNULL(convert(nvarchar,ScannerSoftwareType),'')
					+'|'+ISNULL(convert(nvarchar,SoftwareEndDate),'')
					+'|'+ISNULL(convert(nvarchar,SourceSystem),'')
					+'|'+ISNULL(convert(nvarchar,[Status]),'')
					+'|'+ISNULL(convert(nvarchar,InstalledAccount),'')

					+'|'+ISNULL(convert(nvarchar,[PGIDate]),'')
					+'|'+ISNULL(convert(nvarchar,[BillToAccount]),'')
					+'|'+ISNULL(convert(nvarchar,[ShipToAccount]),'')
					+'|'+ISNULL(convert(nvarchar,[TermMonths]),'')
					+'|'+ISNULL(convert(nvarchar,[SAPSalesOrder]),'')
					+'|'+ISNULL(convert(nvarchar,[OpportunityNumber]),'')
					+'|'+ISNULL(convert(nvarchar,[PayerAccount]),'')

				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimAsset] where SKAsset = -1)
	begin
		declare @Hash char(40) = ''

		--set identity_insert DWIRIS.DimAsset on
		insert into DWIRIS.DimAsset (
				[SKAsset]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[AccountNumber]
				,[SKAccount]
				,[CreatedDateKey]
				,[CreatedDate]
				,[Description]
				,[EquipmentCardID]
				,[Id]
				,[InstallDateKey]
				,[InstallDate]
				,[IsActive]
				,[LastReferencedDateKey]
				,[LastReferencedDate]
				,[MATDescription]
				,[ParentID]
				,[SKParent]
				,[ProductId]
				,[PurchaseDateKey]
				,[PurchaseDate]
				,[SerialNumber]
				,[StockKeepingUnit]
				,[UsageEndDateKey]
				,[UsageEndDate]
				,[WandNumber]
				,[FirstRegistrationDateKey]
				,[FirstRegistrationDate]
				,[LastRegistrationDateKey]
				,[LastRegistrationDate]
				,[AssetType]
				,[AssetKind]
				,[AssetName]
				,[ScannerSoftwareType]
				,[SoftwareEndDate]
				,[SourceSystem]
				,[Status]
				,[InstalledAccount]

				,[PGIDate]
				,[BillToAccount]
				,[ShipToAccount]
				,[TermMonths]
				,[SAPSalesOrder]
				,[OpportunityNumber]
				,[PayerAccount]

		)
		values (
				-1					-- SKAsset
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
			,	'N/A'				-- AccountNumber
			,	-1					-- SKAccount
			,	 19000101			-- CreatedDateKey
			,	 '19000101'			-- CreatedDate
			,	'N/A'				-- Description
			,	-1					-- EquipmentCardID
			,	-1					-- Id
			,	 19000101			-- InstallDateKey
			,	 '19000101'			-- InstallDate
			,	'N/A'				-- IsActive
			,	 19000101			-- LastReferenceDateKey
			,	 '19000101'			-- LastReferenceDate
			,	'N/A'				-- MATDescription
			,	'N/A'				-- ParentID
			,	-1					-- SKParent
			,	'N/A'				-- ProductID
			,	 19000101			-- PurchaseDateKey
			,	 '19000101'			-- PurchaseDateDate
			,	'N/A'				-- SerialNumber
			,	'N/A'				-- StockKeepingUnit
			,	 19000101			-- UsageEndDateKey
			,	 '19000101'			-- UsageEndDate
			,	'N/A'				-- WandNumber
			,	 19000101			-- FirstRegistrationDateKey
			,	 '19000101'			-- FirstRegistrationDate
			,	 19000101			-- LastRegistrationDateKey
			,	 '19000101'			-- LastRegistrationDate

			,	'N/A'				-- AssetType
			,	'N/A'				-- AssetKind
			,	'N/A'				-- AssetName
			,	'N/A'				-- ScannerSoftwareType
			,	'19000101'			-- SoftwareEndDate
			,	'N/A'				-- SourceSystem
			,	'N/A'				-- Status
			,	'N/A'				-- InstalledAccount

			,	'19000101'				-- PGIDate
			,	'N/A'				-- BillToAccount
			,	'N/A'				-- ShipToAccount
			,	'N/A'				-- TermMonths
			,	'N/A'				-- SAPSalesOrder
			,	'N/A'				-- OpportunityNumber
			,	'N/A'				-- PayerAccount
		)
		--set identity_insert DWIRIS.DimAsset off;
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimAsset]
		set
		     ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash
			,[AccountNumber]			=		src.[AccountNumber]
			,[SKAccount]				=		src.[SKAccount]
			,[CreatedDateKey]			=		src.[CreatedDateKey]
			,[CreatedDate]				=		src.[CreatedDate]
			,[Description]				=		src.[Description]
			,[EquipmentCardID]			=		src.[EquipmentCardID]
			,[Id]						=		src.[Id]
			,[InstallDateKey]			=		src.[InstallDateKey]
			,[InstallDate]				=		src.[InstallDate]
			,[IsActive]					=		src.[IsActive]
			,[LastReferencedDateKey]	=		src.[LastReferencedDateKey]
			,[LastReferencedDate]		=		src.[LastReferencedDate]
			,[MATDescription]			=		src.[MATDescription]
			,[ParentId]					=		src.[ParentId]
			,[SKParent]					=		src.[SKParent]
			,[ProductId]				=		src.[ProductId]
			,[PurchaseDateKey]			=		src.[PurchaseDateKey]
			,[PurchaseDate]				=		src.[PurchaseDate]
			,[SerialNumber]				=		src.[SerialNumber]
			,[StockKeepingUnit]			=		src.[StockKeepingUnit]
			,[UsageEndDateKey]			=		src.[UsageEndDateKey]
			,[UsageEndDate]				=		src.[UsageEndDate]
			,[WandNumber]				=		src.[WandNumber]
			,[FirstRegistrationDateKey] =		src.FirstRegistrationDateKey
			,[FirstRegistrationDate]	=		src.FirstRegistrationDate
			,[LastRegistrationDateKey] =		src.LastRegistrationDateKey
			,[LastRegistrationDate]		=		src.LastRegistrationDate
			
			,AssetType					=		src.AssetType
			,AssetKind					=		src.AssetKind
			,AssetName					=		src.AssetName
			,ScannerSoftwareType		=		src.ScannerSoftwareType
			,SoftwareEndDate			=		src.SoftwareEndDate
			,SourceSystem				=		src.SourceSystem
			,[Status]					=		src.[Status]
			,InstalledAccount			=		src.[InstalledAccount]

			,[PGIDate]			=		src.[PGIDate]
			,[BillToAccount]			=		src.[BillToAccount]
			,[ShipToAccount]			=		src.[ShipToAccount]
			,[TermMonths]			=		src.[TermMonths]
			,[SAPSalesOrder]			=		src.[SAPSalesOrder]
			,[OpportunityNumber]		=		src.[OpportunityNumber]
			,[PayerAccount]				=		src.[PayerAccount]

	from #TempDimAsset src
	where [DWIRIS].[DimAsset].SKAsset	=	src.SKAsset
		and [DWIRIS].[DimAsset].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimAsset_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimAsset_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimAsset] (
			[SKAsset]
		   ,[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,[DWBatchID]
           ,[DWHash]
           ,[AccountNumber]
           ,[SKAccount]
           ,[CreatedDateKey]
           ,[CreatedDate]
           ,[Description]
           ,[EquipmentCardID]
           ,[Id]
           ,[InstallDateKey]
           ,[InstallDate]
           ,[IsActive]
           ,[LastReferencedDateKey]
           ,[LastReferencedDate]
           ,[MATDescription]
           ,[ParentID]
           ,[SKParent]
           ,[ProductId]
           ,[PurchaseDateKey]
           ,[PurchaseDate]
           ,[SerialNumber]
           ,[StockKeepingUnit]
           ,[UsageEndDateKey]
           ,[UsageEndDate]
           ,[WandNumber]
		   ,[FirstRegistrationDateKey]
		   ,[FirstRegistrationDate]
		   ,[LastRegistrationDateKey]
		   ,[LastRegistrationDate]

		   ,AssetType
		   ,AssetKind
		   ,AssetName
		   ,ScannerSoftwareType
		   ,SoftwareEndDate
		   ,SourceSystem
		   ,[Status]
		   ,InstalledAccount

		   ,[PGIDate]
		   ,[BillToAccount]
		   ,[ShipToAccount]
		   ,[TermMonths]
		   ,[SAPSalesOrder]
		   ,[OpportunityNumber]
		   ,[PayerAccount]
		   )
	select 
			[SKAsset]
		   ,[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,@BatchID
           ,[DWHash]
           ,[AccountNumber]
           ,[SKAccount]
           ,[CreatedDateKey]
           ,[CreatedDate]
           ,[Description]
           ,[EquipmentCardID]
           ,[Id]
           ,[InstallDateKey]
           ,[InstallDate]
           ,[IsActive]
           ,[LastReferencedDateKey]
           ,[LastReferencedDate]
           ,[MATDescription]
           ,[ParentID]
           ,[SKParent]
           ,[ProductId]
           ,[PurchaseDateKey]
           ,[PurchaseDate]
           ,[SerialNumber]
           ,[StockKeepingUnit]
           ,[UsageEndDateKey]
           ,[UsageEndDate]
           ,[WandNumber]
		   ,[FirstRegistrationDateKey]
		   ,[FirstRegistrationDate]
		   ,[LastRegistrationDateKey]
		   ,[LastRegistrationDate]

		   ,AssetType
		   ,AssetKind
		   ,AssetName
		   ,ScannerSoftwareType
		   ,SoftwareEndDate
		   ,SourceSystem
		   ,[Status]
		   ,InstalledAccount

		   ,[PGIDate]
		   ,[BillToAccount]
			,[ShipToAccount]
				,[TermMonths]
				,[SAPSalesOrder]
				,[OpportunityNumber]
				,[PayerAccount]
	from #TempDimAsset src
	where not exists(select dst.SKAsset from DWIRIS.DimAsset dst where dst.SKAsset = src.SKAsset)
	option (label = 'DWIRIS.LoadDimAsset_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimAsset_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end --procedure