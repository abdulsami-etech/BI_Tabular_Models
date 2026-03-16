CREATE TABLE [SrcMAT].[Activity_TicketLink] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [ActivityTicketLinkID] INT           NOT NULL,
    [TicketID]             INT           NOT NULL,
    [ActivityID]           INT           NOT NULL,
    [RowStatusID]          TINYINT       NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [CreatedByUserID]      INT           NOT NULL,
    [DateUpdated]          DATETIME      NOT NULL,
    [UpdatedByUserID]      INT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([ActivityTicketLinkID]));

