CREATE TABLE [SrcMAT].[Activity_ContactLink] (
    [LZBatchID]             INT           NOT NULL,
    [ADLSBatchID]           INT           NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0) NOT NULL,
    [ActivityContactLinkID] INT           NOT NULL,
    [ContactID]             INT           NOT NULL,
    [ActivityID]            INT           NOT NULL,
    [RowStatusID]           TINYINT       NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [CreatedByUserID]       INT           NOT NULL,
    [DateUpdated]           DATETIME      NOT NULL,
    [UpdatedByUserID]       INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

