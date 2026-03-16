CREATE TABLE [DWTOPS].[DimRouteStep] (
    [SKRouteStep]       INT           NOT NULL,
    [ADLSBatchID]       INT           NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0) NOT NULL,
    [LZBatchID]         INT           NOT NULL,
    [DWBatchID]         INT           NOT NULL,
    [DWHash]            CHAR (40)     NOT NULL,
    [KeyRouteStep]      BIGINT        NOT NULL,
    [RouteStepName]     VARCHAR (64)  NOT NULL,
    [RouteStepType]     VARCHAR (50)  NOT NULL,
    [RouteStepCategory] VARCHAR (50)  NULL
)
WITH (CLUSTERED INDEX([SKRouteStep]), DISTRIBUTION = REPLICATE);

