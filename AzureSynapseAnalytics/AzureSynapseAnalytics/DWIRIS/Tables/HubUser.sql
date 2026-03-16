CREATE TABLE [DWIRIS].[HubUser] (
    [SKUser]           INT          IDENTITY (1, 1) NOT NULL,
    [KeyUser]          NCHAR (18)   NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyUser]), DISTRIBUTION = REPLICATE);

