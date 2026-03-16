CREATE TABLE [DWIRIS].[HubEntitlement] (
    [SKEntitlement]    INT            IDENTITY (1, 1) NOT NULL,
    [KeyEntitlement]   NVARCHAR (255) NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NOT NULL,
    [DWBatchID]        INT            NOT NULL,
    [InsertDateTime]   DATETIME       NOT NULL,
    CONSTRAINT [PK_HubEntitlement] PRIMARY KEY NONCLUSTERED ([SKEntitlement] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubEntitlement_KeyEntitlement] UNIQUE NONCLUSTERED ([KeyEntitlement] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([KeyEntitlement]), DISTRIBUTION = REPLICATE);

