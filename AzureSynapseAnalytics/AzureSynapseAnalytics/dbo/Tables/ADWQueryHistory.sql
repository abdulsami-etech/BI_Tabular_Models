CREATE TABLE [dbo].[ADWQueryHistory] (
    [request_id]            NVARCHAR (32)   NULL,
    [session_id]            NVARCHAR (32)   NULL,
    [status_s]              NVARCHAR (32)   NULL,
    [submit_time]           DATETIME        NULL,
    [start_time]            DATETIME        NULL,
    [end_compile_time]      DATETIME        NULL,
    [end_time]              DATETIME        NULL,
    [total_elapsed_time]    INT             NULL,
    [label_s]               NVARCHAR (255)  NULL,
    [error_id]              NVARCHAR (36)   NULL,
    [database_id]           INT             NULL,
    [command]               NVARCHAR (4000) NULL,
    [resource_class]        NVARCHAR (20)   NULL,
    [importance]            NVARCHAR (128)  NULL,
    [group_name]            [sysname]       NULL,
    [classifier_name]       [sysname]       NULL,
    [client_correlation_id] NVARCHAR (255)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

