CREATE TABLE [SrcMAT].[Activity_FileAttachment] (
    [LZBatchID]                INT            NOT NULL,
    [ADLSBatchID]              INT            NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)  NOT NULL,
    [ActivityFileAttachmentID] INT            NOT NULL,
    [ActivityID]               INT            NULL,
    [FileSizeKb]               INT            NULL,
    [OriginalFileName]         NVARCHAR (200) NULL,
    [RepositoryFileName]       NVARCHAR (200) NULL,
    [RepositoryFilePath]       NVARCHAR (250) NULL,
    [HttpFileLink]             NVARCHAR (500) NULL,
    [RowStatusID]              INT            NULL,
    [DateCreated]              DATETIME       NULL,
    [DateUpdated]              DATETIME       NULL
)
WITH (CLUSTERED INDEX([ActivityFileAttachmentID]), DISTRIBUTION = HASH([ActivityID]));

