CREATE TABLE [SrcSFDC].[Apttus_Config2__LoyaltyPointAccrualAdjustmentItem__c] (
    [LZBatchID]                           INT            NOT NULL,
    [ADLSBatchID]                         INT            NOT NULL,
    [ADLSTimestamp]                       DATETIME2 (0)  NOT NULL,
    [Apttus_Config2__AccrualSummaryId__c] NCHAR (18)     NULL,
    [Apttus_Config2__AdjustmentDate__c]   DATETIME2 (7)  NULL,
    [Apttus_Config2__AdjustmentReason__c] NVARCHAR (255) NULL,
    [Apttus_Config2__Description__c]      NVARCHAR (255) NULL,
    [Apttus_Config2__IncentiveId__c]      NCHAR (18)     NULL,
    [Apttus_Config2__Points__c]           DECIMAL (18)   NULL,
    [ConnectionReceivedId]                NCHAR (18)     NULL,
    [ConnectionSentId]                    NCHAR (18)     NULL,
    [CreatedById]                         NCHAR (18)     NULL,
    [CreatedDate]                         DATETIME2 (7)  NOT NULL,
    [CurrencyIsoCode]                     NVARCHAR (3)   NULL,
    [Id]                                  NCHAR (18)     NOT NULL,
    [IsDeleted]                           BIT            NOT NULL,
    [LastActivityDate]                    DATETIME2 (7)  NULL,
    [LastModifiedById]                    NCHAR (18)     NULL,
    [LastModifiedDate]                    DATETIME2 (7)  NOT NULL,
    [Name]                                NVARCHAR (80)  NULL,
    [SystemModstamp]                      DATETIME2 (7)  NOT NULL,
    [Contact__c]                          NCHAR (18)     NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

