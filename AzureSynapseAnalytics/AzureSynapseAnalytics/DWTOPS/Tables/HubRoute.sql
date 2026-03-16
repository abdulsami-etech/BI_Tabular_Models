CREATE TABLE [DWTOPS].[HubRoute] (
    [SKRoute]          INT          IDENTITY (1, 1) NOT NULL,
    [KeyRoute]         BIGINT       NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyRoute]), DISTRIBUTION = REPLICATE);

