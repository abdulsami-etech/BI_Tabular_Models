CREATE TABLE [SrcMAT].[ItemCategories] (
    [LZBatchID]                      INT           NOT NULL,
    [ADLSBatchID]                    INT           NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0) NOT NULL,
    [ItemCategoryID]                 SMALLINT      NOT NULL,
    [ItemCategoryGenericDescription] NVARCHAR (50) NULL,
    [RowStatusID]                    TINYINT       NOT NULL,
    [DateCreated]                    DATETIME      NOT NULL,
    [CreatedByUserID]                INT           NOT NULL,
    [DateUpdated]                    DATETIME      NULL,
    [UpdatedByUserID]                INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

