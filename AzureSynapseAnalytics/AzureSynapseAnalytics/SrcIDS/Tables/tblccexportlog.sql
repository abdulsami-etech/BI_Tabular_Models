CREATE TABLE [SrcIDS].[tblccexportlog] (
    [LZBatchID]               INT                                      NOT NULL,
    [ADLSBatchID]             INT                                      NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)                            NOT NULL,
    [export_id]               INT                                      NOT NULL,
    [master_user_id]          INT                                      NOT NULL,
    [vip_patient_id]          INT                                      NOT NULL,
    [export_date]             DATETIME2 (7)                            NOT NULL,
    [response_date]           DATETIME2 (7)                            NULL,
    [cc_state]                INT                                      NOT NULL,
    [original_full_file_name] NVARCHAR (128)                           NULL,
    [exported_filename]       NVARCHAR (128)                           NULL,
    [translation_required]    BIT                                      NULL,
    [conf_num]                NVARCHAR (64)                            NULL,
    [original_file_version]   NVARCHAR (50)                            NULL,
    [original_file_name]      NVARCHAR (128)                           NULL,
    [modified_at]             DATETIME2 (7)                            NOT NULL,
    [_Region]                 VARCHAR (32)                             NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([export_id]));

