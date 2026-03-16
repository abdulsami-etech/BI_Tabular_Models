CREATE PROC [DW].[LoadDimLeadCall] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0), @IsForceFullLoad [bit] AS
BEGIN
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimLeadCall') is not null
		drop table #TempDimLeadCall

	create table #TempDimLeadCall with (distribution = round_robin, heap) as 
	select	c.ADLSBatchID															as ADLSBatchID
		,	c.ADLSTimestamp															as ADLSTimestamp
		,	c.LZBatchID																as LZBatchID
		,	convert(char(40), '')													as DWHash
		
		,	hub.SKLeadCall															as SKLeadCall
		,	c.Id																	as KeyLeadCall

		,c.[Call_Connected__c]										as [CallConnected]
		,c.[CreatedById]											as [CreatedById]
		,u_created.[UserName]										as [CreatedByUserName]
		,c.[CreatedDate]											as [CreatedDate]
		,c.[CurrencyIsoCode]										as [CurrencyIsoCode]
		,c.[IsDeleted]												as [IsDeleted]
		,c.[LastModifiedById]										as [LastModifiedById]
		,u_modify.[UserName]										as [LastModifiedByUserName]
		,c.[Name]													as [Name]
		,c.[OwnerId]												as [OwnerId]
		,u_owner.[UserName]											as [OwnerUserName]
		,c.[ringdna105__Abandoned_Call__c]							as [RingAbandonedCall]
		,c.[ringdna105__Account__c]									as [RingAccountId]
		,c.[ringdna105__ActivityDate__c]							as [RingActivityDate]
		,c.[ringdna105__Call_Connected__c]							as [RingCallConnected]
		,c.[ringdna105__Call_Direction__c]							as [RingCallDirection]
		,c.[ringdna105__Call_Duration__c]							as [RingCallDuationSec]
		,c.[ringdna105__Call_Hour_Of_Day_Agent__c]					as [RingCallHourOfDayAgent]
		,c.[ringdna105__Call_Hour_Of_Day_Local__c]					as [RingCallHourOfDayLocal]
		,c.[ringdna105__Call_Status__c]								as [RingCallStatus]
		,c.[ringdna105__CallObject__c]								as [RingCallObject]
		,c.[ringdna105__Campaign__c]								as [RingCampaignId]
		,c.[ringdna105__Contact__c]									as [RingContactId]
		,c.[ringdna105__Lead__c]									as [RingLeadId]
		,c.[ringdna105__Description__c]								as [RingDescription]
		,c.[ringdna105__Local_Presence__c]							as [RingLocalPresence]
		,c.[ringdna105__Status__c]									as [RingStatus]
		,c.[SystemModstamp]											as [SystemModstamp]
		,c.[Time_of_day__c]											as [TimeOfDay]
		,l.CountryCode												as [LeadCountryCode]
		,l.Country													as [LeadCountry]
		,DimReg.SecRegion

	FROM [SrcSFDC].[ringdna105__Call__c] c
		inner join DW.HubLeadCall hub on hub.KeyLeadCall=c.Id
		left join DW.[DimUser] u_created on u_created.KeyUser=c.[CreatedById]
		left join DW.[DimUser] u_modify  on u_modify.KeyUser=c.[LastModifiedById]
		left join DW.[DimUser] u_owner  on u_owner.KeyUser=c.[OwnerId]
		left join SrcSFDC.Lead l on l.Id=c.[ringdna105__Lead__c]
		LEFT JOIN Custom.GeographyHierarchy DimReg on l.[CountryCode]=DimReg.CountryCode

	update #TempDimLeadCall set DWHash=
		convert(char(40),
			hashbytes('SHA1',
							 isnull(convert(nvarchar, [CallConnected]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedById]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedByUserName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CurrencyIsoCode]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [IsDeleted]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LastModifiedById]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LastModifiedByUserName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Name]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [OwnerId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [OwnerUserName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingAbandonedCall]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingAccountId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingActivityDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCallConnected]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCallDirection]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCallDuationSec]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCallHourOfDayAgent]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCallHourOfDayLocal]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCallStatus]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCallObject]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingCampaignId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingContactId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingLeadId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingDescription]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingLocalPresence]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RingStatus]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SystemModstamp]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [TimeOfDay]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LeadCountryCode]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LeadCountry]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SecRegion]), N'N/A')
				)
			, 2)

	if @IsForceFullLoad=1 truncate table DW.DimLeadCall

	if not exists (select * from DW.DimLeadCall where SKLeadCall = -1)
	begin
		declare @Hash char(40) = ''
			,	@CurrentDate datetime2(7) = getdate()

		insert into DW.DimLeadCall (
				SKLeadCall
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyLeadCall

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

	update DW.DimLeadCall
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash

		,[CallConnected] =src.[CallConnected]
		,[CreatedById] =src.[CreatedById]
		,[CreatedByUserName] =src.[CreatedByUserName]
		,[CreatedDate] =src.[CreatedDate]
		,[CurrencyIsoCode] =src.[CurrencyIsoCode]
		,[IsDeleted] =src.[IsDeleted]
		,[LastModifiedById] =src.[LastModifiedById]
		,[LastModifiedByUserName] =src.[LastModifiedByUserName]
		,[Name] =src.[Name]
		,[OwnerId] =src.[OwnerId]
		,[OwnerUserName] =src.[OwnerUserName]
		,[RingAbandonedCall] =src.[RingAbandonedCall]
		,[RingAccountId] =src.[RingAccountId]
		,[RingActivityDate] =src.[RingActivityDate]
		,[RingCallConnected] =src.[RingCallConnected]
		,[RingCallDirection] =src.[RingCallDirection]
		,[RingCallDuationSec] =src.[RingCallDuationSec]
		,[RingCallHourOfDayAgent] =src.[RingCallHourOfDayAgent]
		,[RingCallHourOfDayLocal] =src.[RingCallHourOfDayLocal]
		,[RingCallStatus] =src.[RingCallStatus]
		,[RingCallObject] =src.[RingCallObject]
		,[RingCampaignId] =src.[RingCampaignId]
		,[RingContactId] =src.[RingContactId]
		,[RingLeadId] =src.[RingLeadId]
		,[RingDescription] =src.[RingDescription]
		,[RingLocalPresence] =src.[RingLocalPresence]
		,[RingStatus] =src.[RingStatus]
		,[SystemModstamp] =src.[SystemModstamp]
		,[TimeOfDay] =src.[TimeOfDay]
		,[LeadCountryCode]=src.[LeadCountryCode]
		,[LeadCountry]=src.[LeadCountry]
		,[SecRegion]=src.[SecRegion]
		
	from #TempDimLeadCall src
	where DW.DimLeadCall.SKLeadCall = src.SKLeadCall
		and DW.DimLeadCall.DWHash != src.DWHash
	option (label = 'DW.LoadDimLeadCall_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimLeadCall_Update', @rc = @RowsUpdated out



	insert into DW.DimLeadCall (
			SKLeadCall
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyLeadCall

		,[CallConnected]
		,[CreatedById]
		,[CreatedByUserName]
		,[CreatedDate]
		,[CurrencyIsoCode]
		,[IsDeleted]
		,[LastModifiedById]
		,[LastModifiedByUserName]
		,[Name]
		,[OwnerId]
		,[OwnerUserName]
		,[RingAbandonedCall]
		,[RingAccountId]
		,[RingActivityDate]
		,[RingCallConnected]
		,[RingCallDirection]
		,[RingCallDuationSec]
		,[RingCallHourOfDayAgent]
		,[RingCallHourOfDayLocal]
		,[RingCallStatus]
		,[RingCallObject]
		,[RingCampaignId]
		,[RingContactId]
		,[RingLeadId]
		,[RingDescription]
		,[RingLocalPresence]
		,[RingStatus]
		,[SystemModstamp]
		,[TimeOfDay]
		,[LeadCountryCode]
		,[LeadCountry]
		,[SecRegion]
	)
	select	src.SKLeadCall
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyLeadCall

		,src.[CallConnected]
		,src.[CreatedById]
		,src.[CreatedByUserName]
		,src.[CreatedDate]
		,src.[CurrencyIsoCode]
		,src.[IsDeleted]
		,src.[LastModifiedById]
		,src.[LastModifiedByUserName]
		,src.[Name]
		,src.[OwnerId]
		,src.[OwnerUserName]
		,src.[RingAbandonedCall]
		,src.[RingAccountId]
		,src.[RingActivityDate]
		,src.[RingCallConnected]
		,src.[RingCallDirection]
		,src.[RingCallDuationSec]
		,src.[RingCallHourOfDayAgent]
		,src.[RingCallHourOfDayLocal]
		,src.[RingCallStatus]
		,src.[RingCallObject]
		,src.[RingCampaignId]
		,src.[RingContactId]
		,src.[RingLeadId]
		,src.[RingDescription]
		,src.[RingLocalPresence]
		,src.[RingStatus]
		,src.[SystemModstamp]
		,src.[TimeOfDay]
		,src.[LeadCountryCode]
		,src.[LeadCountry]
		,src.[SecRegion]


	from #TempDimLeadCall src
	where not exists (select dst.SKLeadCall from DW.DimLeadCall dst where dst.SKLeadCall = src.SKLeadCall)
	option (label = 'DW.LoadDimLeadCall_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimLeadCall_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
