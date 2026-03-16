CREATE TABLE [DWIRIS].[HubEvent] (
    [SKEvent]        INT            IDENTITY (1, 1) NOT NULL,
    [KeyEvent]       NVARCHAR (255) NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyEvent]), DISTRIBUTION = REPLICATE);

