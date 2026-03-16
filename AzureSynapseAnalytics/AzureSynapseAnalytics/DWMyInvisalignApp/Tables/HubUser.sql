CREATE TABLE [DWMyInvisalignApp].[HubUser] (
    [SKUser]         INT            IDENTITY (1, 1) NOT NULL,
    [KeyUser]        NVARCHAR (100) NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NULL
)
WITH (CLUSTERED INDEX([KeyUser]), DISTRIBUTION = REPLICATE);

