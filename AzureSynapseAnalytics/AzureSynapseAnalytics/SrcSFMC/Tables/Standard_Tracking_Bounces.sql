CREATE TABLE [SrcSFMC].[Standard_Tracking_Bounces] (
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
    [BounceCategory]           NVARCHAR (50)  NULL,
    [SMTPCode]                 INT            NULL,
    [BounceReason]             VARCHAR (8000) NULL,
    [BatchID]                  NVARCHAR (100) NULL,
    [TriggeredSendExternalKey] NVARCHAR (100) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

