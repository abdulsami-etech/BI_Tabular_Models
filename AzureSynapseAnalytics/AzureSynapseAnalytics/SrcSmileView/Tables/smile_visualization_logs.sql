CREATE TABLE [SrcSmileView].[smile_visualization_logs] (
    [LZBatchID]             INT            NOT NULL,
    [ADLSBatchID]           INT            NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)  NOT NULL,
    [id]                    BIGINT         NOT NULL,
    [event_name]            VARCHAR (64)   NULL,
    [session_id]            VARCHAR (128)  NULL,
    [simulation_id]         VARCHAR (128)  NULL,
    [lead_id]               VARCHAR (36)   NULL,
    [reason_code]           VARCHAR (36)   NULL,
    [simulation_start_time] DATETIME       NULL,
    [simulation_end_time]   DATETIME       NULL,
    [country_code]          VARCHAR (36)   NULL,
    [site_id]               VARCHAR (128)  NULL,
    [extra_data]            VARCHAR (4000) NULL,
    [created_at]            DATETIME       NOT NULL,
    [updated_at]            DATETIME       NOT NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

