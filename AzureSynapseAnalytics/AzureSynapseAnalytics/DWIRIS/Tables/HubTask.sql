CREATE TABLE [DWIRIS].[HubTask] (
    [SKTask]         INT            IDENTITY (1, 1) NOT NULL,
    [KeyTask]        NVARCHAR (255) NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyTask]), DISTRIBUTION = REPLICATE);

