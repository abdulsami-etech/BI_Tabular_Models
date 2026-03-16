CREATE TABLE [SrcMESCorp].[AT_AT_PilotSupport] (
    [LZBatchID]                  INT            NOT NULL,
    [ADLSBatchID]                INT            NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0)  NOT NULL,
    [atr_key]                    BIGINT         NOT NULL,
    [site_num]                   INT            NOT NULL,
    [atr_name]                   NVARCHAR (64)  NOT NULL,
    [creation_time]              DATETIME       NULL,
    [creation_time_u]            DATETIME       NULL,
    [creation_time_z]            NVARCHAR (64)  NULL,
    [last_modified_time]         DATETIME       NULL,
    [last_modified_time_u]       DATETIME       NULL,
    [last_modified_time_z]       NVARCHAR (64)  NULL,
    [description_S]              NVARCHAR (250) NULL,
    [fab_checklist_8]            BIGINT         NULL,
    [fab_cluster_S]              NVARCHAR (50)  NULL,
    [fab_instruction_S]          NVARCHAR (250) NULL,
    [ids_id_S]                   NVARCHAR (10)  NULL,
    [label_bag_S]                NVARCHAR (100) NULL,
    [label_box_S]                NVARCHAR (100) NULL,
    [name_S]                     NVARCHAR (100) NULL,
    [pilot_status_Y]             TINYINT        NULL,
    [treat_additional_process_Y] TINYINT        NULL,
    [treat_instruction_S]        NVARCHAR (250) NULL,
    [user_name_S]                NVARCHAR (80)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

