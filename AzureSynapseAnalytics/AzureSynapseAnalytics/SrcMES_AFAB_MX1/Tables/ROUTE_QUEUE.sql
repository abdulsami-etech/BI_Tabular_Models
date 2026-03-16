CREATE TABLE [SrcMES_AFAB_MX1].[ROUTE_QUEUE] (
    [LZBatchID]                  INT           NOT NULL,
    [ADLSBatchID]                INT           NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0) NOT NULL,
    [queue_key]                  BIGINT        NOT NULL,
    [site_num]                   INT           NOT NULL,
    [route_key]                  BIGINT        NOT NULL,
    [queue_name]                 NVARCHAR (64) NOT NULL,
    [queue_duration]             INT           NULL,
    [est_duration_to_completion] INT           NULL,
    [capacity]                   INT           NULL,
    [xfr_insert_pid]             INT           NULL,
    [xfr_update_pid]             INT           NULL,
    [queue_type]                 INT           NOT NULL,
    [pixel_x]                    INT           NULL,
    [pixel_y]                    INT           NULL,
    [p_queue_assigned]           INT           NULL,
    [trx_id]                     CHAR (38)     NOT NULL,
    [last_modified_time]         DATETIME      NOT NULL,
    [auto_start]                 INT           NULL,
    [last_modified_time_u]       DATETIME      NULL,
    [last_modified_time_z]       NVARCHAR (64) NULL,
    [pd_xfr_update_pid]          INT           NOT NULL,
    [src_xfr_update_pid]         INT           NOT NULL,
    [purged]                     INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

