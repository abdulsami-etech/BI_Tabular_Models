CREATE TABLE [SrcSFDC].[AccountContactRole] (
    [LZBatchID]        INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [AccountId]        NCHAR (18)    NOT NULL,
    [ContactId]        NCHAR (18)    NOT NULL,
    [CreatedById]      NCHAR (18)    NULL,
    [CreatedDate]      DATETIME2 (7) NOT NULL,
    [Id]               NCHAR (18)    NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [IsPrimary]        BIT           NOT NULL,
    [LastModifiedById] NCHAR (18)    NULL,
    [LastModifiedDate] DATETIME2 (7) NOT NULL,
    [Role]             NVARCHAR (40) NULL,
    [SystemModstamp]   DATETIME2 (7) NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

