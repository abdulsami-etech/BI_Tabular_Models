CREATE TABLE [SrcSFDC].[RecordType] (
    [LZBatchID]         INT            NOT NULL,
    [ADLSBatchID]       INT            NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)  NOT NULL,
    [BusinessProcessId] NCHAR (18)     NULL,
    [CreatedById]       NCHAR (18)     NULL,
    [CreatedDate]       DATETIME2 (7)  NOT NULL,
    [Description]       NVARCHAR (255) NULL,
    [DeveloperName]     NVARCHAR (80)  NOT NULL,
    [Id]                NCHAR (18)     NOT NULL,
    [IsActive]          BIT            NOT NULL,
    [LastModifiedById]  NCHAR (18)     NULL,
    [LastModifiedDate]  DATETIME2 (7)  NOT NULL,
    [Name]              NVARCHAR (80)  NOT NULL,
    [NamespacePrefix]   NVARCHAR (15)  NULL,
    [SobjectType]       NVARCHAR (60)  NOT NULL,
    [SystemModstamp]    DATETIME2 (7)  NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

