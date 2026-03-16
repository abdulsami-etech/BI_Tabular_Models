CREATE TABLE [DWTOPS].[HubOperation] (
    [SKOperation]      INT          IDENTITY (1, 1) NOT NULL,
    [KeyOperation]     BIGINT       NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyOperation]), DISTRIBUTION = REPLICATE);

