CREATE TABLE [SrcSFDC].[Attachment] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [ConnectionReceivedId] NCHAR (18)     NULL,
    [ConnectionSentId]     NCHAR (18)     NULL,
    [ContentType]          NVARCHAR (120) NULL,
    [CreatedById]          NCHAR (18)     NULL,
    [CreatedDate]          DATETIME2 (7)  NOT NULL,
    [Description]          NVARCHAR (500) NULL,
    [Id]                   NCHAR (18)     NOT NULL,
    [IsDeleted]            NVARCHAR (10)  NOT NULL,
    [IsEncrypted]          NVARCHAR (10)  NOT NULL,
    [IsPartnerShared]      NVARCHAR (10)  NOT NULL,
    [IsPrivate]            NVARCHAR (10)  NOT NULL,
    [LastModifiedById]     NCHAR (18)     NULL,
    [LastModifiedDate]     DATETIME2 (7)  NOT NULL,
    [Name]                 NVARCHAR (255) NOT NULL,
    [OwnerId]              NCHAR (18)     NOT NULL,
    [ParentId]             NCHAR (18)     NOT NULL,
    [SystemModstamp]       DATETIME2 (7)  NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

