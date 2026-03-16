CREATE TABLE [CTRL].[DynamicQueryLog] (
    [SessionID]    UNIQUEIDENTIFIER NOT NULL,
    [SQLQuery]     NVARCHAR (MAX)   NOT NULL,
    [DateInserted] DATETIME2 (3)    NOT NULL
)
WITH (HEAP, DISTRIBUTION = HASH([SessionID]));

