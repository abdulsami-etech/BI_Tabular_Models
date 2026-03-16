CREATE TABLE [SrcSFDC].[Patient__c] (
    [LZBatchID]        INT                                             NOT NULL,
    [ADLSBatchID]      INT                                             NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)                                   NOT NULL,
    [CreatedDate]      DATETIME2 (7)                                   NOT NULL,
    [Gender__c]        NVARCHAR (255)                                  NULL,
    [Id]               NCHAR (18)                                      NOT NULL,
    [IsArchived__c]    BIT                                             NULL,
    [IsDeleted]        BIT                                             NOT NULL,
    [LastModifiedDate] DATETIME2 (7)                                   NOT NULL,
    [SystemModstamp]   DATETIME2 (7)                                   NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = ROUND_ROBIN);

