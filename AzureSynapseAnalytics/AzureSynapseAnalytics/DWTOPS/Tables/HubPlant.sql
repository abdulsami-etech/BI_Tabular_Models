CREATE TABLE [DWTOPS].[HubPlant] (
    [SKPlant]          INT          IDENTITY (1, 1) NOT NULL,
    [KeyPlant]         VARCHAR (64) NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyPlant]), DISTRIBUTION = REPLICATE);

