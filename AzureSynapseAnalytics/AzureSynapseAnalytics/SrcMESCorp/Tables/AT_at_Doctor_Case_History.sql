CREATE TABLE [SrcMESCorp].[AT_at_Doctor_Case_History] (
    [LZBatchID]                 INT            NOT NULL,
    [ADLSBatchID]               INT            NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0)  NOT NULL,
    [atr_key]                   BIGINT         NOT NULL,
    [site_num]                  INT            NOT NULL,
    [atr_name]                  NVARCHAR (64)  NULL,
    [creation_time]             DATETIME       NULL,
    [ClinicianID_S]             NVARCHAR (80)  NULL,
    [DoctorID_S]                NVARCHAR (80)  NULL,
    [JDE_Order_Date_T]          DATETIME       NULL,
    [JDE_Ship_Date_T]           DATETIME       NULL,
    [lot_name_S]                NVARCHAR (128) NULL,
    [MES_Order_Creation_Date_T] DATETIME       NULL,
    [Order_number_S]            NVARCHAR (64)  NULL,
    [part_number_S]             NVARCHAR (64)  NULL,
    [last_modified_time]        DATETIME       NULL,
    [creation_time_u]           DATETIME       NULL,
    [creation_time_z]           NVARCHAR (64)  NULL,
    [JDE_Ship_Date_u]           DATETIME       NULL,
    [JDE_Ship_Date_z]           NVARCHAR (64)  NULL,
    [last_modified_time_u]      DATETIME       NULL,
    [last_modified_time_z]      NVARCHAR (64)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

