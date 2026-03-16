CREATE PROC [DW].[LoadDimLeadConversation] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0), @IsForceFullLoad [bit] AS
BEGIN
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimLeadConversation') is not null
		drop table #TempDimLeadConversation

	create table #TempDimLeadConversation with (distribution = round_robin, heap) as 
	select	c.ADLSBatchID															as ADLSBatchID
		,	c.ADLSTimestamp															as ADLSTimestamp
		,	c.LZBatchID																as LZBatchID
		,	convert(char(40), '')													as DWHash
		
		,	hub.SKLeadConversation													as SKLeadConversation
		,	c.Id																	as KeyLeadConversation

		,c.[Consumer_Lead__c]											as [ConsumerLeadId]
		,c.[Contact__c]													as [ContactId]
		,c.[CreatedById]												as [CreatedById]
		,u_created.[UserName]											as [CreatedByUserName]
		,c.[CreatedDate]												as [CreatedDate]
		,c.[CurrencyIsoCode]											as [CurrencyIsoCode]
		,c.[IsDeleted]													as [IsDeleted]
		,c.[LastModifiedById]											as [LastModifiedById]
		,u_modify.[UserName]											as [LastModifiedByUserName]
		,c.[LastModifiedDate]											as [LastModifiedDate]
		,c.[Name]														as [Name]
		,c.[OwnerId]													as [OwnerId]
		,u_owner.[UserName]												as [OwnerUserName]
		,c.[SMS_Conversation__c]										as [SMSConversation]
		,c.[SystemModstamp]												as [SystemModstamp]
		,c.[WhatsApp_Conversation__c]									as [WhatsAppConversation]
		,l.[CountryCode]												as [LeadCountryCode]
		,l.[Country]													as [LeadCountry]
		,DimReg.SecRegion

		FROM  [SrcSFDC].[Lead_Conversation__c] c
				inner join DW.HubLeadConversation hub on hub.KeyLeadConversation=c.Id
				left join DW.[DimUser] u_created on u_created.KeyUser=c.[CreatedById]
				left join DW.[DimUser] u_modify  on u_modify.KeyUser=c.[LastModifiedById]
				left join DW.[DimUser] u_owner  on u_owner.KeyUser=c.[OwnerId]
				left join SrcSFDC.Lead l on l.Id=c.Consumer_Lead__c
				LEFT JOIN Custom.GeographyHierarchy DimReg on l.[CountryCode]=DimReg.CountryCode

	update #TempDimLeadConversation set DWHash=
		convert(char(40),
			hashbytes('SHA1',
							 isnull(convert(nvarchar, [ConsumerLeadId]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [ContactId]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [CreatedById]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [CreatedByUserName]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [CreatedDate]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [CurrencyIsoCode]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [IsDeleted]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [LastModifiedById]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [LastModifiedByUserName]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [LastModifiedDate]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [Name]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [OwnerId]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [OwnerUserName]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [SMSConversation]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [SystemModstamp]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [WhatsAppConversation]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [LeadCountryCode]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [LeadCountry]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [SecRegion]), N'N/A')


				)
			, 2)

	if @IsForceFullLoad=1 truncate table DW.DimLeadConversation

	if not exists (select * from DW.DimLeadConversation where SKLeadConversation = -1)
	begin
		declare @Hash char(40) = ''
			,	@CurrentDate datetime2(7) = getdate()

		insert into DW.DimLeadConversation (
				SKLeadConversation
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyLeadConversation

		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
		)
	end

	update DW.DimLeadConversation
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash

		,[ConsumerLeadId] =src.[ConsumerLeadId]
		,[ContactId] =src.[ContactId]
		,[CreatedById] =src.[CreatedById]
		,[CreatedByUserName] =src.[CreatedByUserName]
		,[CreatedDate] =src.[CreatedDate]
		,[CurrencyIsoCode] =src.[CurrencyIsoCode]
		,[IsDeleted] =src.[IsDeleted]
		,[LastModifiedById] =src.[LastModifiedById]
		,[LastModifiedByUserName] =src.[LastModifiedByUserName]
		,[LastModifiedDate] =src.[LastModifiedDate]
		,[Name] =src.[Name]
		,[OwnerId] =src.[OwnerId]
		,[OwnerUserName] =src.[OwnerUserName]
		,[SMSConversation] =src.[SMSConversation]
		,[SystemModstamp] =src.[SystemModstamp]
		,[WhatsAppConversation] =src.[WhatsAppConversation]
		,[LeadCountryCode]=src.[LeadCountryCode]
		,[LeadCountry]=src.[LeadCountry]
		,[SecRegion]=src.[SecRegion]
		
	from #TempDimLeadConversation src
	where DW.DimLeadConversation.SKLeadConversation = src.SKLeadConversation
		and DW.DimLeadConversation.DWHash != src.DWHash
	option (label = 'DW.LoadDimLeadConversation_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimLeadConversation_Update', @rc = @RowsUpdated out



	insert into DW.DimLeadConversation (
			SKLeadConversation
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyLeadConversation

		,[ConsumerLeadId]
		,[ContactId]
		,[CreatedById]
		,[CreatedByUserName]
		,[CreatedDate]
		,[CurrencyIsoCode]
		,[IsDeleted]
		,[LastModifiedById]
		,[LastModifiedByUserName]
		,[LastModifiedDate]
		,[Name]
		,[OwnerId]
		,[OwnerUserName]
		,[SMSConversation]
		,[SystemModstamp]
		,[WhatsAppConversation]
		,[LeadCountryCode]
		,[LeadCountry]
		,[SecRegion]
	)
	select	src.SKLeadConversation
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyLeadConversation

		,src.[ConsumerLeadId]
		,src.[ContactId]
		,src.[CreatedById]
		,src.[CreatedByUserName]
		,src.[CreatedDate]
		,src.[CurrencyIsoCode]
		,src.[IsDeleted]
		,src.[LastModifiedById]
		,src.[LastModifiedByUserName]
		,src.[LastModifiedDate]
		,src.[Name]
		,src.[OwnerId]
		,src.[OwnerUserName]
		,src.[SMSConversation]
		,src.[SystemModstamp]
		,src.[WhatsAppConversation]
		,src.[LeadCountryCode]
		,src.[LeadCountry]
		,src.[SecRegion]

	from #TempDimLeadConversation src
	where not exists (select dst.SKLeadConversation from DW.DimLeadConversation dst where dst.SKLeadConversation = src.SKLeadConversation)
	option (label = 'DW.LoadDimLeadConversation_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimLeadConversation_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
