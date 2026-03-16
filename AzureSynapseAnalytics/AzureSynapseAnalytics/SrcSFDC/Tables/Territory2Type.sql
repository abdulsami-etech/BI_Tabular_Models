CREATE TABLE [SrcSFDC].[Territory2Type] (
    [LZBatchID]        INT            NOT NULL,
    [ADLSBatchID]      INT            NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)  NOT NULL,
    [CreatedById]      NCHAR (18)     NULL,
    [CreatedDate]      DATETIME2 (7)  NOT NULL,
    [Description]      NVARCHAR (255) NULL,
    [DeveloperName]    NVARCHAR (80)  NOT NULL,
    [Id]               NCHAR (18)     NOT NULL,
    [IsDeleted]        BIT            NOT NULL,
    [Language]         NVARCHAR (40)  NOT NULL,
    [LastModifiedById] NCHAR (18)     NULL,
    [LastModifiedDate] DATETIME2 (7)  NOT NULL,
    [MasterLabel]      NVARCHAR (80)  NOT NULL,
    [Priority]         INT            NOT NULL,
    [SystemModstamp]   DATETIME2 (7)  NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

