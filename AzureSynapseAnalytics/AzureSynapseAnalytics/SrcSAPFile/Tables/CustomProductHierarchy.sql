CREATE TABLE [SrcSAPFile].[CustomProductHierarchy] (
    [LZBatchID]             INT           NOT NULL,
    [ADLSBatchID]           INT           NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0) NOT NULL,
    [ProductCode]           NVARCHAR (18) NOT NULL,
    [BusinessSegment]       NVARCHAR (35) NOT NULL,
    [ProductSegment]        NVARCHAR (35) NOT NULL,
    [ProductCategory]       NVARCHAR (35) NOT NULL,
    [ProductClassification] NVARCHAR (35) NOT NULL,
    [ProductGroup]          NVARCHAR (35) NOT NULL,
    [ProductSubGroup]       NVARCHAR (35) NOT NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

