CREATE TABLE [DWTOPS].[HubExpediteScope] (
    [SKExpediteScope]  INT          IDENTITY (1, 1) NOT NULL,
    [KeyExpediteScope] VARCHAR (50) NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyExpediteScope]), DISTRIBUTION = REPLICATE);

