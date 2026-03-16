CREATE TABLE [SrcSFDC].[Apttus_Config2__IncentiveLoyaltyEnrollment__HistoryFlattened] (
    [LZBatchID]                       INT            NOT NULL,
    [ADLSBatchID]                     INT            NULL,
    [ADLSTimestamp]                   DATETIME2 (0)  NULL,
    [ParentId]                        NCHAR (18)     NULL,
    [StartDate]                       DATE           NULL,
    [EndDate]                         DATE           NULL,
    [Apttus_Config2__Active__c]       NVARCHAR (255) NULL,
    [Apttus_Config2__LoyaltyLevel__c] NVARCHAR (255) NULL,
    [Program_Registration__c]         NVARCHAR (255) NULL,
    [Apttus_Config2__CustomerType__c] NVARCHAR (255) NULL
)
WITH (CLUSTERED INDEX([ParentId]), DISTRIBUTION = HASH([ParentId]));

