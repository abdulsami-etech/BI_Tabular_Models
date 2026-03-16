CREATE TABLE [DW].[HubLeadCall] (
    [SKLeadCall]       INT           IDENTITY (1, 1) NOT NULL,
    [KeyLeadCall]      NVARCHAR (18) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL,
    CONSTRAINT [PK_HubLeadCall] PRIMARY KEY NONCLUSTERED ([SKLeadCall] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubLeadCall_KeyLeadCall] UNIQUE NONCLUSTERED ([KeyLeadCall] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([KeyLeadCall]));