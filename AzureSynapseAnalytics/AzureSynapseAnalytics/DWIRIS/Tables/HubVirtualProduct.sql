CREATE TABLE [DWIRIS].[HubVirtualProduct] (
    [SKVirtualProduct]  INT      IDENTITY (1, 1) NOT NULL,
    [KeyVirtualProduct] INT      NOT NULL,
    [DWBatchID]         INT      NOT NULL,
    [InsertDateTime]    DATETIME NOT NULL
)
WITH (CLUSTERED INDEX([KeyVirtualProduct]), DISTRIBUTION = REPLICATE);

