CREATE TABLE [DW].[HubCampaign] (
    [SKCampaign]       INT           IDENTITY (1, 1) NOT NULL,
    [KeyCampaign]      NVARCHAR (18) NOT NULL,
    [SourceSystemCode] VARCHAR (10)  NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [InsertDateTime]   DATETIME      NOT NULL,
    CONSTRAINT [PK_HubCampaign] PRIMARY KEY NONCLUSTERED ([SKCampaign] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubCampaign_KeyCampaign] UNIQUE NONCLUSTERED ([KeyCampaign] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = REPLICATE);