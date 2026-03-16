CREATE TABLE [SrcCONSDL].[UserType2AudienceSegment] (
    [LZBatchID]       INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [UserType]        NVARCHAR (50) NOT NULL,
    [AudienceSegment] NVARCHAR (50) NOT NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

