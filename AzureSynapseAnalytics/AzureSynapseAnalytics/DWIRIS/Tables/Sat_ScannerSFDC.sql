CREATE TABLE [DWIRIS].[Sat_ScannerSFDC] (
    [SKScanner]     INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [DWHash]        CHAR (40)      NOT NULL,
    [DWBatchID]     INT            NOT NULL,
    [KeyScanner]    NVARCHAR (160) NULL,
    [ScannerID]     NVARCHAR (255) NULL,
    [CreatedDate]   DATETIME2 (0)  NULL,
    [ScannerModel]  NVARCHAR (255) NULL
)
WITH (CLUSTERED INDEX([SKScanner]), DISTRIBUTION = REPLICATE);

