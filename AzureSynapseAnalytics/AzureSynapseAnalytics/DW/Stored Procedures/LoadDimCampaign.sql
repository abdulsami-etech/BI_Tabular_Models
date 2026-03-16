CREATE PROC [DW].[LoadDimCampaign] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimCampaign') is not null
		drop table #TempDimCampaign

	create table #TempDimCampaign with (distribution = round_robin, heap) as 
	select	c.ADLSBatchID															as ADLSBatchID
		,	c.ADLSTimestamp															as ADLSTimestamp
		,	c.LZBatchID																as LZBatchID
		,	convert(char(40), '')													as DWHash
		
		,	hub.SKCampaign															as SKCampaign
		,	c.Id																	as KeyCampaign

		  ,c.[CampaignMemberRecordTypeId]			as [CampaignMemberRecordTypeId]
		  ,c.[Capacity_Final__c]					as [CapacityFinal]
		  ,c.[Close_date_for_registrations__c]		as [ClosedDateForRegistrations]
		  ,c.[Closed_date__c]						as [ClosedDate]
		  ,c.[Comment_about_Event__c]				as [Comment]
		  ,c.[Confirmed_registrations__c]			as [ConfirmedRegistrations]
		  ,c.[Contact_Person__c]					as [ContactPerson]
		  ,c.[CreatedById]							as [CreatedById]
		  ,c.[CreatedDate]							as [CreatedDate]
		  ,c.[CurrencyIsoCode]						as [CurrencyIsoCode]
		  ,c.[Doctor_Type__c]						as [DoctorType]
		  ,c.[End_time__c]							as [EndTime]
		  ,c.[EndDate]								as [EndDate]
		  ,c.[Event_City__c]						as [EventCity]
		  ,c.[Event_Country__c]						as [EventCountry]
		  ,c.[Event_Date__c]						as [EventDate]
		  ,c.[Event_Sub_Type__c]					as [EventSubType]
		  ,c.[Event_Type__c]						as [EventType]
		  ,c.[Event_Type_Description__c]			as [EventTypeDescription]
		  ,c.[Event_type_name_standarized_Invoice__c]	as [EventTypeStandarizedInvoice]
		  ,c.[Event_Type_picklist__c]					as [EventTypePickList]
		  ,c.[Event_Type_Process_Description__c]		as [EventTypeProcessDescription]
		  ,c.[Final_Attendance__c]						as [FinalAttendance]
		  ,c.[IsActive]									as [IsActive]
		  ,c.[IsDeleted]								as [IsDeleted]
		  ,c.[Language__c]								as [Language]
		  ,c.[LastModifiedById]							as [LastModifiedById]
		  ,c.[LastModifiedDate]							as [LastModifiedDate]
		  ,c.[Name]										as [CampaignName]								
		  ,c.[NumberOfContacts]							as [NumberOfContacts]
		  ,c.[NumberOfConvertedLeads]					as [NumberOfConvertedLeads]
		  ,c.[NumberOfLeads]							as [NumberOfLeads]
		  ,c.[NumberOfOpportunities]					as [NumberOfOpportunities]
		  ,c.[NumberOfResponses]						as [NumberOfResponses]
		  ,c.[NumberOfWonOpportunities]					as [NumberOfWonOpportunities]
		  ,c.[OwnerId]									as [OwnerId]
		  ,c.[ParentId]									as [ParentId]
		  ,c.[Program_Name__c]							as [ProgramName]
		  ,c.[RecordTypeId]								as [RecordTypeId]
		  ,c.[Sales_Region__c]							as [SalesRegion]
		  ,c.[Speaker__c]								as [Speaker]
		  ,c.[Speaker1__c]								as [SpeakerId]
		  ,c.[Start_time__c]							as [StartTime]
		  ,c.[StartDate]								as [StartDate]
		  ,c.[State__c]									as [State]
		  ,c.[Status]									as [Status]
		  ,c.[Submit_Final_List__c]						as [SubmitFinalList]
		  ,c.[SystemModstamp]							as [SystemModstamp]
		  ,c.[Type]										as [Type]
		  ,c.[Venue_ID__c]								as [VenueId]
		  ,c.[Venue__c]									as [VenueCode]
		  ,c.[Event_Topic_Category__c]					as [Event Topic Category]
		
		, ISNULL(DimReg.SecRegion,'')					as SecRegion
	
	from SrcSFDC.Campaign c
		inner join DW.HubCampaign hub on hub.KeyCampaign = c.Id
		left join Custom.GeographyHierarchy DimReg on c.[Event_Country__c]=DimReg.CountryCode


	update #TempDimCampaign set DWHash=
		convert(char(40),
			hashbytes('SHA1',
							 isnull(convert(nvarchar, [CampaignMemberRecordTypeId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CapacityFinal]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ClosedDateForRegistrations]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ClosedDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Comment]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ConfirmedRegistrations]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ContactPerson]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedById]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CreatedDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CurrencyIsoCode]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [DoctorType]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EndTime]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EndDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventCity]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventCountry]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventSubType]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventType]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventTypeDescription]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventTypeStandarizedInvoice]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventTypePickList]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [EventTypeProcessDescription]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [FinalAttendance]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [IsActive]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [IsDeleted]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Language]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LastModifiedById]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [LastModifiedDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [CampaignName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [NumberOfContacts]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [NumberOfConvertedLeads]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [NumberOfLeads]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [NumberOfOpportunities]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [NumberOfResponses]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [NumberOfWonOpportunities]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [OwnerId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ParentId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [ProgramName]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [RecordTypeId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SalesRegion]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Speaker]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SpeakerId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [StartTime]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [StartDate]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [State]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Status]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SubmitFinalList]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SystemModstamp]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Type]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [VenueId]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [VenueCode]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [SecRegion]), N'N/A')
					+ N'|' + isnull(convert(nvarchar, [Event Topic Category]), N'N/A')
				)
			, 2)

	if not exists (select * from DW.DimCampaign where SKCampaign = -1)
	begin
		declare @Hash char(40) = ''
			,	@CurrentDate datetime2(7) = getdate()

		insert into DW.DimCampaign (
				SKCampaign
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyCampaign

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

	update DW.DimCampaign
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash

		  ,[CampaignMemberRecordTypeId]							=src.[CampaignMemberRecordTypeId]
		  ,[CapacityFinal]										=src.[CapacityFinal]
		  ,[ClosedDateForRegistrations]							=src.[ClosedDateForRegistrations]
		  ,[ClosedDate]											=src.[ClosedDate]
		  ,[Comment]											=src.[Comment]
		  ,[ConfirmedRegistrations]								=src.[ConfirmedRegistrations]
		  ,[ContactPerson]										=src.[ContactPerson]
		  ,[CreatedById]										=src.[CreatedById]
		  ,[CreatedDate]										=src.[CreatedDate]
		  ,[CurrencyIsoCode]									=src.[CurrencyIsoCode]
		  ,[DoctorType]											=src.[DoctorType]
		  ,[EndTime]											=src.[EndTime]
		  ,[EndDate]											=src.[EndDate]
		  ,[EventCity]											=src.[EventCity]
		  ,[EventCountry]										=src.[EventCountry]
		  ,[EventDate]											=src.[EventDate]
		  ,[EventSubType]										=src.[EventSubType]
		  ,[EventType]											=src.[EventType]
		  ,[EventTypeDescription]								=src.[EventTypeDescription]
		  ,[EventTypeStandarizedInvoice]						=src.[EventTypeStandarizedInvoice]
		  ,[EventTypePickList]									=src.[EventTypePickList]
		  ,[EventTypeProcessDescription]						=src.[EventTypeProcessDescription]
		  ,[FinalAttendance]									=src.[FinalAttendance]
		  ,[IsActive]											=src.[IsActive]
		  ,[IsDeleted]											=src.[IsDeleted]
		  ,[Language]											=src.[Language]
		  ,[LastModifiedById]									=src.[LastModifiedById]
		  ,[LastModifiedDate]									=src.[LastModifiedDate]
		  ,[CampaignName]										=src.[CampaignName]								
		  ,[NumberOfContacts]									=src.[NumberOfContacts]
		  ,[NumberOfConvertedLeads]								=src.[NumberOfConvertedLeads]
		  ,[NumberOfLeads]										=src.[NumberOfLeads]
		  ,[NumberOfOpportunities]								=src.[NumberOfOpportunities]
		  ,[NumberOfResponses]									=src.[NumberOfResponses]
		  ,[NumberOfWonOpportunities]							=src.[NumberOfWonOpportunities]
		  ,[OwnerId]											=src.[OwnerId]
		  ,[ParentId]											=src.[ParentId]
		  ,[ProgramName]										=src.[ProgramName]
		  ,[RecordTypeId]										=src.[RecordTypeId]
		  ,[SalesRegion]										=src.[SalesRegion]
		  ,[Speaker]											=src.[Speaker]
		  ,[SpeakerId]											=src.[SpeakerId]
		  ,[StartTime]											=src.[StartTime]
		  ,[StartDate]											=src.[StartDate]
		  ,[State]												=src.[State]
		  ,[Status]												=src.[Status]
		  ,[SubmitFinalList]									=src.[SubmitFinalList]
		  ,[SystemModstamp]										=src.[SystemModstamp]
		  ,[Type]												=src.[Type]
		  ,[VenueId]											=src.[VenueId]
		  ,[VenueCode]											=src.[VenueCode]
		  ,[Event Topic Category]								=src.[Event Topic Category]

		  ,SecRegion											=src.SecRegion
		
	from #TempDimCampaign src
	where DW.DimCampaign.SKCampaign = src.SKCampaign
		and DW.DimCampaign.DWHash != src.DWHash
	option (label = 'DW.LoadDimCampaign_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimCampaign_Update', @rc = @RowsUpdated out



	insert into DW.DimCampaign (
			SKCampaign
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyCampaign

		  ,[CampaignMemberRecordTypeId]							
		  ,[CapacityFinal]										
		  ,[ClosedDateForRegistrations]							
		  ,[ClosedDate]											
		  ,[Comment]											
		  ,[ConfirmedRegistrations]								
		  ,[ContactPerson]										
		  ,[CreatedById]										
		  ,[CreatedDate]										
		  ,[CurrencyIsoCode]									
		  ,[DoctorType]											
		  ,[EndTime]											
		  ,[EndDate]											
		  ,[EventCity]											
		  ,[EventCountry]										
		  ,[EventDate]											
		  ,[EventSubType]										
		  ,[EventType]											
		  ,[EventTypeDescription]								
		  ,[EventTypeStandarizedInvoice]						
		  ,[EventTypePickList]									
		  ,[EventTypeProcessDescription]						
		  ,[FinalAttendance]									
		  ,[IsActive]											
		  ,[IsDeleted]											
		  ,[Language]											
		  ,[LastModifiedById]									
		  ,[LastModifiedDate]									
		  ,[CampaignName]																		
		  ,[NumberOfContacts]									
		  ,[NumberOfConvertedLeads]								
		  ,[NumberOfLeads]										
		  ,[NumberOfOpportunities]								
		  ,[NumberOfResponses]									
		  ,[NumberOfWonOpportunities]							
		  ,[OwnerId]											
		  ,[ParentId]											
		  ,[ProgramName]										
		  ,[RecordTypeId]										
		  ,[SalesRegion]										
		  ,[Speaker]											
		  ,[SpeakerId]											
		  ,[StartTime]											
		  ,[StartDate]											
		  ,[State]												
		  ,[Status]												
		  ,[SubmitFinalList]									
		  ,[SystemModstamp]										
		  ,[Type]												
		  ,[VenueId]											
		  ,[VenueCode]			
		  ,[Event Topic Category]
		  ,SecRegion
	)
	select	src.SKCampaign
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyCampaign

		  ,src.[CampaignMemberRecordTypeId]
		  ,src.[CapacityFinal]
		  ,src.[ClosedDateForRegistrations]
		  ,src.[ClosedDate]
		  ,src.[Comment]
		  ,src.[ConfirmedRegistrations]
		  ,src.[ContactPerson]
		  ,src.[CreatedById]
		  ,src.[CreatedDate]
		  ,src.[CurrencyIsoCode]
		  ,src.[DoctorType]
		  ,src.[EndTime]
		  ,src.[EndDate]
		  ,src.[EventCity]
		  ,src.[EventCountry]
		  ,src.[EventDate]
		  ,src.[EventSubType]
		  ,src.[EventType]
		  ,src.[EventTypeDescription]
		  ,src.[EventTypeStandarizedInvoice]
		  ,src.[EventTypePickList]
		  ,src.[EventTypeProcessDescription]
		  ,src.[FinalAttendance]
		  ,src.[IsActive]
		  ,src.[IsDeleted]
		  ,src.[Language]
		  ,src.[LastModifiedById]
		  ,src.[LastModifiedDate]
		  ,src.[CampaignName]								
		  ,src.[NumberOfContacts]
		  ,src.[NumberOfConvertedLeads]
		  ,src.[NumberOfLeads]
		  ,src.[NumberOfOpportunities]
		  ,src.[NumberOfResponses]
		  ,src.[NumberOfWonOpportunities]
		  ,src.[OwnerId]
		  ,src.[ParentId]
		  ,src.[ProgramName]
		  ,src.[RecordTypeId]
		  ,src.[SalesRegion]
		  ,src.[Speaker]
		  ,src.[SpeakerId]
		  ,src.[StartTime]
		  ,src.[StartDate]
		  ,src.[State]
		  ,src.[Status]
		  ,src.[SubmitFinalList]
		  ,src.[SystemModstamp]
		  ,src.[Type]
		  ,src.[VenueId]
		  ,src.[VenueCode]
		  ,src.[Event Topic Category]
		  ,src.SecRegion

	from #TempDimCampaign src
	where not exists (select dst.SKCampaign from DW.DimCampaign dst where dst.SKCampaign = src.SKCampaign)
	option (label = 'DW.LoadDimCampaign_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimCampaign_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
