CREATE TABLE [DWMyInvisalignApp].[HubAPIUser] (
    [SKAPIUser]         INT            IDENTITY (1, 1) NOT NULL,
    [KeyAPIUser]        NVARCHAR (100) NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NULL
)
WITH (CLUSTERED INDEX([KeyAPIUser]), DISTRIBUTION = HASH(KeyAPIUser));
