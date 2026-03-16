CREATE TABLE [SrcMAT].[Contact_ContactTypeLink] (
    [LZBatchID]         INT           NOT NULL,
    [ADLSBatchID]       INT           NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0) NOT NULL,
    [ContactTypeLinkID] INT           NOT NULL,
    [ContactID]         INT           NOT NULL,
    [ContactTypeID]     INT           NOT NULL,
    [RowStatusID]       TINYINT       NOT NULL,
    [DateCreated]       DATETIME      NULL,
    [CreatedByUserID]   INT           NOT NULL,
    [DateUpdated]       DATETIME      NULL,
    [UpdatedByUserID]   INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

