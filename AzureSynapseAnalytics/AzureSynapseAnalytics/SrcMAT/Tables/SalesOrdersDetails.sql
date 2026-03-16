CREATE TABLE [SrcMAT].[SalesOrdersDetails] (
    [LZBatchID]           INT             NOT NULL,
    [ADLSBatchID]         INT             NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0)   NOT NULL,
    [SalesOrderDetailsID] INT             NOT NULL,
    [SalesOrderHeaderID]  INT             NULL,
    [ItemID]              INT             NULL,
    [Quantity]            DECIMAL (10, 2) NOT NULL,
    [BillToPartnerID]     INT             NOT NULL,
    [ShipToPartnerID]     INT             NOT NULL,
    [DueDate]             DATETIME        NULL,
    [ShippingDate]        DATETIME        NULL,
    [DeliveryDate]        DATETIME        NULL,
    [BillingDate]         DATETIME        NULL,
    [RowStatusID]         TINYINT         NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [CreatedByUserID]     INT             NOT NULL,
    [DateUpdated]         DATETIME        NULL,
    [UpdatedByUserID]     INT             NOT NULL,
    [Notes]               VARCHAR (MAX)   NULL
)
WITH (CLUSTERED INDEX([SalesOrderDetailsID]), DISTRIBUTION = HASH([SalesOrderHeaderID]));

