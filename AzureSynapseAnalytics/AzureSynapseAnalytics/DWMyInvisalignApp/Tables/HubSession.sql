CREATE TABLE [DWMyInvisalignApp].[HubSession] (
    [SKSession]      INT           IDENTITY (1, 1) NOT NULL,
    [KeyTrace]       INT           NOT NULL,
    [KeyUser]        NVARCHAR (50) NOT NULL,
    [DWBatchID]      INT           NOT NULL,
    [InsertDateTime] DATETIME      NULL
)
WITH (CLUSTERED INDEX([KeyTrace], [KeyUser]), DISTRIBUTION = REPLICATE);

