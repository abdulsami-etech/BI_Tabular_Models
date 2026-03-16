CREATE TABLE [DW].[DimOrderStatus] (
    [SKOrderStatus]     INT       NOT NULL,
    [OrderStatusCode]    NVARCHAR (100) NOT NULL,
    [OrderStatusName]    NVARCHAR (100) NOT NULL,
    [CreatedDate]        DATETIME       NULL,
    [ModifiedDate]       DATETIME       NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

