CREATE TABLE [DWIRIS].[HubTeam] (
    [SKTeam]           INT            IDENTITY (1, 1) NOT NULL,
    [KeyTeam]          NVARCHAR (255) NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NOT NULL,
    [DWBatchID]        INT            NOT NULL,
    [InsertDateTime]   DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyTeam]), DISTRIBUTION = REPLICATE);

