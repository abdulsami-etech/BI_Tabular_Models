CREATE TABLE [DWIRIS].[HubOpportunity] (
    [SKOpportunity]  INT            IDENTITY (1, 1) NOT NULL,
    [KeyOpportunity] NVARCHAR (255) NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyOpportunity]), DISTRIBUTION = REPLICATE);

