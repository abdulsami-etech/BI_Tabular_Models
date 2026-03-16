CREATE TABLE [SrcMAT].[CountryRegion] (
    [LZBatchID]       INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [CountryRegionID] INT           NOT NULL,
    [RegionID]        INT           NOT NULL,
    [CountryID]       SMALLINT      NOT NULL,
    [RowStatusID]     TINYINT       NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [CreatedByUserID] INT           NOT NULL,
    [DateUpdated]     DATETIME      NULL,
    [UpdatedByUserID] INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

