CREATE TABLE [SrcMESCorp].[APP_USER] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [user_key]             BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [user_name]            NVARCHAR (64)  NOT NULL,
    [first_name]           NVARCHAR (64)  NULL,
    [last_name]            NVARCHAR (64)  NULL,
    [description]          NVARCHAR (255) NULL,
    [category]             NVARCHAR (50)  NULL,
    [status]               NVARCHAR (50)  NOT NULL,
    [status_change_time]   DATETIME       NOT NULL,
    [user_expiration]      DATETIME       NULL,
    [password_expiration]  DATETIME       NULL,
    [creation_time]        DATETIME       NOT NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [login_count]          INT            NULL,
    [email_address]        NVARCHAR (255) NULL,
    [status_change_time_u] DATETIME       NULL,
    [status_change_time_z] NVARCHAR (64)  NULL,
    [user_expiration_u]    DATETIME       NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

