CREATE TABLE [SrcIDS].[tblPuDoctorIntraoralScan] (
    [LZBatchID]                 INT           NOT NULL,
    [ADLSBatchID]               INT           NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0) NOT NULL,
    [doctor_intra_oral_scan_id] INT           NOT NULL,
    [master_user_id]            INT           NULL,
    [vendor]                    INT           NULL,
    [external_id]               NVARCHAR (50) NULL,
    [disable_date]              DATETIME2 (7) NULL,
    [modified_by]               NVARCHAR (50) NULL,
    [modified_date]             DATETIME2 (7) NULL,
    [_Region]                   VARCHAR (32)  NOT NULL
)
WITH (CLUSTERED INDEX([doctor_intra_oral_scan_id]), DISTRIBUTION = HASH([doctor_intra_oral_scan_id]));

