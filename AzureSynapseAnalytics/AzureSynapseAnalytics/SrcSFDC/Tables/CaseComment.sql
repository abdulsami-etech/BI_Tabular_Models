CREATE TABLE [SrcSFDC].[CaseComment] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [CommentBody]          NVARCHAR (MAX) NULL,
    [ConnectionReceivedId] NCHAR (18)     NULL,
    [ConnectionSentId]     NCHAR (18)     NULL,
    [CreatedById]          NCHAR (18)     NULL,
    [CreatedDate]          DATETIME2 (7)  NOT NULL,
    [Id]                   NCHAR (18)     NOT NULL,
    [IsDeleted]            BIT            NOT NULL,
    [IsPublished]          BIT            NOT NULL,
    [LastModifiedById]     NCHAR (18)     NULL,
    [LastModifiedDate]     DATETIME2 (7)  NOT NULL,
    [ParentId]             NCHAR (18)     NOT NULL,
    [SystemModstamp]       DATETIME2 (7)  NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

