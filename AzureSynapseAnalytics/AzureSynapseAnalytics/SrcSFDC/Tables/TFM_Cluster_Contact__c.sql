CREATE TABLE [SrcSFDC].[TFM_Cluster_Contact__c] (
    [LZBatchID]         INT             NOT NULL,
    [ADLSBatchID]       INT             NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)   NOT NULL,
    [Contact__c]        NCHAR (18)      NULL,
    [Id]                NCHAR (18)      NOT NULL,
    [LastModifiedDate]  DATETIME2 (7)   NOT NULL,
    [Name]              NVARCHAR (80)   NULL,
    [OwnerId__c]        NVARCHAR (1300) NULL,
    [SystemModstamp]    DATETIME2 (7)   NOT NULL,
    [TFM_Cluster__c]    NCHAR (18)      NULL,
    [TFM_End_Date__c]   DATETIME2 (7)   NULL,
    [TFM_Start_Date__c] DATETIME2 (7)   NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

