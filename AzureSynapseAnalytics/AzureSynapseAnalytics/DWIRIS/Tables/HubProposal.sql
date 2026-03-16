CREATE TABLE [DWIRIS].[HubProposal] (
    [SKProposal]     INT            IDENTITY (1, 1) NOT NULL,
    [KeyProposal]    NVARCHAR (255) NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyProposal]), DISTRIBUTION = REPLICATE);

