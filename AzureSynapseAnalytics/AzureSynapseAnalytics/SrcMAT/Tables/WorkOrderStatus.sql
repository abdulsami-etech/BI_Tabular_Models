CREATE TABLE [SrcMAT].[WorkOrderStatus] (
    [LZBatchID]                         INT           NOT NULL,
    [ADLSBatchID]                       INT           NOT NULL,
    [ADLSTimestamp]                     DATETIME2 (0) NOT NULL,
    [WorkOrderStatusID]                 SMALLINT      NOT NULL,
    [WorkOrderStatusGenericDescription] NVARCHAR (50) NOT NULL,
    [RowStatusID]                       TINYINT       NOT NULL,
    [DateCreated]                       DATETIME      NOT NULL,
    [CreatedByUserID]                   INT           NOT NULL,
    [DateUpdated]                       DATETIME      NULL,
    [UpdatedByUserID]                   INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

