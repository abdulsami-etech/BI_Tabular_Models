CREATE TABLE [SrcSFDC].[Advantage_Eligibility_Check__c] (
    [LZBatchID]             INT            NOT NULL,
    [ADLSBatchID]           INT            NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)  NOT NULL,
    [Account_Type__c]       NVARCHAR (255) NULL,
    [Certification_Type__c] NVARCHAR (255) NULL,
    [CreatedById]           NCHAR (18)     NULL,
    [CreatedDate]           DATETIME2 (7)  NOT NULL,
    [CurrencyIsoCode]       NVARCHAR (3)   NOT NULL,
    [Id]                    NCHAR (18)     NOT NULL,
    [IsDeleted]             BIT            NOT NULL,
    [LastModifiedById]      NCHAR (18)     NULL,
    [LastModifiedDate]      DATETIME2 (7)  NOT NULL,
    [Line_of_Business__c]   NVARCHAR (255) NULL,
    [Name]                  NVARCHAR (38)  NOT NULL,
    [Program_Code__c]       NVARCHAR (10)  NULL,
    [Promotion_Region__c]   NVARCHAR (80)  NULL,
    [SetupOwnerId]          NCHAR (18)     NULL,
    [SystemModstamp]        DATETIME2 (7)  NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

