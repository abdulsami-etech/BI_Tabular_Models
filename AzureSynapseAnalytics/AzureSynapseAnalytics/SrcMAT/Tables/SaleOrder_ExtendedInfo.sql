CREATE TABLE [SrcMAT].[SaleOrder_ExtendedInfo] (
    [LZBatchID]                 INT             NOT NULL,
    [ADLSBatchID]               INT             NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0)   NOT NULL,
    [SalesOrderHeaderID]        INT             NOT NULL,
    [ShipToCompanyID]           INT             NOT NULL,
    [PurchaseOrderID]           NVARCHAR (50)   NULL,
    [PurchaseOrderSignedDate]   DATETIME        NULL,
    [PurchaseOrderReceivedDate] DATETIME        NULL,
    [PaymentOptions]            NVARCHAR (50)   NULL,
    [OrderSource]               NVARCHAR (50)   NULL,
    [Description]               NVARCHAR (4000) NULL,
    [RowStatusID]               TINYINT         NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [CreatedByUserID]           INT             NOT NULL,
    [DateUpdated]               DATETIME        NULL,
    [UpdatedByUserID]           INT             NOT NULL,
    [PurchaseOrderStatus]       NVARCHAR (20)   NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

