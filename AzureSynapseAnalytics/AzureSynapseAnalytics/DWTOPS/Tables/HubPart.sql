CREATE TABLE [DWTOPS].[HubPart] (
    [SKPart]           INT           IDENTITY (1, 1) NOT NULL,
    [KeyPart]          VARCHAR (129) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL
)
WITH (CLUSTERED INDEX([KeyPart]), DISTRIBUTION = REPLICATE);

