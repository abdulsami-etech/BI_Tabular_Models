CREATE TABLE [SrcCONSDL].[DMA] (
    [LZBatchID]               INT            NOT NULL,
    [ADLSBatchID]             INT            NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)  NOT NULL,
    [Zip]                     NVARCHAR (20)  NOT NULL,
    [DMAName]                 NVARCHAR (100) NOT NULL,
    [ConsumerMarketingDBName] NVARCHAR (100) NULL,
    [ConsumerMarketingName]   NVARCHAR (100) NULL,
    [UsStateCode]             NVARCHAR (5)   NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

