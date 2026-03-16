CREATE TABLE [SrcSFDC].[GroupMember] (
    [LZBatchID]      INT           NOT NULL,
    [ADLSBatchID]    INT           NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0) NOT NULL,
    [GroupId]        NCHAR (18)    NOT NULL,
    [Id]             NCHAR (18)    NOT NULL,
    [SystemModstamp] DATETIME2 (7) NOT NULL,
    [UserOrGroupId]  NCHAR (18)    NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

