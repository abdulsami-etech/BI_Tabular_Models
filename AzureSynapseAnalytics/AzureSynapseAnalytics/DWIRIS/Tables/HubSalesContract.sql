CREATE TABLE [DWIRIS].[HubSalesContract] (
    [SKSalesContract]  INT           IDENTITY (1, 1) NOT NULL,
    [KeySalesContract] NVARCHAR (18) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL
)
WITH (CLUSTERED INDEX([KeySalesContract]), DISTRIBUTION = REPLICATE);

