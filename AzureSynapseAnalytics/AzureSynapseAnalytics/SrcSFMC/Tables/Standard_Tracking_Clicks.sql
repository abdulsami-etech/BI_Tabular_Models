CREATE TABLE [SrcSFMC].[Standard_Tracking_Clicks] (
    [LZBatchID]                INT            NOT NULL,
    [ADLSBatchID]              INT            NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)  NOT NULL,
    [ClientID]                 BIGINT         NOT NULL,
    [SendID]                   BIGINT         NOT NULL,
    [SubscriberKey]            NVARCHAR (100) NULL,
    [EmailAddress]             NVARCHAR (255) NULL,
    [SubscriberID]             BIGINT         NULL,
    [ListID]                   BIGINT         NULL,
    [EventDate]                DATETIME       NULL,
    [EventType]                NVARCHAR (6)   NULL,
    [SendURLID]                BIGINT         NULL,
    [URLID]                    BIGINT         NULL,
    [URL]                      VARCHAR (4000) NULL,
    [Alias]                    NVARCHAR (700) NULL,
    [BatchID]                  BIGINT         NULL,
    [TriggeredSendExternalKey] NVARCHAR (100) NULL,
    [IsUnique]                 NVARCHAR (5)   NULL,
    [IsUniqueForURL]           NVARCHAR (5)   NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

