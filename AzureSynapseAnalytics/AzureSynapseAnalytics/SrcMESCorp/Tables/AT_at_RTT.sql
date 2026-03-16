CREATE TABLE [SrcMESCorp].[AT_at_RTT] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [atr_key]              BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [atr_name]             NVARCHAR (64)  NOT NULL,
    [purge_status]         INT            NULL,
    [creation_time]        DATETIME       NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time]   DATETIME       NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [description_S]        NVARCHAR (128) NULL,
    [new_logic_Y]          TINYINT        NULL,
    [preferred_tech_Y]     TINYINT        NULL,
    [region_S]             NVARCHAR (64)  NULL,
    [skill_level_Y]        TINYINT        NULL,
    [ccmod_category_Y]     TINYINT        NULL,
    [ccmod_mandatory_Y]    TINYINT        NULL,
    [ccmod_user_name_S]    NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

