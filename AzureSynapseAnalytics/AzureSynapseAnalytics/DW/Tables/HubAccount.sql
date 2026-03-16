CREATE TABLE [DW].[HubAccount] (
    [SKAccount]        INT          IDENTITY (1, 1) NOT NULL,
    [KeyAccount]       NCHAR (18)   NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL,
    CONSTRAINT [PK_HubAccount] PRIMARY KEY NONCLUSTERED ([SKAccount] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubAccount_KeyAccount] UNIQUE NONCLUSTERED ([KeyAccount] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyAccount]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_HubAccount_KeyAccount]
    ON [DW].[HubAccount]([KeyAccount] ASC);

