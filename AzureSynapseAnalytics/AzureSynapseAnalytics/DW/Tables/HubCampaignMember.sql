CREATE TABLE [DW].[HubCampaignMember] (
    [SKCampaignMember]       INT           IDENTITY (1, 1) NOT NULL,
    [KeyCampaignMember]      NVARCHAR (18) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL,
    CONSTRAINT [PK_HubCampaignMember] PRIMARY KEY NONCLUSTERED ([SKCampaignMember] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubCampaignMember_KeyCampaignMember] UNIQUE NONCLUSTERED ([KeyCampaignMember] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = REPLICATE);
