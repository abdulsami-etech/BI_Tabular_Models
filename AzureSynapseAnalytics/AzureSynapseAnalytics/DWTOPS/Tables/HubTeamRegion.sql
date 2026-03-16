CREATE TABLE [DWTOPS].[HubTeamRegion] (
    [SKTeamRegion]     INT          IDENTITY (1, 1) NOT NULL,
    [KeyTeamRegion]    VARCHAR (80) NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyTeamRegion]), DISTRIBUTION = REPLICATE);

