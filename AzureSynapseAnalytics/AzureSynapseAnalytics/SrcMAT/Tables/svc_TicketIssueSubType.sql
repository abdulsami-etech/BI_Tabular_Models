CREATE TABLE [SrcMAT].[svc_TicketIssueSubType] (
    [LZBatchID]                            INT           NOT NULL,
    [ADLSBatchID]                          INT           NOT NULL,
    [ADLSTimestamp]                        DATETIME2 (0) NOT NULL,
    [TicketIssueSubTypeID]                 SMALLINT      NOT NULL,
    [TicketIssueTypeID]                    SMALLINT      NOT NULL,
    [TicketIssueSubTypeGenericDescription] NVARCHAR (50) NOT NULL,
    [RowStatusID]                          TINYINT       NOT NULL,
    [DateCreated]                          DATETIME      NOT NULL,
    [CreatedByUserID]                      INT           NOT NULL,
    [DateUpdated]                          DATETIME      NOT NULL,
    [UpdatedByUserID]                      INT           NOT NULL,
    [AreChildrenMandatory]                 BIT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

