CREATE TABLE [DWTOPS].[DimCompleteReason] (
    [SKCompleteReason]  INT           NOT NULL,
    [ADLSBatchID]       INT           NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0) NOT NULL,
    [LZBatchID]         INT           NOT NULL,
    [DWBatchID]         INT           NOT NULL,
    [DWHash]            CHAR (40)     NOT NULL,
    [KeyCompleteReason] VARCHAR (64)  NOT NULL,
    [IsCompletion]      VARCHAR (8)   NOT NULL,
    [IsRework]          VARCHAR (8)   NOT NULL,
    [IsReject]          VARCHAR (8)   NOT NULL,
    [IsTask]            VARCHAR (8)   NOT NULL
)
WITH (CLUSTERED INDEX([SKCompleteReason]), DISTRIBUTION = REPLICATE);

