CREATE TABLE [SrcIDS].[tblCnPatients] (
    [LZBatchID]      INT                                      NOT NULL,
    [ADLSBatchID]    INT                                      NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)                            NOT NULL,
    [vip_patient_id] INT                                      NOT NULL,
    [gender]         NVARCHAR (50)                            NULL,
    [archive]        INT                                      NOT NULL,
    [create_date]    DATETIME2 (7)                            NULL,
    [modified_date]  DATETIME2 (7)                            NULL,
    [_Region]        VARCHAR (32)                             NOT NULL
)
WITH (CLUSTERED INDEX([vip_patient_id]), DISTRIBUTION = ROUND_ROBIN);

