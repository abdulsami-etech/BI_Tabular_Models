CREATE TABLE [DWTOPS].[HubComment] (
    [SKComment]        INT            IDENTITY (1, 1) NOT NULL,
    [KeyComment]       NVARCHAR (255) NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NOT NULL,
    [DWBatchID]        INT            NOT NULL,
    [InsertDateTime]   DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyComment]), DISTRIBUTION = HASH([KeyComment]));

