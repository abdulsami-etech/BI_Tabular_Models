CREATE TABLE [SrcMAT].[svc_Ticket_PartsRequestLink] (
    [LZBatchID]                     INT           NOT NULL,
    [ADLSBatchID]                   INT           NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0) NOT NULL,
    [svc_Ticket_PartsRequestLinkId] INT           NOT NULL,
    [TicketId]                      INT           NOT NULL,
    [ItemId]                        INT           NOT NULL,
    [Quantity]                      SMALLINT      NOT NULL,
    [ApprovalStatus]                TINYINT       NOT NULL,
    [TransitionDetailsId]           INT           NULL,
    [RowStatusID]                   TINYINT       NOT NULL,
    [CreatedByUserId]               INT           NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [UpdatedByUserId]               INT           NOT NULL,
    [DateUpdated]                   DATETIME      NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

