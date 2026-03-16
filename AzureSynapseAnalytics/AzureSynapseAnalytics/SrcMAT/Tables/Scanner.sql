CREATE TABLE [SrcMAT].[Scanner] (
    [LZBatchID]       INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [EquipmentCardID] INT           NOT NULL,
    [EmbeddedHeadSN]  NVARCHAR (50) NULL,
    [ScannerTypeID]   INT           NOT NULL,
    [RowStatusID]     TINYINT       NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [CreatedByUserID] INT           NOT NULL,
    [DateUpdated]     DATETIME      NOT NULL,
    [UpdatedByUserID] INT           NOT NULL,
    [ScannerModelId]  INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

