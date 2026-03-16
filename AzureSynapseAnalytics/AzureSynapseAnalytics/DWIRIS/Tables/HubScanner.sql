CREATE TABLE [DWIRIS].[HubScanner] (
    [SKScanner]      INT            IDENTITY (1, 1) NOT NULL,
    [KeyScanner]     NVARCHAR (160) NOT NULL,
    [SourceSystem]   CHAR (40)      NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyScanner]), DISTRIBUTION = REPLICATE);

