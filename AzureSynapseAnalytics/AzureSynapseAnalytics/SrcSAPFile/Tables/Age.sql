CREATE TABLE [SrcSAPFile].[Age] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [AgeKey]        INT           NOT NULL,
    [AgeTierRange]  NVARCHAR (30) NOT NULL,
    [AgeTierDetail] NVARCHAR (30) NOT NULL,
    [AgeSegment]    NVARCHAR (30) NOT NULL,
    [AgeCategory]   NVARCHAR (15) NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

