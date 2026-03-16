CREATE TABLE [SrcSFDC].[AccountContactRelation] (
    [LZBatchID]          INT             NOT NULL,
    [ADLSBatchID]        INT             NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)   NOT NULL,
    [AccountId]          NCHAR (18)      NOT NULL,
    [Company_ID__c]      NVARCHAR (1300) NULL,
    [ContactId]          NCHAR (18)      NOT NULL,
    [CreatedById]        NCHAR (18)      NULL,
    [CreatedDate]        DATETIME2 (7)   NOT NULL,
    [CurrencyIsoCode]    NVARCHAR (3)    NOT NULL,
    [EndDate]            DATETIME2 (7)   NULL,
    [External_ID__c]     NVARCHAR (255)  NULL,
    [Id]                 NCHAR (18)      NOT NULL,
    [IsActive]           BIT             NOT NULL,
    [IsDeleted]          BIT             NOT NULL,
    [IsDirect]           BIT             NOT NULL,
    [LastModifiedById]   NCHAR (18)      NULL,
    [LastModifiedDate]   DATETIME2 (7)   NOT NULL,
    [Roles]              NVARCHAR (MAX)  NULL,
    [StartDate]          DATETIME2 (7)   NULL,
    [SystemModstamp]     DATETIME2 (7)   NOT NULL,
    [B2B_Partnership__c] NVARCHAR (256)  NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

