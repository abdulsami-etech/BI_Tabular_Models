CREATE TABLE [DWTOPS].[HubRouteStep] (
    [SKRouteStep]      INT          IDENTITY (1, 1) NOT NULL,
    [KeyRouteStep]     BIGINT       NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyRouteStep]), DISTRIBUTION = REPLICATE);

