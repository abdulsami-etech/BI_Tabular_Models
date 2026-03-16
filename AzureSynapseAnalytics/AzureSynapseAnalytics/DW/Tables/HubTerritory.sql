CREATE TABLE [DW].[HubTerritory] (
    [SKTerritory]      INT          IDENTITY (1, 1) NOT NULL,
    [KeyTerritory]     NCHAR (18)   NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL,
    CONSTRAINT [PK_HubTerritory] PRIMARY KEY NONCLUSTERED ([SKTerritory] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubTerritory_KeyTerritory] UNIQUE NONCLUSTERED ([KeyTerritory] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyTerritory]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_HubTerritory_KeyTerritory]
    ON [DW].[HubTerritory]([KeyTerritory] ASC);

