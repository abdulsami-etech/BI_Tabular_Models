CREATE TABLE [SrcIDS].[tblcndoctorpatientmap] (
    [LZBatchID]          INT                                      NOT NULL,
    [ADLSBatchID]        INT                                      NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)                            NOT NULL,
    [vip_patient_id]     INT                                      NOT NULL,
    [did]                BIGINT                                   NULL,
    [lid_treat_location] BIGINT                                   NULL,
    [load_option]        SMALLINT                                 NOT NULL,
    [master_user_id]     INT                                      NULL,
    [modified_at]        DATETIME2 (7)                            NULL,
    [jde_patient_id]     CHAR (64)                                NULL,
    [_Region]            VARCHAR (32)                             NOT NULL
)
WITH (CLUSTERED INDEX([vip_patient_id]), DISTRIBUTION = ROUND_ROBIN);

