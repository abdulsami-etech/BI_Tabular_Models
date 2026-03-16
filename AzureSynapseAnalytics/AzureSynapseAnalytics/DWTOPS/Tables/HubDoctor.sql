CREATE TABLE [DWTOPS].[HubDoctor] (
    [SKDoctor]         INT           IDENTITY (1, 1) NOT NULL,
    [KeyDoctor]        NVARCHAR (80) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL
)
WITH (CLUSTERED INDEX([KeyDoctor]), DISTRIBUTION = REPLICATE);

