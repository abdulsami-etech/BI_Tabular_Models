CREATE TABLE [DWIRIS].[FactScannerInstallation] (
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [LZBatchID]     INT           NOT NULL,
    [DWBatchID]     INT           NOT NULL,
    [SKAsset]       INT           NOT NULL,
    [SKAccount]     INT           NOT NULL,
    [SKDate]        INT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SKAsset]));

