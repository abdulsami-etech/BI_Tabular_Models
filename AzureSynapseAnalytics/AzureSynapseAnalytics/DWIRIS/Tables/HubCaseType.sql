CREATE TABLE [DWIRIS].[HubCaseType] (
    [SKCaseType]       INT            IDENTITY (1, 1) NOT NULL,
    [KeyCaseType]      NVARCHAR (255) NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NOT NULL,
    [DWBatchID]        INT            NOT NULL,
    [InsertDateTime]   DATETIME       NOT NULL,
    CONSTRAINT [PK_HubCaseType] PRIMARY KEY NONCLUSTERED ([SKCaseType] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubCaseType_KeyCaseType] UNIQUE NONCLUSTERED ([KeyCaseType] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyCaseType]), DISTRIBUTION = REPLICATE);

