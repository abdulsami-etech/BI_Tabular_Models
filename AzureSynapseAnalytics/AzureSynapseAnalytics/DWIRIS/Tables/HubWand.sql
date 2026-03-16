CREATE TABLE [DWIRIS].[HubWand] (
    [SKWand]         INT            IDENTITY (1, 1) NOT NULL,
    [KeyWand]        NVARCHAR (160) NOT NULL,
    [SourceSystem]   CHAR (40)      NOT NULL,
    [DWBatchID]      INT            NOT NULL,
    [InsertDateTime] DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([KeyWand]), DISTRIBUTION = REPLICATE);

