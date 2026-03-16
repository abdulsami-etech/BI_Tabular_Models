CREATE TABLE [SrcMAT].[WarrantyType] (
    [LZBatchID]               INT           NOT NULL,
    [ADLSBatchID]             INT           NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0) NOT NULL,
    [WarrantyTypeID]          SMALLINT      NOT NULL,
    [WarrantyTypeDescription] VARCHAR (50)  NOT NULL,
    [RowStatusID]             TINYINT       NOT NULL,
    [DateCreated]             DATETIME      NOT NULL,
    [CreatedByUserID]         INT           NOT NULL,
    [DateUpdated]             DATETIME      NULL,
    [UpdatedByUserID]         INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

