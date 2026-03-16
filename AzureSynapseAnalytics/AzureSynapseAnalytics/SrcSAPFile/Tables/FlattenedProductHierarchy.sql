CREATE TABLE [SrcSAPFile].[FlattenedProductHierarchy] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [LEVEL1]        NVARCHAR (2)  NOT NULL,
    [LEVEL2]        NVARCHAR (4)  NOT NULL,
    [LEVEL3]        NVARCHAR (6)  NOT NULL,
    [LEVEL4]        NVARCHAR (8)  NOT NULL,
    [LEVEL5]        NVARCHAR (10) NOT NULL,
    [LEVEL6]        NVARCHAR (12) NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

