CREATE TABLE [SrcCONSDL].[AudienceSegment] (
    [LZBatchID]          INT            NOT NULL,
    [ADLSBatchID]        INT            NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)  NOT NULL,
    [AudienceSegmentKey] INT            NOT NULL,
    [AudienceSegment]    NVARCHAR (100) NOT NULL,
    [BusinessSegment]    NVARCHAR (100) NOT NULL,
    [SortOrder]          INT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

