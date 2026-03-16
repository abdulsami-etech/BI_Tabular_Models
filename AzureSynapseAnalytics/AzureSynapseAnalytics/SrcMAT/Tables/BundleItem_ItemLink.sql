CREATE TABLE [SrcMAT].[BundleItem_ItemLink] (
    [LZBatchID]             INT           NOT NULL,
    [ADLSBatchID]           INT           NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0) NOT NULL,
    [BundleItem_ItemLinkID] INT           NOT NULL,
    [BundleItemID]          INT           NOT NULL,
    [ItemID]                INT           NOT NULL,
    [RowStatusID]           INT           NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [CreatedByUserID]       INT           NOT NULL,
    [DateUpdated]           DATETIME      NOT NULL,
    [UpdatedByUserID]       INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

