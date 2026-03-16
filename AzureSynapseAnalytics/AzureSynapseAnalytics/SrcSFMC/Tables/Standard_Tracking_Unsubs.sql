CREATE TABLE [SrcSFMC].[Standard_Tracking_Unsubs] (
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
    [EventType]                NVARCHAR (100) NULL,
    [BatchID]                  BIGINT         NULL,
    [TriggeredSendExternalKey] NVARCHAR (100) NULL,
    [UnsubReason]              VARCHAR (4000) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

