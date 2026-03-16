CREATE TABLE [SrcMAT].[svc_TicketIssueAsset] (
    [LZBatchID]                          INT            NOT NULL,
    [ADLSBatchID]                        INT            NOT NULL,
    [ADLSTimestamp]                      DATETIME2 (0)  NOT NULL,
    [TicketIssueAssetID]                 SMALLINT       NOT NULL,
    [TicketIssueSubTypeID]               SMALLINT       NOT NULL,
    [TicketIssueAssetGenericDescription] NVARCHAR (200) NOT NULL,
    [RowStatusID]                        TINYINT        NOT NULL,
    [DateCreated]                        DATETIME       NOT NULL,
    [CreatedByUserID]                    INT            NOT NULL,
    [DateUpdated]                        DATETIME       NOT NULL,
    [UpdatedByUserID]                    INT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

