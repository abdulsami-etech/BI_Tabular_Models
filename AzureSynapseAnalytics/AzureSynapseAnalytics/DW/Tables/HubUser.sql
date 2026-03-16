CREATE TABLE [DW].[HubUser] (
    [SKUser]           INT           IDENTITY (1, 1) NOT NULL,
    [KeyUser]          NVARCHAR (18) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL,
    CONSTRAINT [PK_HubUser] PRIMARY KEY NONCLUSTERED ([SKUser] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubUser_KeyUser] UNIQUE NONCLUSTERED ([KeyUser] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyUser]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_HubUser_KeyUser]
    ON [DW].[HubUser]([KeyUser] ASC);

