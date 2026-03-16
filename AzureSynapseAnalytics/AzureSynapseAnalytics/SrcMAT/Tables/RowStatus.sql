CREATE TABLE [SrcMAT].[RowStatus] (
    [LZBatchID]                   INT           NOT NULL,
    [ADLSBatchID]                 INT           NOT NULL,
    [ADLSTimestamp]               DATETIME2 (0) NOT NULL,
    [RowStatusID]                 TINYINT       NOT NULL,
    [RowStatusDescriptionGeneric] VARCHAR (50)  NULL,
    [ActiveStatus]                BIT           NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [CreatedByUserID]             INT           NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [UpdatedByUserID]             INT           NOT NULL,
    [Display]                     BIT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

