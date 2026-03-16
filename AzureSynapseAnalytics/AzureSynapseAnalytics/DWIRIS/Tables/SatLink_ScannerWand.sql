CREATE TABLE [DWIRIS].[SatLink_ScannerWand] (
    [HashScannerWandKey] BINARY (32)    NOT NULL,
    [InsertDateTime]     DATETIME2 (7)  NOT NULL,
    [SourceSystem]       NVARCHAR (32)  NOT NULL,
    [HashDiff]           BINARY (32)    NOT NULL,
    [EventName]          NVARCHAR (256) NULL,
    [EventDate]          DATETIME2 (7)  NULL,
    [KeyScanner]         NVARCHAR (256) NULL,
    [KeyWand]            NVARCHAR (256) NULL,
    [SystemKey]          NVARCHAR (256) NULL,
    [EventCloseDate]     DATETIME       NULL,
    [CurrentStatus]      NVARCHAR (255) NULL
)
WITH (CLUSTERED INDEX([HashScannerWandKey]), DISTRIBUTION = ROUND_ROBIN);

