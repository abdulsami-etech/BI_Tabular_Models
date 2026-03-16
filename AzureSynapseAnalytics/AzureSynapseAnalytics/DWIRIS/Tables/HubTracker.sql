CREATE TABLE [DWIRIS].[HubTracker] (
    [SKTracker]        INT            IDENTITY (1, 1) NOT NULL,
    [KeyTracker]       NVARCHAR (255) NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NOT NULL,
    [DWBatchID]        INT            NOT NULL,
    [InsertDateTime]   DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyTracker]), DISTRIBUTION = REPLICATE);

