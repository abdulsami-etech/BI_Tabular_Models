CREATE TABLE [SrcINST].[Session_Ext] (
    [LZBatchID]     INT              NOT NULL,
    [ADLSBatchID]   INT              NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)    NOT NULL,
    [session_id]    UNIQUEIDENTIFIER NOT NULL,
    [name]          VARCHAR (255)    NOT NULL,
    [value]         VARCHAR (4000)   NOT NULL,
    [BatchID]       INT              NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([session_id]));

