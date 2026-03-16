CREATE TABLE [DWIRIS].[FactCaseDownload] (
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [LZBatchID]            INT           NOT NULL,
    [DWBatchID]            INT           NOT NULL,
    [DWHash]               CHAR (40)     NULL,
    [ID]                   BIGINT        NOT NULL,
    [SourceSystem]         CHAR (10)     NOT NULL,
    [SKCase]               INT           NOT NULL,
    [KeyCase]              BIGINT        NOT NULL,
    [ACSFileRevision]      VARCHAR (50)  NULL,
    [FileType]             INT           NULL,
    [DownloadedByClientID] INT           NULL,
    [DownloadDate]         DATETIME      NULL,
    [DownloadCount]        INT           NULL,
    [SKDateTime]           INT           NULL,
    CONSTRAINT [PK_HubCaseDownload] PRIMARY KEY NONCLUSTERED ([ID] ASC, [SourceSystem] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

