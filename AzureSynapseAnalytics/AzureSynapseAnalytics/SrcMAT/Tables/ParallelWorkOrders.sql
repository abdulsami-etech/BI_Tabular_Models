CREATE TABLE [SrcMAT].[ParallelWorkOrders] (
    [LZBatchID]                 INT           NOT NULL,
    [ADLSBatchID]               INT           NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0) NOT NULL,
    [ParallelWorkOrderID]       INT           NOT NULL,
    [SalesOrderDetailsID]       INT           NOT NULL,
    [BillOfWorkID]              INT           NOT NULL,
    [ResourceID]                INT           NOT NULL,
    [ParallelWorkOrderStatusID] SMALLINT      NOT NULL,
    [CreatedByWorkOrderID]      INT           NOT NULL,
    [RowStatusID]               TINYINT       NOT NULL,
    [DateCreated]               DATETIME      NOT NULL,
    [CreatedByUserID]           INT           NOT NULL,
    [DateUpdated]               DATETIME      NOT NULL,
    [UpdatedByUserID]           INT           NOT NULL,
    [ResourcePartnerID]         INT           NULL,
    [OrderID]                   INT           NULL,
    [DataFormatID]              SMALLINT      NULL,
    [ExportTypeFormatID]        SMALLINT      NULL,
    [FileTypeFormatID]          SMALLINT      NULL,
    [CADCAMSystemTypeId]        SMALLINT      NULL
)
WITH (CLUSTERED INDEX([ParallelWorkOrderID]), DISTRIBUTION = HASH([ParallelWorkOrderID]));

