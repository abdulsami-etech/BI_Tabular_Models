CREATE TABLE [SrcIDS].[login_log] (
    [LZBatchID]         INT            NOT NULL,
    [ADLSBatchID]       INT            NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)  NOT NULL,
    [id]                BIGINT         NOT NULL,
    [log]               NVARCHAR (MAX) NULL,
    [modified_datetime] DATETIME2 (7)  NOT NULL,
    [_Region]           VARCHAR (32)   NOT NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

