CREATE TABLE [DWIRIS].[DimTeam] (
    [SKTeam]        INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [LZBatchID]     INT            NOT NULL,
    [DWBatchID]     INT            NOT NULL,
    [DWHash]        CHAR (40)      NOT NULL,
    [SourceSystem]  VARCHAR (10)   NOT NULL,
    [TeamName]      NVARCHAR (255) NULL,
    [TeamMATID]     INT            NULL
)
WITH (CLUSTERED INDEX([SKTeam]), DISTRIBUTION = REPLICATE);

