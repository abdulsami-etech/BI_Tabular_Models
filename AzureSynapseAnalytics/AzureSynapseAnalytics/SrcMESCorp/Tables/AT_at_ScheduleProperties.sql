CREATE TABLE [SrcMESCorp].[AT_at_ScheduleProperties] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [atr_key]              BIGINT        NOT NULL,
    [site_num]             INT           NOT NULL,
    [atr_name]             NVARCHAR (64) NULL,
    [purge_status]         INT           NULL,
    [creation_time]        DATETIME      NULL,
    [trx_id]               CHAR (38)     NOT NULL,
    [EndTime_S]            NVARCHAR (80) NULL,
    [ScheduleName_S]       NVARCHAR (80) NULL,
    [StartTime_S]          NVARCHAR (80) NULL,
    [WeekDay_S]            NVARCHAR (80) NULL,
    [last_modified_time]   DATETIME      NULL,
    [creation_time_u]      DATETIME      NULL,
    [creation_time_z]      NVARCHAR (64) NULL,
    [last_modified_time_u] DATETIME      NULL,
    [last_modified_time_z] NVARCHAR (64) NULL,
    [parent_key]           BIGINT        NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

