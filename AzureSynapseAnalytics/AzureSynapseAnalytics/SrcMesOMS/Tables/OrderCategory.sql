CREATE TABLE [SrcMesOMS].[OrderCategory] (
    [LZBatchID]       INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [orderCategoryID] INT           NOT NULL,
    [categoryName]    VARCHAR (50)  NOT NULL,
    [mesName]         VARCHAR (50)  NOT NULL,
    [isActive]        BIT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

