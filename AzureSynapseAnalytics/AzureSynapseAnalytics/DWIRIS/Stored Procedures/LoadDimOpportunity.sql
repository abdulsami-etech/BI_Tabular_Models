CREATE PROC [DWIRIS].[LoadDimOpportunity] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimOpportunity') is not null
		drop table #TempDimOpportunity

-- Get delta rows
	create table #TempDimOpportunity with (distribution = round_robin, heap) as 
	select				
					 ho.SKOpportunity												as SKOpportunity
					,o.ADLSBatchID													as ADLSBatchID
					,o.ADLSTimestamp												as ADLSTimestamp
					,o.LZBatchID													as LZBatchID
					,convert(char(40), '')											as DWHash
					,o.Id 															as KeyOpportunity
					,hu.SKUser 														as SKUser
					,ha.SKAccount													as SKAccount
					,o.[Name] 														as OpportunityName
					,o.[Opportunity_Number__c] 										as OpportunityNumber
					,o.[Commission_Date__c] 										as CommissionDate
					,o.[Shipped_Date__c] 											as ShippedDate
					,o.[Sale_Type__c] 												as SaleType
					,o.[Opportunity_Id__c] 											as OpportunityId_C
					,o.[Generated_By__c] 											as GeneratedBy
					,o.[CloseDate] 													as CloseDate
					,o.[Amount] 													as Amount
					,o.[Product__c] 												as ProductName
					,o.[StageName] 													as StageName
					,o.[Demo_Date__c] 												as DemoDate
					,o.[Contract_Loaded__c] 										as ContractLoadDate
					,o.Agreement_Effective_Date__c									as AgreementEffectiveDate
					,o.Alert_Status_Date__c											as AlertStatusDate
					,o.Align_Signature_Date__c										as AlignSignatureDate
					,o.Cancellation_Date__c											as CancellationDate
					,o.Cancellation_Reason__c										as CancellationReason
					,o.Cancellation_Status__c										as CancellationStatus
					,o.Cancelled__c													as Cancelled
					,o.Child_Opportunity_Id__c										as ChildOpportunityId
					,o.Closed_Reason__c												as ClosedReason
					,o.Competitor_Involved__c										as CompetitorInvolved
					,o.Contact__c													as Contact
					,o.Contract_Signed_Date__c										as ContractSignedDate
					,o.Contract_type__c												as Contracttype
					,o.Country__c													as Country
					,o.CreatedById													as CreatedById
					,o.CreatedDate													as CreatedDate
					,o.CurrencyIsoCode												as CurrencyIsoCode
					,o.Delivered_Date__c											as DeliveredDate
					,o.Dep__c														as Dep
					,o.[Description]												as [Description]
					,o.Distributor__c												as Distributor
					,o.ExpectedRevenue												as ExpectedRevenue
					,o.Funding_Source__c											as FundingSource
					,o.Go_Digital__c 												as GoDigital
					,o.Go_Digital_Opp__c 											as GoDigitalOpp
					,o.HasOpportunityLineItem 										as HasOpportunityLineItem
					,o.is_Refurbished_Product__c 									as isRefurbishedProduct
					,o.IsDeleted 													as IsDeleted
					,o.iTero_Type__c 												as iTeroType
					,o.LastModifiedDate 											as LastModifiedDate
					,o.LeadSource 													as LeadSource
					,o.Leasing_Company__c 											as LeasingCompany
					,o.[Name] 														as [Name]
					,o.Number_of_Scanners__c										as NumberofScanners
					,o.Payment_Type__c												as PaymentType
					,o.Probability													as Probability
					,o.Product_Option__c											as ProductOption
					,o.Promotion__c													as Promotion
					,o.RecordTypeId													as RecordTypeId
					,o.Request_Format__c											as RequestFormat
					,o.Scanner_Demo_Date__c											as ScannerDemoDate
					,o.Scanner_Quantity__c											as ScannerQuantity
					,o.Scanner_Sales_Channel__c										as ScannerSalesChannel
					,o.Scanner_SN__c												as ScannerSN
					,o.Sub_Lead_Source__c											as SubLeadSource
					,o.SystemModstamp												as SystemModstamp
					,o.Total_Quantity__c											as TotalQuantity
					,o.TotalOpportunityQuantity										as TotalOpportunityQuantity
					,o.Trade_In_Serial_Number__c									as TradeInSerialNumber
					,o.Routed_Date__c 												as RoutedDate
					,orl.Parent_Opportunity__c 										as ParentOpportunity
				from [SrcSFDC].[Opportunity] o
				inner join DWIRIS.HubOpportunity ho
					on ho.KeyOpportunity = o.ID
				left join DWIRIS.HubUser hu
					on hu.KeyUser = o.OwnerId
				left join DW.HubAccount ha
					on ha.KeyAccount = o.AccountID
				left join [SrcSFDC].[Opportunity_Relationship__c] orl
					on orl.Child_Opportunity__c = o.Id
				where o.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimOpportunity)
		
		
	--update HASH
	update #TempDimOpportunity set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         ISNULL(convert(nvarchar,KeyOpportunity),'')
					+'|'+ISNULL(convert(nvarchar,SKUser),'')
					+'|'+ISNULL(convert(nvarchar,SKAccount),'')
					+'|'+ISNULL(convert(nvarchar,OpportunityName),'')
					+'|'+ISNULL(convert(nvarchar,OpportunityNumber),'')
					+'|'+ISNULL(convert(nvarchar,CommissionDate),'')
					+'|'+ISNULL(convert(nvarchar,ShippedDate),'')
					+'|'+ISNULL(convert(nvarchar,SaleType),'')
					+'|'+ISNULL(convert(nvarchar,OpportunityId_C),'')
					+'|'+ISNULL(convert(nvarchar,GeneratedBy),'')
					+'|'+ISNULL(convert(nvarchar,CloseDate),'')
					+'|'+ISNULL(convert(nvarchar,Amount),'')
					+'|'+ISNULL(convert(nvarchar,ProductName),'')
					+'|'+ISNULL(convert(nvarchar,StageName),'')
					+'|'+ISNULL(convert(nvarchar,DemoDate),'')
					+'|'+ISNULL(convert(nvarchar,ContractLoadDate),'')
					+'|'+ISNULL(convert(nvarchar,AgreementEffectiveDate),'')
					+'|'+ISNULL(convert(nvarchar,AlertStatusDate),'')
					+'|'+ISNULL(convert(nvarchar,AlignSignatureDate),'')
					+'|'+ISNULL(convert(nvarchar,CancellationDate),'')
					+'|'+ISNULL(convert(nvarchar,CancellationReason),'')
					+'|'+ISNULL(convert(nvarchar,CancellationStatus),'')
					+'|'+ISNULL(convert(nvarchar,Cancelled),'')
					+'|'+ISNULL(convert(nvarchar,ChildOpportunityId),'')
					+'|'+ISNULL(convert(nvarchar,ClosedReason),'')
					+'|'+ISNULL(convert(nvarchar,CompetitorInvolved),'')
					+'|'+ISNULL(convert(nvarchar,Contact),'')
					+'|'+ISNULL(convert(nvarchar,ContractSignedDate),'')
					+'|'+ISNULL(convert(nvarchar,Contracttype),'')
					+'|'+ISNULL(convert(nvarchar,Country),'')
					+'|'+ISNULL(convert(nvarchar,CreatedById),'')
					+'|'+ISNULL(convert(nvarchar,CreatedDate),'')
					+'|'+ISNULL(convert(nvarchar,CurrencyIsoCode),'')
					+'|'+ISNULL(convert(nvarchar,DeliveredDate),'')
					+'|'+ISNULL(convert(nvarchar,Dep),'')
					+'|'+ISNULL(convert(nvarchar,[Description]),'')
					+'|'+ISNULL(convert(nvarchar,Distributor),'')
					+'|'+ISNULL(convert(nvarchar,ExpectedRevenue),'')
					+'|'+ISNULL(convert(nvarchar,FundingSource),'')
					+'|'+ISNULL(convert(nvarchar,GoDigital),'')
					+'|'+ISNULL(convert(nvarchar,GoDigitalOpp),'')
					+'|'+ISNULL(convert(nvarchar,HasOpportunityLineItem),'')
					+'|'+ISNULL(convert(nvarchar,isRefurbishedProduct),'')
					+'|'+ISNULL(convert(nvarchar,IsDeleted),'')
					+'|'+ISNULL(convert(nvarchar,iTeroType),'')
					+'|'+ISNULL(convert(nvarchar,LastModifiedDate),'')
					+'|'+ISNULL(convert(nvarchar,LeadSource),'')
					+'|'+ISNULL(convert(nvarchar,LeasingCompany),'')
					+'|'+ISNULL(convert(nvarchar,[Name]),'')
					+'|'+ISNULL(convert(nvarchar,NumberofScanners),'')
					+'|'+ISNULL(convert(nvarchar,PaymentType),'')
					+'|'+ISNULL(convert(nvarchar,Probability),'')
					+'|'+ISNULL(convert(nvarchar,ProductOption),'')
					+'|'+ISNULL(convert(nvarchar,Promotion),'')
					+'|'+ISNULL(convert(nvarchar,RecordTypeId),'')
					+'|'+ISNULL(convert(nvarchar,RequestFormat),'')
					+'|'+ISNULL(convert(nvarchar,ScannerDemoDate),'')
					+'|'+ISNULL(convert(nvarchar,ScannerQuantity),'')
					+'|'+ISNULL(convert(nvarchar,ScannerSalesChannel),'')
					+'|'+ISNULL(convert(nvarchar,ScannerSN),'')
					+'|'+ISNULL(convert(nvarchar,SubLeadSource),'')
					+'|'+ISNULL(convert(nvarchar,SystemModstamp),'')
					+'|'+ISNULL(convert(nvarchar,TotalQuantity),'')
					+'|'+ISNULL(convert(nvarchar,TotalOpportunityQuantity),'')
					+'|'+ISNULL(convert(nvarchar,TradeInSerialNumber),'')
					+'|'+ISNULL(convert(nvarchar,RoutedDate),'')
					+'|'+ISNULL(convert(nvarchar,ParentOpportunity),'')
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimOpportunity] where SKOpportunity = -1)
	begin
		declare @Hash char(40) = ''

		insert into DWIRIS.DimOpportunity (
				[SKOpportunity],
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				[DWBatchID],
				[DWHash],
				[KeyOpportunity],
				[SKUser],
				[SKAccount],
				[OpportunityName],
				[OpportunityNumber],
				[CommissionDate],
				[ShippedDate],
				[SaleType],
				[OpportunityId_C],
				[GeneratedBy],
				[CloseDate],
				[Amount],
				[ProductName],
				[StageName],
				[DemoDate],
				[ContractLoadDate]
				,[AgreementEffectiveDate]
				,[AlertStatusDate]
				,[AlignSignatureDate]
				,[CancellationDate]
				,[CancellationReason]
				,[CancellationStatus]
				,[Cancelled]
				,[ChildOpportunityId]
				,[ClosedReason]
				,[CompetitorInvolved]
				,[Contact]
				,[ContractSignedDate]
				,[Contracttype]
				,[Country]
				,[CreatedById]
				,[CreatedDate]
				,[CurrencyIsoCode]
				,[DeliveredDate]
				,[Dep]
				,[Description]
				,[Distributor]
				,[ExpectedRevenue]
				,[FundingSource]
				,[GoDigital]
				,[GoDigitalOpp]
				,[HasOpportunityLineItem]
				,[isRefurbishedProduct]
				,[IsDeleted]
				,[iTeroType]
				,[LastModifiedDate]
				,[LeadSource]
				,[LeasingCompany]
				,[Name]
				,[NumberofScanners]
				,[PaymentType]
				,[Probability]
				,[ProductOption]
				,[Promotion]
				,[RecordTypeId]
				,[RequestFormat]
				,[ScannerDemoDate]
				,[ScannerQuantity]
				,[ScannerSalesChannel]
				,[ScannerSN]
				,[SubLeadSource]
				,[SystemModstamp]
				,[TotalQuantity]
				,[TotalOpportunityQuantity]
				,[TradeInSerialNumber]
				,[RoutedDate]
				,[ParentOpportunity]
		)
		values (
				-1					-- SKOpportunity
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
			,   'N/A'				--[KeyOpportunity]
			,	-1					-- SKUser
			,	-1					-- SKAccount
			,	'N/A'				--[OpportunityName]
			,	'N/A'				--[OpportunityNumber]
			,	'19000101'			--[CommissionDate]
			,	'19000101'			--[ShippedDate]
			,	'N/A'				--[SaleType]
			,	'N/A'				--[OpportunityId_C]
			,	'N/A'				--[GeneratedBy]
			,	'19000101'			--[CloseDate]
			,	-1					--[Amount]
			,	'N/A'				--[ProductName]
			,	'N/A'				--[StageName]
			,	'19000101'			--[DemoDate]
			,	'19000101'			--[ContractLoadDate]
			,	'19000101'			--[AgreementEffectiveDate]
			,	'19000101'			--[AlertStatusDate]
			,	'19000101'			--[AlignSignatureDate]
			,	'19000101'			--[CancellationDate]
			,	'N/A'				--[CancellationReason]
			,	'N/A'				--[CancellationStatus]
			,	-1					--[Cancelled]
			,	'N/A'				--[ChildOpportunityId]
			,	'N/A'				--[ClosedReason]
			,	'N/A'				--[CompetitorInvolved]
			,	'N/A'				--[Contact]
			,	'19000101'			--[ContractSignedDate]
			,	'N/A'				--[Contracttype]
			,	'N/A'				--[Country]
			,	'N/A'				--[CreatedById]
			,	'19000101'			--[CreatedDate]
			,	'N/A'				--[CurrencyIsoCode]
			,	'19000101'			--[DeliveredDate]
			,	'19000101'			--[Dep]
			,	'19000101'			--[Description]
			,	'N/A'				--[Distributor]
			,	-1					--[ExpectedRevenue]
			,	'N/A'				--[FundingSource]
			,	'19000101'			--[GoDigital]
			,	'19000101'			--[GoDigitalOpp]
			,	'19000101'			--[HasOpportunityLineItem]
			,	'19000101'			--[isRefurbishedProduct]
			,	'19000101'			--[IsDeleted]
			,	'N/A'				--[iTeroType]
			,	'19000101'			--[LastModifiedDate]
			,	'N/A'				--[LeadSource]
			,	'N/A'				--[LeasingCompany]
			,	'N/A'				--[Name]
			,	-1					--[NumberofScanners]
			,	'N/A'				--[PaymentType]
			,	-1					--[Probability]
			,	'N/A'				--[ProductOption]
			,	'N/A'				--[Promotion]
			,	'19000101'			--[RecordTypeId]
			,	'N/A'				--[RequestFormat]
			,	'19000101'			--[ScannerDemoDate]
			,	-1					--[ScannerQuantity]
			,	'N/A'				--[ScannerSalesChannel]
			,	'N/A'				--[ScannerSN]
			,	'N/A'				--[SubLeadSource]
			,	'19000101'			--[SystemModstamp]
			,	-1					--[TotalQuantity]
			,	-1					--[TotalOpportunityQuantity]
			,	'N/A'				--[TradeInSerialNumber]
			,	'19000101'			--[RoutedDate]
			,	'N/A'				--[ParentOpportunity]


	)
	end


	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimOpportunity]
		set
		   ADLSBatchID										=	src.ADLSBatchID
		  ,ADLSTimestamp									=	src.ADLSTimestamp
		  ,LZBatchID										=	src.LZBatchID
		  ,DWBatchID										=	@BatchID
		  ,DWHash											=	src.DWHash
 		  ,[KeyOpportunity]									=	src.[KeyOpportunity]
		  ,[SKUser]											=	src.[SKUser]
		  ,[SKAccount]										=	src.[SKAccount]
		  ,[OpportunityName]								=	src.[OpportunityName]
		  ,[OpportunityNumber]								=	src.[OpportunityNumber]
 		  ,[CommissionDate]									=	src.[CommissionDate]
		  ,[ShippedDate]									=	src.[ShippedDate]
		  ,[SaleType]										=	src.[SaleType]
		  ,[OpportunityId_C]								=	src.[OpportunityId_C]
		  ,[GeneratedBy]									=	src.[GeneratedBy]
		  ,[CloseDate]										=	src.[CloseDate]
		  ,[Amount]											=	src.[Amount]
		  ,[ProductName]									=	src.[ProductName]
		  ,[StageName]										=	src.[StageName]
		  ,[DemoDate]										=	src.[DemoDate]
		  ,[ContractLoadDate]								=	src.[ContractLoadDate]
		  ,[AgreementEffectiveDate]							=	src.AgreementEffectiveDate,
			[AlertStatusDate]								=	src.AlertStatusDate,
			[AlignSignatureDate]							=	src.AlignSignatureDate,
			[CancellationDate]								=	src.CancellationDate,
			[CancellationReason]							=	src.CancellationReason,
			[CancellationStatus]							=	src.CancellationStatus,
			[Cancelled]										=	src.Cancelled,
			[ChildOpportunityId]							=	src.ChildOpportunityId,
			[ClosedReason]									=	src.ClosedReason,
			[CompetitorInvolved]							=	src.CompetitorInvolved,
			[Contact]										=	src.Contact,
			[ContractSignedDate]							=	src.ContractSignedDate,
			[Contracttype]									=	src.Contracttype,
			[Country]										=	src.Country,
			[CreatedById]									=	src.CreatedById,
			[CreatedDate]									=	src.CreatedDate,
			[CurrencyIsoCode]								=	src.CurrencyIsoCode,
			[DeliveredDate]									=	src.DeliveredDate,
			[Dep]											=	src.Dep,
			[Description]									=	src.[Description],
			[Distributor]									=	src.Distributor,
			[ExpectedRevenue]								=	src.ExpectedRevenue,
			[FundingSource]									=	src.FundingSource,
			[GoDigital]										=	src.GoDigital,
			[GoDigitalOpp]									=	src.GoDigitalOpp,
			[HasOpportunityLineItem]						=	src.HasOpportunityLineItem,
			[isRefurbishedProduct]							=	src.isRefurbishedProduct,
			[IsDeleted]										=	src.IsDeleted,
			[iTeroType]										=	src.iTeroType,
			[LastModifiedDate]								=	src.LastModifiedDate,
			[LeadSource]									=	src.LeadSource,
			[LeasingCompany]								=	src.LeasingCompany,
			[Name]											=	src.[Name],
			[NumberofScanners]								=	src.NumberofScanners,
			[PaymentType]									=	src.PaymentType,
			[Probability]									=	src.Probability,
			[ProductOption]									=	src.ProductOption,
			[Promotion]										=	src.Promotion,
			[RecordTypeId]									=	src.RecordTypeId,
			[RequestFormat]									=	src.RequestFormat,
			[ScannerDemoDate]								=	src.ScannerDemoDate,
			[ScannerQuantity]								=	src.ScannerQuantity,
			[ScannerSalesChannel]							=	src.ScannerSalesChannel,
			[ScannerSN]										=	src.ScannerSN,
			[SubLeadSource]									=	src.SubLeadSource,
			[SystemModstamp]								=	src.SystemModstamp,
			[TotalQuantity]									=	src.TotalQuantity,
			[TotalOpportunityQuantity]						=	src.TotalOpportunityQuantity,
			[TradeInSerialNumber]							=	src.TradeInSerialNumber,
			[RoutedDate]									=	src.RoutedDate,
			[ParentOpportunity]								=	src.ParentOpportunity
	from #TempDimOpportunity src
	where [DWIRIS].[DimOpportunity].SKOpportunity	=	src.SKOpportunity
		and [DWIRIS].[DimOpportunity].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimOpportunity_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimOpportunity_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimOpportunity] (
				[SKOpportunity],
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				[DWBatchID],
				[DWHash],
				[KeyOpportunity],
				[SKUser],
				[SKAccount],
				[OpportunityName],
				[OpportunityNumber],
				[CommissionDate],
				[ShippedDate],
				[SaleType],
				[OpportunityId_C],
				[GeneratedBy],
				[CloseDate],
				[Amount],
				[ProductName],
				[StageName],
				[DemoDate],
				[ContractLoadDate]
				,[AgreementEffectiveDate]
				,[AlertStatusDate]
				,[AlignSignatureDate]
				,[CancellationDate]
				,[CancellationReason]
				,[CancellationStatus]
				,[Cancelled]
				,[ChildOpportunityId]
				,[ClosedReason]
				,[CompetitorInvolved]
				,[Contact]
				,[ContractSignedDate]
				,[Contracttype]
				,[Country]
				,[CreatedById]
				,[CreatedDate]
				,[CurrencyIsoCode]
				,[DeliveredDate]
				,[Dep]
				,[Description]
				,[Distributor]
				,[ExpectedRevenue]
				,[FundingSource]
				,[GoDigital]
				,[GoDigitalOpp]
				,[HasOpportunityLineItem]
				,[isRefurbishedProduct]
				,[IsDeleted]
				,[iTeroType]
				,[LastModifiedDate]
				,[LeadSource]
				,[LeasingCompany]
				,[Name]
				,[NumberofScanners]
				,[PaymentType]
				,[Probability]
				,[ProductOption]
				,[Promotion]
				,[RecordTypeId]
				,[RequestFormat]
				,[ScannerDemoDate]
				,[ScannerQuantity]
				,[ScannerSalesChannel]
				,[ScannerSN]
				,[SubLeadSource]
				,[SystemModstamp]
				,[TotalQuantity]
				,[TotalOpportunityQuantity]
				,[TradeInSerialNumber]
				,[RoutedDate]
				,[ParentOpportunity]

		   )
	select 
				[SKOpportunity],
				[ADLSBatchID],
				[ADLSTimestamp],
				[LZBatchID],
				@BatchID,
				[DWHash],
				[KeyOpportunity],
				[SKUser],
				[SKAccount],
				[OpportunityName],
				[OpportunityNumber],
				[CommissionDate],
				[ShippedDate],
				[SaleType],
				[OpportunityId_C],
				[GeneratedBy],
				[CloseDate],
				[Amount],
				[ProductName],
				[StageName],
				[DemoDate],
				[ContractLoadDate]
				,[AgreementEffectiveDate]
				,[AlertStatusDate]
				,[AlignSignatureDate]
				,[CancellationDate]
				,[CancellationReason]
				,[CancellationStatus]
				,[Cancelled]
				,[ChildOpportunityId]
				,[ClosedReason]
				,[CompetitorInvolved]
				,[Contact]
				,[ContractSignedDate]
				,[Contracttype]
				,[Country]
				,[CreatedById]
				,[CreatedDate]
				,[CurrencyIsoCode]
				,[DeliveredDate]
				,[Dep]
				,[Description]
				,[Distributor]
				,[ExpectedRevenue]
				,[FundingSource]
				,[GoDigital]
				,[GoDigitalOpp]
				,[HasOpportunityLineItem]
				,[isRefurbishedProduct]
				,[IsDeleted]
				,[iTeroType]
				,[LastModifiedDate]
				,[LeadSource]
				,[LeasingCompany]
				,[Name]
				,[NumberofScanners]
				,[PaymentType]
				,[Probability]
				,[ProductOption]
				,[Promotion]
				,[RecordTypeId]
				,[RequestFormat]
				,[ScannerDemoDate]
				,[ScannerQuantity]
				,[ScannerSalesChannel]
				,[ScannerSN]
				,[SubLeadSource]
				,[SystemModstamp]
				,[TotalQuantity]
				,[TotalOpportunityQuantity]
				,[TradeInSerialNumber]
				,[RoutedDate]
				,[ParentOpportunity]
	from #TempDimOpportunity src
	where not exists(select dst.SKOpportunity from DWIRIS.DimOpportunity dst where dst.SKOpportunity = src.SKOpportunity)
	option (label = 'DWIRIS.LoadDimOpportunity_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimOpportunity_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure