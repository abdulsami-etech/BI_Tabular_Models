CREATE TABLE [DW].[HubOrder] (
    [SKOrder]          BIGINT       IDENTITY (1, 1) NOT NULL,
    [KeyOrder]         BIGINT       NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL,
    CONSTRAINT [PK_HubOrder] PRIMARY KEY NONCLUSTERED ([SKOrder] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_HubOrder_KeyOrder] UNIQUE NONCLUSTERED ([KeyOrder] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX,  DISTRIBUTION = HASH([KeyOrder]) );


GO
CREATE NONCLUSTERED INDEX [IX_HubOrder_KeyOrder]
    ON [DW].[HubOrder]([KeyOrder] ASC);

