CREATE TABLE [DWIRIS].[Sat_ScannerMAT] (
    [SKScanner]         INT            NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)  NOT NULL,
    [DWHash]            CHAR (40)      NOT NULL,
    [DWBatchID]         INT            NOT NULL,
    [KeyScanner]        NVARCHAR (160) NULL,
    [ScannerID]         NVARCHAR (255) NULL,
    [CreatedDate]       DATETIME2 (0)  NULL,
    [ScannerModel]      NVARCHAR (255) NULL,
    [HolderID]          INT            NULL,
    [HolderName]        NVARCHAR (255) NULL,
    [OwnerID]           INT            NULL,
    [OwnerName]         NVARCHAR (255) NULL,
    [RegisteredToId]    INT            NULL,
    [RegisteredToName]  NVARCHAR (255) NULL,
    [RegistrationDate]  DATETIME2 (0)  NULL,
    [RegistrationOrder] INT            NULL
)
WITH (CLUSTERED INDEX([SKScanner]), DISTRIBUTION = REPLICATE);

