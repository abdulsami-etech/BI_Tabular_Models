CREATE TABLE [SrcIDS].[tblcnpatientordermap] (
    [LZBatchID]      INT                                      NOT NULL,
    [ADLSBatchID]    INT                                      NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)                            NOT NULL,
    [vip_order_id]   INT                                      NOT NULL,
    [vip_patient_id] INT                                      NOT NULL,
    [jde_order_id]   BIGINT                                   NULL,
    [modified_at]    DATETIME2 (7)                            NULL,
    [_Region]        VARCHAR (32)                             NOT NULL
)
WITH (CLUSTERED INDEX([vip_order_id]), DISTRIBUTION = HASH([vip_order_id]));

