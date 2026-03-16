CREATE TABLE [SrcIDS].[tblCnAccounts] (
    [LZBatchID]               INT           NOT NULL,
    [ADLSBatchID]             INT           NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0) NOT NULL,
    [master_user_id]          INT           NOT NULL,
    [user_name]               NVARCHAR (50) NULL,
    [password]                NVARCHAR (50) NULL,
    [disabled]                DATETIME2 (7) NULL,
    [login_email]             NVARCHAR (50) NULL,
    [login_name]              NVARCHAR (50) NULL,
    [contact_sfid]            NVARCHAR (18) NULL,
    [login_type]              INT           NOT NULL,
    [identity_server_user_id] NVARCHAR (36) NULL,
    [_Region]                 VARCHAR (32)  NOT NULL
)
WITH (CLUSTERED INDEX([master_user_id]), DISTRIBUTION = HASH([master_user_id]));

