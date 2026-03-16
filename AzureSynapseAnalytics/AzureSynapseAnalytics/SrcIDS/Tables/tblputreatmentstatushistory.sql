CREATE TABLE [SrcIDS].[tblputreatmentstatushistory] (
    [LZBatchID]                   INT                                      NOT NULL,
    [ADLSBatchID]                 INT                                      NOT NULL,
    [ADLSTimestamp]               DATETIME2 (0)                            NOT NULL,
    [treatment_status_history_id] INT                                      NOT NULL,
    [history_item_type]           INT                                      NOT NULL,
    [treatment_id]                INT                                      NOT NULL,
    [vip_patient_id]              INT                                      NOT NULL,
    [tx_type_id]                  INT                                      NOT NULL,
    [tx_status_id]                INT                                      NOT NULL,
    [tx_eecd]                     DATETIME2 (7)                            NULL,
    [primary_vip_order_id]        INT                                      NULL,
    [modified_date]               DATETIME2 (7)                            NULL,
    [last_vip_order_id]           INT                                      NULL,
    [tx_ccd]                      DATETIME2 (7)                            NULL,
    [_Region]                     VARCHAR (32)                             NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([primary_vip_order_id]));

