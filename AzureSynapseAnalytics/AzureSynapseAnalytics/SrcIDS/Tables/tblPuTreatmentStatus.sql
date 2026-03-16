CREATE TABLE [SrcIDS].[tblPuTreatmentStatus] (
    [LZBatchID]                   INT           NOT NULL,
    [ADLSBatchID]                 INT           NOT NULL,
    [ADLSTimestamp]               DATETIME2 (0) NOT NULL,
    [treatment_id]                INT           NOT NULL,
    [treatment_status_history_id] INT           NOT NULL,
    [modified_date]               DATETIME2 (7) NULL,
    [_Region]                     VARCHAR (32)  NOT NULL
)
WITH (CLUSTERED INDEX([treatment_id]), DISTRIBUTION = HASH([treatment_id]));

