CREATE TABLE [SrcMAT].[Scanner_ExtendedInfo] (
    [LZBatchID]         INT           NOT NULL,
    [ADLSBatchID]       INT           NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0) NOT NULL,
    [CartSN]            NVARCHAR (50) NOT NULL,
    [ScannerTypeID]     SMALLINT      NOT NULL,
    [WarrantyTo]        INT           NOT NULL,
    [WarrantyTypeID]    SMALLINT      NOT NULL,
    [WarrantyStartDate] DATETIME      NULL,
    [WarrantyEndDate]   DATETIME      NULL,
    [RowStatusID]       TINYINT       NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [CreatedByUserID]   INT           NOT NULL,
    [DateUpdated]       DATETIME      NOT NULL,
    [UpdatedByUserID]   INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

