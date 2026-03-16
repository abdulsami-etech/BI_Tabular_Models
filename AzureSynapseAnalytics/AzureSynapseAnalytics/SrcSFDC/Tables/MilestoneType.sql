CREATE TABLE [SrcSFDC].[MilestoneType] (
    [LZBatchID]        INT            NOT NULL,
    [ADLSBatchID]      INT            NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)  NOT NULL,
    [CreatedById]      NVARCHAR (18)  NULL,
    [CreatedDate]      DATETIME2 (7)  NULL,
    [Description]      NVARCHAR (255) NULL,
    [Id]               NVARCHAR (18)  NULL,
    [LastModifiedById] NVARCHAR (18)  NULL,
    [LastModifiedDate] DATETIME2 (7)  NULL,
    [Name]             NVARCHAR (80)  NULL,
    [RecurrenceType]   NVARCHAR (40)  NULL,
    [SystemModstamp]   DATETIME2 (7)  NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

