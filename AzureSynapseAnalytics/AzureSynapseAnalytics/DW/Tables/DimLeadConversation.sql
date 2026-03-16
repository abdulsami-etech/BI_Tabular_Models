CREATE TABLE [DW].[DimLeadConversation] (
    [SKLeadConversation]           INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [LZBatchID]            INT            NOT NULL,
    [DWBatchID]            INT            NOT NULL,
    [DWHash]               CHAR (40)      NOT NULL,
    [KeyLeadConversation]          NCHAR (18)     NOT NULL

    ,[ConsumerLeadId]               NCHAR (18) NULL
    ,[ContactId]                    NCHAR (18) NULL
    ,[CreatedById]                  NCHAR (18) NULL
    ,[CreatedByUserName]            NVARCHAR (121) NULL
    ,[CreatedDate]                  DATETIME2 NULL
    ,[CurrencyIsoCode]              NVARCHAR (6) NULL
    ,[IsDeleted]                    NVARCHAR (5) NULL
    ,[LastModifiedById]             NCHAR (18) NULL
    ,[LastModifiedByUserName]       NVARCHAR (121) NULL
    ,[LastModifiedDate]             DATETIME2 NULL
    ,[Name]                         NVARCHAR(160)  NULL
    ,[OwnerId]                      NCHAR (18) NULL
    ,[OwnerUserName]                NVARCHAR (121) NULL
    ,[SMSConversation]              NVARCHAR(5) NULL
    ,[SystemModstamp]               DATETIME2 NULL
    ,[WhatsAppConversation]         NVARCHAR(5) NULL
    ,[LeadCountryCode]              NVARCHAR(20) NULL
    ,[LeadCountry]                  NVARCHAR(160) NULL
    ,[SecRegion]                    VARCHAR (10)  NULL
    

    --CONSTRAINT [PK_DimLeadConversation] PRIMARY KEY NONCLUSTERED ([SKLeadConversation] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_DimLeadConversation_KeyLeadConversation] UNIQUE NONCLUSTERED ([KeyLeadConversation] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKLeadConversation]), DISTRIBUTION = HASH([SKLeadConversation]));
