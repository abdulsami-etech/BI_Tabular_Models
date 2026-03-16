CREATE TABLE [SrcCONSDL].[LevelOfInterest] (
    [LZBatchID]               INT            NOT NULL,
    [ADLSBatchID]             INT            NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)  NOT NULL,
    [LevelOfInterestKey]      INT            NOT NULL,
    [LevelOfInterestName]     NVARCHAR (450) NOT NULL,
    [LevelOfInterestGroupKey] INT            NOT NULL,
    [LevelOfInterestGroup]    NVARCHAR (100) NOT NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

