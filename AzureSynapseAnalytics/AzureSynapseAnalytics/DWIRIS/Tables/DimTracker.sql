CREATE TABLE [DWIRIS].[DimTracker] (
    [SKTracker]                      INT            NOT NULL,
    [ADLSBatchID]                    INT            NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0)  NOT NULL,
    [LZBatchID]                      INT            NOT NULL,
    [DWBatchID]                      INT            NOT NULL,
    [DWHash]                         CHAR (40)      NOT NULL,
    [SourceSystem]                   VARCHAR (10)   NOT NULL,
    [SKAsset]                        INT            NOT NULL,
    [TrackerName]                    NVARCHAR (80)  NULL,
    [TrackingMessage]                NVARCHAR (255) NULL,
    [TrackingNumber]                 NVARCHAR (255) NULL,
    [TrackingStatus]                 NVARCHAR (255) NULL,
    [ScheduledDeliveryDeliveredDate] DATETIME2 (7)  NULL,
    [Carrier]                        NVARCHAR (255) NULL,
    [ShippedDate]                    DATETIME2 (7)  NULL,
    [OpportunityId]                  NCHAR (36)     NULL,
    [ProcessingStatus]               NVARCHAR (510) NULL,
    [KeyTicket]                      NCHAR (36)     NULL
)
WITH (CLUSTERED INDEX([SKTracker]), DISTRIBUTION = REPLICATE);

