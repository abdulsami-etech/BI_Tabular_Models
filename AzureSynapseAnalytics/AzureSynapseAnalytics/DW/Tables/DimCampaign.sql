CREATE TABLE [DW].[DimCampaign] (
    [SKCampaign]           INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [LZBatchID]            INT            NOT NULL,
    [DWBatchID]            INT            NOT NULL,
    [DWHash]               CHAR (40)      NOT NULL,
    [KeyCampaign]          NCHAR (18)     NOT NULL

      ,[CampaignMemberRecordTypeId]			NVARCHAR(18)	NULL
      ,[CapacityFinal]						DECIMAL(18,5)	NULL
      ,[ClosedDateForRegistrations]			DATETIME2 (7)	NULL
      ,[ClosedDate]							DATETIME2 (7)	NULL
      ,[Comment]							NVARCHAR(256)	NULL
      ,[ConfirmedRegistrations]				DECIMAL(18,5)	NULL
      ,[ContactPerson]						NVARCHAR(256)	NULL
      ,[CreatedById]						NVARCHAR(18)	NULL
      ,[CreatedDate]						DATETIME2 (7)	NULL
      ,[CurrencyIsoCode]					NVARCHAR(10)	NULL
      ,[DoctorType]							NVARCHAR(256)	NULL
      ,[EndTime]							NVARCHAR(10)	NULL
      ,[EndDate]							DATETIME2 (7)	NULL
      ,[EventCity]							NVARCHAR(256)	NULL
      ,[EventCountry]						NVARCHAR(256)	NULL
      ,[EventDate]							DATETIME2 (7)	NULL
      ,[EventSubType]						NVARCHAR(256)	NULL
      ,[EventType]							NVARCHAR(256)	NULL
      ,[EventTypeDescription]				NVARCHAR(MAX)	NULL
      ,[EventTypeStandarizedInvoice]		NVARCHAR(256)	NULL
      ,[EventTypePickList]					NVARCHAR(256)	NULL
      ,[EventTypeProcessDescription]		NVARCHAR(MAX)	NULL
      ,[FinalAttendance]					DECIMAL(18,5)	NULL
      ,[IsActive]							NVARCHAR(10)	NULL
      ,[IsDeleted]							NVARCHAR(10)	NULL
      ,[Language]							NVARCHAR(256)	NULL	
      ,[LastModifiedById]					NVARCHAR(18)	NULL
      ,[LastModifiedDate]					DATETIME2 (7)	NULL
      ,[CampaignName]						NVARCHAR(256)	NULL
      ,[NumberOfContacts]					INT				NULL
      ,[NumberOfConvertedLeads]				INT				NULL
      ,[NumberOfLeads]						INT				NULL
      ,[NumberOfOpportunities]				INT				NULL
      ,[NumberOfResponses]					INT				NULL
      ,[NumberOfWonOpportunities]			INT				NULL
      ,[OwnerId]							NVARCHAR(18)	NULL
      ,[ParentId]							NVARCHAR(18)	NULL
      ,[ProgramName]						NVARCHAR(256)	NULL
      ,[RecordTypeId]						NVARCHAR(18)	NULL
      ,[SalesRegion]						NVARCHAR(256)	NULL
      ,[Speaker]							NVARCHAR(256)	NULL
      ,[SpeakerId]							NVARCHAR(18)	NULL
      ,[StartTime]							NVARCHAR(10)	NULL
      ,[StartDate]							DATETIME2 (7)	NULL
      ,[State]								NVARCHAR(256)	NULL
      ,[Status]								NVARCHAR(50)	NULL
      ,[SubmitFinalList]					NVARCHAR(5)		NULL
      ,[SystemModstamp]						DATETIME2 (7)	NULL
      ,[Type]								NVARCHAR(256)	NULL
      ,[VenueId]							NVARCHAR(18)	NULL
      ,[VenueCode]							NVARCHAR(50)	NULL
      ,[Event Topic Category]               NVARCHAR(max)   NULL
      
      ,[SecRegion]                          VARCHAR (10)   DEFAULT ('') NOT NULL
   
    CONSTRAINT [PK_DimCampaign] PRIMARY KEY NONCLUSTERED ([SKCampaign] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_DimCampaign_KeyCampaign] UNIQUE NONCLUSTERED ([KeyCampaign] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKCampaign]), DISTRIBUTION = HASH([SKCampaign]));

