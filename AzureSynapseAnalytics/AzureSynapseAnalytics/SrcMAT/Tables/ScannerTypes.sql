CREATE TABLE [SrcMAT].[ScannerTypes] (
    [LZBatchID]              INT           NOT NULL,
    [ADLSBatchID]            INT           NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0) NOT NULL,
    [ScannerTypeID]          INT           NOT NULL,
    [ScannerTypeDescription] NVARCHAR (50) NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

