CREATE TABLE [SrcSec].[RegionCompcodeMapping] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [Region]        NVARCHAR (60) NOT NULL,
    [Companycode]   NVARCHAR (60) NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

