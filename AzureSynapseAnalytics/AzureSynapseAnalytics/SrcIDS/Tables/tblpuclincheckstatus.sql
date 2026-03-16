CREATE TABLE [SrcIDS].[tblpuclincheckstatus] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [export_id]     INT           NOT NULL,
    [vip_order_id]  INT           NULL,
    [modified_date] DATETIME2 (7) NULL,
    [_Region]       VARCHAR (32)  NOT NULL
)
WITH (CLUSTERED INDEX([export_id]), DISTRIBUTION = HASH([export_id]));

