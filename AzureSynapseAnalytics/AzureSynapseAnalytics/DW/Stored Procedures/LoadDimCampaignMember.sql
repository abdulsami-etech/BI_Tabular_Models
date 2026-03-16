CREATE PROC [DW].[LoadDimCampaignMember] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimCampaignMember') is not null
		drop table #TempDimCampaignMember

	create table #TempDimCampaignMember with (distribution = round_robin, heap) as 
	select	c.ADLSBatchID															as ADLSBatchID
		,	c.ADLSTimestamp															as ADLSTimestamp
		,	c.LZBatchID																as LZBatchID
		,	convert(char(40), '')													as DWHash
		
		,	hub.SKCampaignMember													as SKCampaignMember
		,	m.Id																	as KeyCampaignMember

		  ,m.[CampaignId]							as [CampaignId]
		  ,m.[City]									as [City]
		  ,m.[CompanyOrAccount]						as [CompanyOrAccount]
		  ,m.[ContactId]							as [ContactId]
		  ,m.[Country]								as [Country]
		  ,m.[Createdby_Role__c]					as [CreatedByRole]
		  ,m.[Createdby_User__c]					as [CreatedByUser]
		  ,m.[CreatedById]							as [CreatedById]
		  ,m.[CreatedDate]							as [CreatedDate]
		  ,m.[CurrencyIsoCode]						as [CurrencyIsoCode]
		  ,m.[DID__c]								as [DID]
		  ,m.[DID_Number__c]						as [DIDNumber]
		  ,m.[Email]								as [Email]
		  ,m.[FirstName]							as [FirstName]
		  ,m.[FirstRespondedDate]					as [FirstRespondedDate]
		  ,m.[Is_Attended__c]						as [IsAttended]
		  ,m.[IsDeleted]							as [IsDeleted]
		  ,m.[LastModifiedById]						as [LastModifiedById]
		  ,m.[LastModifiedDate]						as [LastModifiedDate]
		  ,m.[LastName]								as [LastName]
		  ,m.[LeadId]								as [LeadId]
		  ,m.[LeadOrContactId]						as [LeadOrContactId]
		  ,m.[LeadOrContactOwnerId]					as [LeadOrContactOwnerId]
		  ,m.[LeadSource]							as [LeadSource]
		  ,m.[Name]									as [Name]
		  ,m.[Original_Type__c]						as [OriginalType]
		  ,m.[RecordTypeId]							as [RecordTypeId]
		  ,m.[Status]								as [Status] 
		  ,m.[Status_Reason__c]						as [StatusReason]
		  ,m.[SystemModstamp]						as [SystemModstamp]
		  ,m.[Type]									as [Type]
		
		, ISNULL(DimReg.SecRegion,'')					as SecRegion
	
	from SrcSFDC.CampaignMember m
		inner join SrcSFDC.Campaign c on c.Id=m.CampaignID
		inner join DW.HubCampaignMember hub on hub.KeyCampaignMember = m.Id
		left join Custom.GeographyHierarchy DimReg on c.[Event_Country__c]=DimReg.CountryCode


	update #TempDimCampaignMember set DWHash=
		convert(char(40),
			hashbytes('SHA1',
							 isnull(convert(nvarchar, [CampaignId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [City]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CompanyOrAccount]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ContactId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Country]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedByRole]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedByUser]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedById]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CurrencyIsoCode]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [DID]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [DIDNumber]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Email]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [FirstName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [FirstRespondedDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [IsAttended]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [IsDeleted]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LastModifiedById]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LastModifiedDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LastName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LeadId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LeadOrContactId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LeadOrContactOwnerId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LeadSource]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Name]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [OriginalType]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RecordTypeId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Status]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [StatusReason]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SystemModstamp]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Type]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SecRegion]), N'N/A')
				)
			, 2)

	if not exists (select * from DW.DimCampaignMember where SKCampaignMember = -1)
	begin
		declare @Hash char(40) = ''
			,	@CurrentDate datetime2(7) = getdate()

		insert into DW.DimCampaignMember (
				SKCampaignMember
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyCampaignMember
			,   CampaignID

		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	N'N/A'
		)
	end

	update DW.DimCampaignMember
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash

		 ,[CampaignId]	 				=src.[CampaignId]
		 ,[City]						=src.[City]
		 ,[CompanyOrAccount]	 		=src.[CompanyOrAccount]
		 ,[ContactId]	 				=src.[ContactId]
		 ,[Country]	 					=src.[Country]
		 ,[CreatedByRole]	 			=src.[CreatedByRole]
		 ,[CreatedByUser]	 			=src.[CreatedByUser]
		 ,[CreatedById]	 				=src.[CreatedById]
		 ,[CreatedDate]	 				=src.[CreatedDate]
		 ,[CurrencyIsoCode]	 			=src.[CurrencyIsoCode]
		 ,[DID]	 						=src.[DID]
		 ,[DIDNumber]	 				=src.[DIDNumber]
		 ,[Email]	 					=src.[Email]
		 ,[FirstName]	 				=src.[FirstName]
		 ,[FirstRespondedDate]	 		=src.[FirstRespondedDate]
		 ,[IsAttended]	 				=src.[IsAttended]
		 ,[IsDeleted]	 				=src.[IsDeleted]
		 ,[LastModifiedById]	 		=src.[LastModifiedById]
		 ,[LastModifiedDate]	 		=src.[LastModifiedDate]
		 ,[LastName]	 				=src.[LastName]
		 ,[LeadId]	 					=src.[LeadId]
		 ,[LeadOrContactId]	 			=src.[LeadOrContactId]
		 ,[LeadOrContactOwnerId]	 	=src.[LeadOrContactOwnerId]
		 ,[LeadSource]	 				=src.[LeadSource]
		 ,[Name]	 					=src.[Name]
		 ,[OriginalType]	 			=src.[OriginalType]
		 ,[RecordTypeId]	 			=src.[RecordTypeId]
		 ,[Status]	 					=src.[Status]
		 ,[StatusReason]	 			=src.[StatusReason]
		 ,[SystemModstamp]	 			=src.[SystemModstamp]
		 ,[Type]	 					=src.[Type]
		 ,[SecRegion]	 				=src.[SecRegion]
		
	from #TempDimCampaignMember src
	where DW.DimCampaignMember.SKCampaignMember = src.SKCampaignMember
		and DW.DimCampaignMember.DWHash != src.DWHash
	option (label = 'DW.LoadDimCampaignMember_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimCampaignMember_Update', @rc = @RowsUpdated out



	insert into DW.DimCampaignMember (
			SKCampaignMember
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyCampaignMember

		  ,[CampaignId]
		  ,[City]
		  ,[CompanyOrAccount]
		  ,[ContactId]
		  ,[Country]
		  ,[CreatedByRole]
		  ,[CreatedByUser]
		  ,[CreatedById]
		  ,[CreatedDate]
		  ,[CurrencyIsoCode]
		  ,[DID]
		  ,[DIDNumber]
		  ,[Email]
		  ,[FirstName]
		  ,[FirstRespondedDate]
		  ,[IsAttended]
		  ,[IsDeleted]
		  ,[LastModifiedById]
		  ,[LastModifiedDate]
		  ,[LastName]
		  ,[LeadId]
		  ,[LeadOrContactId]
		  ,[LeadOrContactOwnerId]
		  ,[LeadSource]
		  ,[Name]
		  ,[OriginalType]
		  ,[RecordTypeId]
		  ,[Status]
		  ,[StatusReason]
		  ,[SystemModstamp]
		  ,[Type]
		  ,[SecRegion]

	)
	select	src.SKCampaignMember
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyCampaignMember

		  ,src.[CampaignId]
		  ,src.[City]
		  ,src.[CompanyOrAccount]
		  ,src.[ContactId]
		  ,src.[Country]
		  ,src.[CreatedByRole]
		  ,src.[CreatedByUser]
		  ,src.[CreatedById]
		  ,src.[CreatedDate]
		  ,src.[CurrencyIsoCode]
		  ,src.[DID]
		  ,src.[DIDNumber]
		  ,src.[Email]
		  ,src.[FirstName]
		  ,src.[FirstRespondedDate]
		  ,src.[IsAttended]
		  ,src.[IsDeleted]
		  ,src.[LastModifiedById]
		  ,src.[LastModifiedDate]
		  ,src.[LastName]
		  ,src.[LeadId]
		  ,src.[LeadOrContactId]
		  ,src.[LeadOrContactOwnerId]
		  ,src.[LeadSource]
		  ,src.[Name]
		  ,src.[OriginalType]
		  ,src.[RecordTypeId]
		  ,src.[Status]
		  ,src.[StatusReason]
		  ,src.[SystemModstamp]
		  ,src.[Type]
		  ,src.[SecRegion]

	from #TempDimCampaignMember src
	where not exists (select dst.SKCampaignMember from DW.DimCampaignMember dst where dst.SKCampaignMember = src.SKCampaignMember)
	option (label = 'DW.LoadDimCampaignMember_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimCampaignMember_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
