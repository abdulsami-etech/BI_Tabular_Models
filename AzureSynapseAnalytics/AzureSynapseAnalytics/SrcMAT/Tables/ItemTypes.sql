CREATE TABLE [SrcMAT].[ItemTypes] (
    [LZBatchID]                  INT           NOT NULL,
    [ADLSBatchID]                INT           NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0) NOT NULL,
    [ItemTypeID]                 SMALLINT      NOT NULL,
    [ItemTypeGenericDescription] VARCHAR (50)  NOT NULL,
    [RowStatusID]                TINYINT       NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [CreatedByUserID]            INT           NOT NULL,
    [DateUpdated]                DATETIME      NULL,
    [UpdatedByUserID]            INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

