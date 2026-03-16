CREATE TABLE [SrcSFDC].[OpportunityFieldHistory] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [CreatedById]   NCHAR (18)     NULL,
    [CreatedDate]   DATETIME2 (7)  NOT NULL,
    [Field]         NVARCHAR (255) NOT NULL,
    [Id]            NCHAR (18)     NOT NULL,
    [IsDeleted]     VARCHAR (5)    NOT NULL,
    [NewValue]      NVARCHAR (255) NULL,
    [OldValue]      NVARCHAR (255) NULL,
    [OpportunityId] NCHAR (18)     NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

