CREATE TABLE [SrcEUPRWAPAC].[CaseDownload] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [Id]                   BIGINT        NOT NULL,
    [OrderId]              BIGINT        NOT NULL,
    [ACSFileRevision]      VARCHAR (50)  NULL,
    [FileType]             INT           NULL,
    [DownloadedByClientId] INT           NULL,
    [DownloadDate]         DATETIME      NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

