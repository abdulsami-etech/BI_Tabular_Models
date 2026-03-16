CREATE TABLE [SrcSFDC].[UserTerritory2Association] (
    [LZBatchID]        INT            NOT NULL,
    [ADLSBatchID]      INT            NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)  NOT NULL,
    [Id]               NCHAR (18)     NOT NULL,
    [IsActive]         BIT            NOT NULL,
    [LastModifiedById] NCHAR (18)     NULL,
    [LastModifiedDate] DATETIME2 (7)  NOT NULL,
    [RoleInTerritory2] NVARCHAR (255) NULL,
    [SystemModstamp]   DATETIME2 (7)  NOT NULL,
    [Territory2Id]     NCHAR (18)     NOT NULL,
    [UserId]           NCHAR (18)     NOT NULL
)
WITH (CLUSTERED INDEX([Territory2Id]), DISTRIBUTION = ROUND_ROBIN);

