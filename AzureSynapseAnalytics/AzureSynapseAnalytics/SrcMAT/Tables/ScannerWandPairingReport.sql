CREATE TABLE [SrcMAT].[ScannerWandPairingReport] (
    [LZBatchID]       INT            NOT NULL,
    [ADLSBatchID]     INT            NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0)  NOT NULL,
    [Id]              INT            NOT NULL,
    [IsActive]        BIT            NOT NULL,
    [ScannerId]       INT            NOT NULL,
    [WandId]          INT            NOT NULL,
    [SoftwareVersion] NVARCHAR (200) NOT NULL,
    [DateUpdated]     DATETIME       NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

