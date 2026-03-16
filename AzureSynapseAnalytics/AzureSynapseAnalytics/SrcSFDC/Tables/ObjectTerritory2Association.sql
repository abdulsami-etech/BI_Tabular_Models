CREATE TABLE [SrcSFDC].[ObjectTerritory2Association] (
    [LZBatchID]        INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [AssociationCause] NVARCHAR (40) NOT NULL,
    [Id]               NCHAR (18)    NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [LastModifiedById] NCHAR (18)    NULL,
    [LastModifiedDate] DATETIME2 (7) NOT NULL,
    [ObjectId]         NCHAR (18)    NOT NULL,
    [SobjectType]      NVARCHAR (40) NULL,
    [SystemModstamp]   DATETIME2 (7) NOT NULL,
    [Territory2Id]     NCHAR (18)    NOT NULL
)
WITH (CLUSTERED INDEX([Territory2Id]), DISTRIBUTION = ROUND_ROBIN);

