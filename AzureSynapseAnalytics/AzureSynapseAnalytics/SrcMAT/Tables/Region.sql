CREATE TABLE [SrcMAT].[Region] (
    [LZBatchID]                INT           NOT NULL,
    [ADLSBatchID]              INT           NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0) NOT NULL,
    [RegionID]                 INT           NOT NULL,
    [RegionGenericDescription] VARCHAR (100) NOT NULL,
    [RegionTypeID]             INT           NOT NULL,
    [SortOrder]                SMALLINT      NOT NULL,
    [RowStatusID]              TINYINT       NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [CreatedByUserID]          INT           NOT NULL,
    [DateUpdated]              DATETIME      NULL,
    [UpdatedByUserID]          INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

