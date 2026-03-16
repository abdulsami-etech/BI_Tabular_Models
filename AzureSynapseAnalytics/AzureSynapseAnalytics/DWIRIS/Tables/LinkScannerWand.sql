CREATE TABLE [DWIRIS].[LinkScannerWand] (
    [HashScannerWandKey] BINARY (32)    NOT NULL,
    [DWBatchID]          INT            NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)  NOT NULL,
    [SourceSystem]       CHAR (40)      NOT NULL,
    [SKScanner]          INT            NOT NULL,
    [SKWand]             INT            NOT NULL,
    [KeyScanner]         NVARCHAR (160) NOT NULL,
    [KeyWand]            NVARCHAR (160) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([HashScannerWandKey]));

