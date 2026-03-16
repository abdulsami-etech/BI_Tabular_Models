CREATE TABLE [DWTOPS].[DimRoute] (
    [SKRoute]       INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [LZBatchID]     INT           NOT NULL,
    [DWBatchID]     INT           NOT NULL,
    [DWHash]        CHAR (40)     NOT NULL,
    [KeyRoute]      BIGINT        NOT NULL,
    [RouteName]     VARCHAR (64)  NOT NULL
)
WITH (CLUSTERED INDEX([SKRoute]), DISTRIBUTION = REPLICATE);

