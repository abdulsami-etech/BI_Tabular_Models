CREATE TABLE [SrcSFDC].[Apttus_Config2__IncentiveLoyaltyEnrollment__History] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [CreatedById]   NCHAR (18)     NULL,
    [CreatedDate]   DATETIME2 (7)  NOT NULL,
    [Field]         NVARCHAR (255) NOT NULL,
    [Id]            NCHAR (18)     NOT NULL,
    [IsDeleted]     BIT            NOT NULL,
    [NewValue]      NVARCHAR (255) NULL,
    [OldValue]      NVARCHAR (255) NULL,
    [ParentId]      NCHAR (18)     NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

