CREATE TABLE [DW].[HubContact] (
    [SKContact]        INT          IDENTITY (1, 1) NOT NULL,
    [KeyContact]       NCHAR (18)   NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL,
    CONSTRAINT [PK_HubContact] PRIMARY KEY NONCLUSTERED ([SKContact] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubContact_KeyContact] UNIQUE NONCLUSTERED ([KeyContact] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyContact]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_HubContact_KeyContact]
    ON [DW].[HubContact]([KeyContact] ASC);

