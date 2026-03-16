CREATE TABLE [SrcIDS].[tblCnPilotDoctors] (
    [LZBatchID]       INT            NOT NULL,
    [ADLSBatchID]     INT            NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0)  NOT NULL,
    [pilot_doctor_id] INT            NOT NULL,
    [master_user_id]  INT            NOT NULL,
    [product]         NVARCHAR (256) NOT NULL,
    [create_date]     DATETIME2 (7)  NOT NULL,
    [disable_date]    DATETIME2 (7)  NULL,
    [user_name]       NVARCHAR (50)  NULL,
    [modified_date]   DATETIME2 (7)  NULL,
    [product_status]  INT            NULL,
    [modified_at]     DATETIME2 (7)  NULL,
    [_Region]         VARCHAR (32)   NOT NULL
)
WITH (CLUSTERED INDEX([master_user_id]), DISTRIBUTION = ROUND_ROBIN);

