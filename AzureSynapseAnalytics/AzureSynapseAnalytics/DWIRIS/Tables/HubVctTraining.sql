CREATE TABLE [DWIRIS].[HubVctTraining] (
    [SKVctTraining]    INT          IDENTITY (1, 1) NOT NULL,
    [KeyVctTraining]   NCHAR (18)   NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL
)
WITH (CLUSTERED INDEX([KeyVctTraining]), DISTRIBUTION = REPLICATE);

