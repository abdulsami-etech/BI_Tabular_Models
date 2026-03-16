CREATE TABLE [SrcIDS].[tblPuClincheckLabDoctors] (
    [LZBatchID]        INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [master_user_id]   INT           NOT NULL,
    [lab_id]           BIGINT        NOT NULL,
    [last_assigned_on] DATETIME2 (7) NOT NULL,
    [_Region]          VARCHAR (32)  NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

