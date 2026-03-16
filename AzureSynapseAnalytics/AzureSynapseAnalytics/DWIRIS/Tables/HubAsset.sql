CREATE TABLE [DWIRIS].[HubAsset] (
    [SKAsset]        INT            IDENTITY (1, 1) NOT NULL,
    [KeyAsset]       NVARCHAR (160) NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyAsset]), DISTRIBUTION = REPLICATE);

