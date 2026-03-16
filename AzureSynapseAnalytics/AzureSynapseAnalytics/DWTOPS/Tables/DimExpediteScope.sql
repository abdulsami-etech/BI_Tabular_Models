CREATE TABLE [DWTOPS].[DimExpediteScope] (
    [SKExpediteScope]  INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [LZBatchID]        INT           NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [DWHash]           CHAR (40)     NOT NULL,
    [KeyExpediteScope] VARCHAR (50)  NOT NULL
)
WITH (CLUSTERED INDEX([SKExpediteScope]), DISTRIBUTION = REPLICATE);

