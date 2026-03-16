CREATE TABLE [DW].[HubLead] (
    [SKLead]                INT IDENTITY (1, 1) NOT NULL,
    [KeyLead]               NVARCHAR (18)       NOT NULL,
    [SourceSystemCode]      VARCHAR (10)        NOT NULL,
    [DWBatchID]             INT                 NOT NULL,
    [InsertDateTime]        DATETIME            NOT NULL,
    CONSTRAINT [PK_HubLead]             PRIMARY KEY NONCLUSTERED ([SKLead]  ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubLeadCall_KeyLead] UNIQUE NONCLUSTERED      ([KeyLead] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([KeyLead]));