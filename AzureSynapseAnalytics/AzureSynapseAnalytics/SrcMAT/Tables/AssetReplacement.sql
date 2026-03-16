CREATE TABLE [SrcMAT].[AssetReplacement] (
    [LZBatchID]             INT           NOT NULL,
    [ADLSBatchID]           INT           NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0) NOT NULL,
    [AssetReplacementId]    INT           NOT NULL,
    [FromEquipmentCardId]   INT           NOT NULL,
    [FromBusinessPartnerId] INT           NOT NULL,
    [ToEquipmentCardId]     INT           NOT NULL,
    [ToBusinessPartnerId]   INT           NOT NULL,
    [ReplaceDate]           DATETIME      NULL,
    [RowStatusID]           TINYINT       NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [CreatedByUserID]       INT           NOT NULL,
    [DateUpdated]           DATETIME      NOT NULL,
    [UpdatedByUserID]       INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

