CREATE TABLE [SrcSFDC].[Shared_Contact__c] (
    [LZBatchID]              INT             NOT NULL,
    [ADLSBatchID]            INT             NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0)   NOT NULL,
    [Account__c]             NCHAR (18)      NULL,
    [Account_Number__c]      NVARCHAR (1300) NULL,
    [ConnectionReceivedId]   NCHAR (18)      NULL,
    [ConnectionSentId]       NCHAR (18)      NULL,
    [Contact__c]             NCHAR (18)      NULL,
    [Contact_Role__c]        NVARCHAR (255)  NULL,
    [CreatedById]            NCHAR (18)      NULL,
    [CreatedDate]            DATETIME2 (7)   NOT NULL,
    [CurrencyIsoCode]        NVARCHAR (3)    NOT NULL,
    [External_Id__c]         NVARCHAR (50)   NULL,
    [Id]                     NCHAR (18)      NOT NULL,
    [Is_Auto_Created__c]     BIT             NULL,
    [isCeatedFromAccount__c] BIT             NULL,
    [IsDeleted]              BIT             NOT NULL,
    [LastActivityDate]       DATETIME2 (7)   NULL,
    [LastModifiedById]       NCHAR (18)      NULL,
    [LastModifiedDate]       DATETIME2 (7)   NOT NULL,
    [LastReferencedDate]     DATETIME2 (7)   NULL,
    [LastViewedDate]         DATETIME2 (7)   NULL,
    [Name]                   NVARCHAR (80)   NULL,
    [Status__c]              NVARCHAR (255)  NULL,
    [SystemModstamp]         DATETIME2 (7)   NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

