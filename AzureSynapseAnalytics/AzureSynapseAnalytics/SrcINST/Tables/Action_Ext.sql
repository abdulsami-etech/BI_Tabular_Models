CREATE TABLE [SrcINST].[Action_Ext] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [action_id]     BIGINT         NOT NULL,
    [name]          NVARCHAR (255) NOT NULL,
    [value]         VARCHAR (255)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([action_id]));

