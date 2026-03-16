CREATE TABLE [DWIRIS].[HubCase] (
    [SKCase]           INT            IDENTITY (1, 1) NOT NULL,
    [KeyCase]          NVARCHAR (255) NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NOT NULL,
    [DWBatchID]        INT            NOT NULL,
    [InsertDateTime]   DATETIME       NOT NULL,
    CONSTRAINT [PK_HubCase] PRIMARY KEY NONCLUSTERED ([SKCase] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubCase_KeyCase] UNIQUE NONCLUSTERED ([KeyCase] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyCase]), DISTRIBUTION = REPLICATE);

