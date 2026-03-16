CREATE TABLE [SrcMAT].[WorkOrders] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [WorkOrderID]          INT           NOT NULL,
    [SalesOrderDetailsID]  INT           NOT NULL,
    [BillOfWorkID]         INT           NOT NULL,
    [ResourceID]           INT           NOT NULL,
    [WorkOrderStatusID]    SMALLINT      NOT NULL,
    [CreatedByWorkOrderID] INT           NOT NULL,
    [RowStatusID]          TINYINT       NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [CreatedByUserID]      INT           NOT NULL,
    [DateUpdated]          DATETIME      NOT NULL,
    [UpdatedByUserID]      INT           NOT NULL,
    [OrderID]              INT           NULL,
    [ResourcePartnerID]    INT           NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([WorkOrderID]));

