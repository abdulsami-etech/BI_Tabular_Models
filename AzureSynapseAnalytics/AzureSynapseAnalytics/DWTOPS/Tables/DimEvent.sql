CREATE TABLE [DWTOPS].[DimEvent] (
    [SKEvent]       INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [LZBatchID]     INT           NOT NULL,
    [DWBatchID]     INT           NOT NULL,
    [DWHash]        CHAR (40)     NOT NULL,
    [KeyEvent]      VARCHAR (33)  NOT NULL
)
WITH (CLUSTERED INDEX([SKEvent]), DISTRIBUTION = REPLICATE);

