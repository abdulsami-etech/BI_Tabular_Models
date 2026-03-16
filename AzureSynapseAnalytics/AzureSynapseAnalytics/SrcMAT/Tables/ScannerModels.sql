CREATE TABLE [SrcMAT].[ScannerModels] (
    [LZBatchID]                INT            NOT NULL,
    [ADLSBatchID]              INT            NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)  NOT NULL,
    [ScannerModelID]           INT            NOT NULL,
    [ScannerModelDescription]  NVARCHAR (50)  NOT NULL,
    [RegexSerialNumberPattern] NVARCHAR (100) NULL,
    [ProductID]                INT            NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

