CREATE TABLE [DWIRIS].[DimVirtualProduct] (
    [SKVirtualProduct]  INT            NOT NULL,
    [ADLSBatchID]       INT            NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)  NOT NULL,
    [LZBatchID]         INT            NOT NULL,
    [DWBatchID]         INT            NULL,
    [DWHash]            CHAR (40)      NULL,
    [SKAsset]           INT            NULL,
    [KeyVirtualProduct] INT            NULL,
    [StartDate]         DATETIME2 (0)  NULL,
    [SKStartDate]       INT            NULL,
    [ExpiryDate]        DATETIME2 (0)  NULL,
    [SKExpiryDate]      INT            NULL,
    [AutoRenewal]       INT            NULL,
    [SerialCode]        NVARCHAR (255) NULL,
    [Category]          NVARCHAR (255) NULL,
    [TypeName]          NVARCHAR (255) NULL,
    [Description]       varchar(100) NULL
)
WITH (CLUSTERED INDEX([SKVirtualProduct]), DISTRIBUTION = REPLICATE);

