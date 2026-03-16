CREATE TABLE [SrcINST].[Action] (
    [LZBatchID]       INT             NOT NULL,
    [ADLSBatchID]     INT             NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0)   NOT NULL,
    [session_id]      VARCHAR (36)    NOT NULL,
    [action_datetime] DATETIME        NOT NULL,
    [action_id]       BIGINT          NOT NULL,
    [type]            VARCHAR (255)   NOT NULL,
    [id]              NVARCHAR (255)  NULL,
    [parent_id]       NVARCHAR (255)  NULL,
    [name]            NVARCHAR (2048) NULL,
    [value]           INT             NULL,
    [state]           NVARCHAR (2500) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([action_id]));

