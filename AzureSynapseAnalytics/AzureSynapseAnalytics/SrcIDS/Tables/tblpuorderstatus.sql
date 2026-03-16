CREATE TABLE [SrcIDS].[tblpuorderstatus] (
    [LZBatchID]               INT           NOT NULL,
    [ADLSBatchID]             INT           NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0) NOT NULL,
    [vip_order_id]            INT           NOT NULL,
    [order_status_history_id] INT           NOT NULL,
    [vip_version]             SMALLINT      NOT NULL,
    [modified_date]           DATETIME2 (7) NULL,
    [_Region]                 VARCHAR (32)  NOT NULL
)
WITH (CLUSTERED INDEX([vip_order_id]), DISTRIBUTION = HASH([vip_order_id]));

