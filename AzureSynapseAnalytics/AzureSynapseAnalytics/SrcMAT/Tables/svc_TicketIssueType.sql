CREATE TABLE [SrcMAT].[svc_TicketIssueType] (
    [LZBatchID]                         INT           NOT NULL,
    [ADLSBatchID]                       INT           NOT NULL,
    [ADLSTimestamp]                     DATETIME2 (0) NOT NULL,
    [TicketIssueTypeID]                 SMALLINT      NOT NULL,
    [TicketIssueTypeGenericDescription] NVARCHAR (50) NOT NULL,
    [RowStatusID]                       TINYINT       NOT NULL,
    [DateCreated]                       DATETIME      NOT NULL,
    [CreatedByUserID]                   INT           NOT NULL,
    [DateUpdated]                       DATETIME      NOT NULL,
    [UpdatedByUserID]                   INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

