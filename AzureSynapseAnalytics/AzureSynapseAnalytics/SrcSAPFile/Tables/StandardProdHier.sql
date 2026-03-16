CREATE TABLE [SrcSAPFile].[StandardProdHier] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [NODEID]        NVARCHAR (8)   NOT NULL,
    [IOBJNM]        NVARCHAR (30)  NOT NULL,
    [NODENAME]      VARCHAR (1333) NOT NULL,
    [TLEVEL]        VARCHAR (2)    NOT NULL,
    [LINK]          VARCHAR (1)    NULL,
    [PARENTID]      VARCHAR (8)    NOT NULL,
    [CHILDID]       VARCHAR (8)    NOT NULL,
    [NEXTID]        VARCHAR (8)    NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

