CREATE TABLE [DW].[HubLeadConversation] (
    [SKLeadConversation]       INT           IDENTITY (1, 1) NOT NULL,
    [KeyLeadConversation]      NVARCHAR (18) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL,
    CONSTRAINT [PK_HubLeadConversation] PRIMARY KEY NONCLUSTERED ([SKLeadConversation] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubLeadConversation_KeyLeadConversation] UNIQUE NONCLUSTERED ([KeyLeadConversation] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([KeyLeadConversation]));