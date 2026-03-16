CREATE TABLE [SrcSAPFile].[RevrecShipVol] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [Profitcenter]  NVARCHAR (10) NULL,
    [OrderNumber]   NVARCHAR (10) NULL,
    [PartNumber]    NVARCHAR (6)  NULL,
    [DocumentType]  NVARCHAR (4)  NULL,
    [InvoiceDate]   NVARCHAR (8)  NULL,
    [Count]         DECIMAL (4)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([OrderNumber]));



