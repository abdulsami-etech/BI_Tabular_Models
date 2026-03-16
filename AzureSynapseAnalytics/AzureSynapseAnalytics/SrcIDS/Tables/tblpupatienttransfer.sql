CREATE TABLE [SrcIDS].[tblpupatienttransfer] (
    [LZBatchID]             INT                                      NOT NULL,
    [ADLSBatchID]           INT                                      NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)                            NOT NULL,
    [transfer_id]           INT                                      NOT NULL,
    [vip_patient_id]        INT                                      NOT NULL,
    [patient_authorization] BIT                                      NOT NULL,
    [from_master_user_id]   INT                                      NOT NULL,
    [to_master_user_id]     INT                                      NOT NULL,
    [to_lid]                INT                                      NOT NULL,
    [created_date]          DATETIME2 (7)                            NOT NULL,
    [canceled_date]         DATETIME2 (7)                            NULL,
    [completed_date]        DATETIME2 (7)                            NULL,
    [transfer_type]         INT                                      NOT NULL,
    [patient_visit]         BIT                                      NULL,
    [doctor_agreement]      BIT                                      NULL,
    [prescription_started]  BIT                                      NULL,
    [_Region]               VARCHAR (32)                             NOT NULL
)
WITH (CLUSTERED INDEX([vip_patient_id]), DISTRIBUTION = ROUND_ROBIN);

