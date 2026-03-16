CREATE PROC [DWIRIS].[LoadDimProposal] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimProposal') is not null
		drop table #TempDimProposal

-- Get delta rows
	create table #TempDimProposal with (distribution = round_robin, heap) as 
	SELECT 
			 h.SKProposal													as SKProposal
			,prop.ADLSBatchID												as ADLSBatchID
			,prop.ADLSTimestamp												as ADLSTimestamp
			,prop.LZBatchID													as LZBatchID
			,prop.DWHash													as DWHash
			,prop.KeyProposal												as KeyProposal
			,prop.AccountNumber												as AccountNumber 
			,prop.ApprovalStage												as ApprovalStage 	
			,prop.ProposalPrimary											as ProposalPrimary
			,prop.PrimaryContactId											as PrimaryContactId 
			,prop.CreatedDate												as CreatedDate
			,prop.ProposalElementScannerType								as ProposalElementScannerType
			,prop.ProposalName												as ProposalName
			,prop.ServiceFeesPAV											as ServiceFeesPAV
			,prop.ProposalId												as ProposalId
			,prop.TreatmentCategory											as TreatmentCategory
			,prop.ProposalLastModifiedDate									as ProposalLastModifiedDate
			,prop.OpportunityId												as OpportunityId
			,prop.ProductName												as ProductName
			,prop.Quantity1													as Quantity1 
			,prop.ProposalQuantity											as ProposalQuantity 
			,prop.IsPrimaryLine												as IsPrimaryLine
			,prop.LineItemElementScannerType								as LineItemElementScannerType
			,prop.LineItemName												as LineItemName
			,prop.LineItemLastModifiedDate									as LineItemLastModifiedDate
			,prop.ProductCode												as ProductCode
			,prop.OpportunityNumber											as OpportunityNumber
			,prop.IncentiveCode												as IncentiveCode
			,prop.NetPrice													as NetPrice
			,prop.ListPrice													as ListPrice
			,prop.IsDeleted													as IsDeleted		
		from (
				select
					 pr.ADLSBatchID													as ADLSBatchID
					,pr.ADLSTimestamp												as ADLSTimestamp
					,pr.LZBatchID													as LZBatchID
					,convert(char(40), '')											as DWHash
					,pr.Id + isnull(li.Id,'') 										as KeyProposal
					,pr.[Account_Number_from_Account__c]							as AccountNumber 
					,pr.[Apttus_Proposal__Approval_Stage__c]						as ApprovalStage 	
					,pr.[Apttus_Proposal__Primary__c]								as ProposalPrimary
					,pr.[Apttus_Proposal__Primary_Contact__c]						as PrimaryContactId 
					,pr.[Created_Date__c]										    as CreatedDate
					,pr.[Element_Scanner_Type__c]									as ProposalElementScannerType
					,pr.[Name]														as ProposalName
					,pr.[Service_Fees_PAV__c]										as ServiceFeesPAV
					,pr.[Id]														as ProposalId
					,pr.[Treatment_Category__c]										as TreatmentCategory
					,pr.[LastModifiedDate]										    as ProposalLastModifiedDate
					,pr.[Apttus_Proposal__Opportunity__c]						    as OpportunityId
					,li.[APTS_Product_Name__c]										as ProductName
					,li.[APTS_Quantity1__c]											as Quantity1 
					,li.[Apttus_Proposal__Quantity__c]								as ProposalQuantity 
					,li.[Apttus_QPConfig__IsPrimaryLine__c]							as IsPrimaryLine
					,li.[Element_Scanner_Type__c]									as LineItemElementScannerType
					,li.[Name]														as LineItemName
					,li.[LastModifiedDate]											as LineItemLastModifiedDate
					,li.[Product_Code__c]											as ProductCode
					,opp.[Opportunity_Number__c]									as OpportunityNumber
					,li.[Apttus_QPConfig__IncentiveCode__c]							as IncentiveCode
					,li.[Apttus_QPConfig__NetPrice__c]								as NetPrice
					,li.[Apttus_QPConfig__ListPrice__c]								as ListPrice
					,li.IsDeleted													as IsDeleted
				from [SrcSFDC].[Apttus_Proposal__Proposal__c] pr
				left join [SrcSFDC].[Apttus_Proposal__Proposal_Line_Item__c] li
					on pr.Id = li.[Apttus_Proposal__Proposal__c]
				left join SrcSFDC.Opportunity opp
					on opp.Id = pr.[Apttus_Proposal__Opportunity__c]
				where (pr.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimProposal)
						or
						li.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimProposal)
					  )
			) prop
		join DWIRIS.HubProposal h
			on h.[KeyProposal] = prop.KeyProposal 
		
		
	--update HASH
	update #TempDimProposal set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         ISNULL(convert(nvarchar,KeyProposal),'')
					+'|'+ISNULL(convert(nvarchar,AccountNumber ),'')
					+'|'+ISNULL(convert(nvarchar,ApprovalStage),'')
					+'|'+ISNULL(convert(nvarchar,ProposalPrimary),'')
					+'|'+ISNULL(convert(nvarchar,PrimaryContactId),'')
					+'|'+ISNULL(convert(nvarchar,CreatedDate),'')
					+'|'+ISNULL(convert(nvarchar,ProposalElementScannerType),'')
					+'|'+ISNULL(convert(nvarchar,ProposalName),'')
					+'|'+ISNULL(convert(nvarchar,ServiceFeesPAV),'')
					+'|'+ISNULL(convert(nvarchar,ProposalId),'')
					+'|'+ISNULL(convert(nvarchar,TreatmentCategory),'')
					+'|'+ISNULL(convert(nvarchar,ProposalLastModifiedDate),'')
					+'|'+ISNULL(convert(nvarchar,OpportunityId),'')
					+'|'+ISNULL(convert(nvarchar,ProductName),'')
					+'|'+ISNULL(convert(nvarchar,Quantity1),'')
					+'|'+ISNULL(convert(nvarchar,ProposalQuantity),'')
					+'|'+ISNULL(convert(nvarchar,IsPrimaryLine),'')
					+'|'+ISNULL(convert(nvarchar,LineItemElementScannerType),'')
					+'|'+ISNULL(convert(nvarchar,LineItemName),'')
					+'|'+ISNULL(convert(nvarchar,LineItemLastModifiedDate),'')
					+'|'+ISNULL(convert(nvarchar,ProductCode),'')
					+'|'+ISNULL(convert(nvarchar,OpportunityNumber),'')
					+'|'+ISNULL(convert(nvarchar,IncentiveCode),'')
					+'|'+ISNULL(convert(nvarchar,ListPrice),'')
					+'|'+ISNULL(convert(nvarchar,NetPrice),'')
					+'|'+ISNULL(convert(nvarchar,IsDeleted),'')
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimProposal] where SKProposal = -1)
	begin
		declare @Hash char(40) = ''

		insert into DWIRIS.DimProposal (
				[SKProposal]
			,[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,[DWBatchID]
           ,[DWHash]
           ,[KeyProposal]
           ,[AccountNumber]
           ,[ApprovalStage]
           ,[ProposalPrimary]
           ,[PrimaryContactId]
           ,[CreatedDate]
           ,[ProposalElementScannerType]
           ,[ProposalName]
           ,[ServiceFeesPAV]
           ,[ProposalId]
           ,[TreatmentCategory]
           ,[ProposalLastModifiedDate]
           ,[OpportunityId]
           ,[ProductName]
           ,[Quantity1]
           ,[ProposalQuantity]
           ,[IsPrimaryLine]
           ,[LineItemElementScannerType]
           ,[LineItemName]
           ,[LineItemLastModifiedDate]
           ,[ProductCode]
	   ,[OpportunityNumber]
	   ,[IncentiveCode]
	   ,[NetPrice]
	   ,[ListPrice]	
	   ,[IsDeleted]
		)
		values (
				-1					-- SKProposal
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
			,   'N/A'				--[KeyProposal]
			,	'N/A'				--[AccountNumber]
			,	'N/A'				--[ApprovalStage]
			,	-1					--[ProposalPrimary]
			,	'N/A'				--[PrimaryContactId]
			,	'19000101'			--[CreatedDate]
			,	'N/A'				--[ProposalElementScannerType]
			,	'N/A'				--[ProposalName]
			,	'N/A'				--[ServiceFeesPAV]
			,	'N/A'				--[ProposalId]
			,	'N/A'				--[TreatmentCategory]
			,   '19000101'			--[ProposalLastModifiedDate]
			,	'N/A'				--[OpportunityId]
			,   'N/A'				--[ProductName]
			,	-1					--[Quantity1]
			,   -1					--[ProposalQuantity]
			,	-1					--[IsPrimaryLine]
			,	'N/A'				--[LineItemElementScannerType]
			,   'N/A'				--[LineItemName]
			,	'19000101'			--[LineItemLastModifiedDate]
			,   'N/A'				--[ProductCode]
			,   'N/A'				--[OpportunityNumber]
			,   'N/A'				--[IncentiveCode]
			,   -1					--[NetPrice]
			,   -1					--[ListPrice]
			,	-1					--[IsDeleted]
	)
	end


	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimProposal]
		set
		   ADLSBatchID										=	src.ADLSBatchID
		  ,ADLSTimestamp									=	src.ADLSTimestamp
		  ,LZBatchID										=	src.LZBatchID
		  ,DWBatchID										=	@BatchID
		  ,DWHash											=	src.DWHash
 		  ,[KeyProposal]									=	src.[KeyProposal]
		  ,[AccountNumber]									=	src.[AccountNumber]
		  ,[ApprovalStage]									=	src.[ApprovalStage]
		  ,[ProposalPrimary]								=	src.[ProposalPrimary]
		  ,[PrimaryContactId]								=	src.[PrimaryContactId]
 		  ,[CreatedDate]									=	src.[CreatedDate]
		  ,[ProposalElementScannerType]						=	src.[ProposalElementScannerType]
		  ,[ProposalName]									=	src.[ProposalName]
		  ,[ServiceFeesPAV]									=	src.[ServiceFeesPAV]
		  ,[ProposalId]										=	src.[ProposalId]
		  ,[TreatmentCategory]								=	src.[TreatmentCategory]
		  ,[ProposalLastModifiedDate]						=	src.[ProposalLastModifiedDate]
		  ,[OpportunityId]									=	src.[OpportunityId]
		  ,[ProductName]									=	src.[ProductName]
		  ,[Quantity1]										=	src.[Quantity1]
		  ,[ProposalQuantity]								=	src.[ProposalQuantity]
		  ,[IsPrimaryLine]									=	src.[IsPrimaryLine]
		  ,[LineItemElementScannerType]						=	src.[LineItemElementScannerType]
		  ,[LineItemName]									=	src.[LineItemName]
		  ,[LineItemLastModifiedDate]						=	src.[LineItemLastModifiedDate]
		  ,[ProductCode]									=	src.[ProductCode]
		  ,[OpportunityNumber]								=	src.[OpportunityNumber]
		  ,[IncentiveCode]									=	src.[IncentiveCode]
		  ,[NetPrice]										=	src.[NetPrice]
		  ,[ListPrice]										=	src.[ListPrice]
		  ,[IsDeleted]										=	src.[IsDeleted]
	from #TempDimProposal src
	where [DWIRIS].[DimProposal].SKProposal	=	src.SKProposal
		and [DWIRIS].[DimProposal].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimProposal_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimProposal_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimProposal] (
			[SKProposal]
		   ,[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,[DWBatchID]
           ,[DWHash]
           ,[KeyProposal]
           ,[AccountNumber]
           ,[ApprovalStage]
           ,[ProposalPrimary]
           ,[PrimaryContactId]
           ,[CreatedDate]
           ,[ProposalElementScannerType]
           ,[ProposalName]
           ,[ServiceFeesPAV]
           ,[ProposalId]
           ,[TreatmentCategory]
           ,[ProposalLastModifiedDate]
           ,[OpportunityId]
           ,[ProductName]
           ,[Quantity1]
           ,[ProposalQuantity]
           ,[IsPrimaryLine]
           ,[LineItemElementScannerType]
           ,[LineItemName]
           ,[LineItemLastModifiedDate]
           ,[ProductCode]
           ,[OpportunityNumber]
		   ,[IncentiveCode]
	   ,[NetPrice]
	   ,[ListPrice]
	   ,[IsDeleted]
		   )
	select 
			[SKProposal]
		   ,[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,@BatchID
           ,[DWHash]
           ,[KeyProposal]
           ,[AccountNumber]
           ,[ApprovalStage]
           ,[ProposalPrimary]
           ,[PrimaryContactId]
           ,[CreatedDate]
           ,[ProposalElementScannerType]
           ,[ProposalName]
           ,[ServiceFeesPAV]
           ,[ProposalId]
           ,[TreatmentCategory]
           ,[ProposalLastModifiedDate]
           ,[OpportunityId]
           ,[ProductName]
           ,[Quantity1]
           ,[ProposalQuantity]
           ,[IsPrimaryLine]
           ,[LineItemElementScannerType]
           ,[LineItemName]
           ,[LineItemLastModifiedDate]
           ,[ProductCode]
           ,[OpportunityNumber]
		   ,[IncentiveCode]
			,[NetPrice]
			,[ListPrice]
			,[IsDeleted]
	from #TempDimProposal src
	where not exists(select dst.SKProposal from DWIRIS.DimProposal dst where dst.SKProposal = src.SKProposal)
	option (label = 'DWIRIS.LoadDimProposal_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimProposal_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end