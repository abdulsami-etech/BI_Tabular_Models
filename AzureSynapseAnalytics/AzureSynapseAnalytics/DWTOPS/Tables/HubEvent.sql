CREATE TABLE [DWTOPS].[HubEvent] (
    [SKEvent]          INT          IDENTITY (1, 1) NOT NULL,
    [KeyEvent]         VARCHAR (33) NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyEvent]), DISTRIBUTION = REPLICATE);

