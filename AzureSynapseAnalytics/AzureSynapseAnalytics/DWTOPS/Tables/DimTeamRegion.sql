CREATE TABLE [DWTOPS].[DimTeamRegion] (
    [SKTeamRegion]  INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [LZBatchID]     INT           NOT NULL,
    [DWBatchID]     INT           NOT NULL,
    [DWHash]        CHAR (40)     NOT NULL,
    [KeyTeamRegion] VARCHAR (80)  NOT NULL,
    [GroupRegion]   VARCHAR (64)  NOT NULL
)
WITH (CLUSTERED INDEX([SKTeamRegion]), DISTRIBUTION = REPLICATE);

