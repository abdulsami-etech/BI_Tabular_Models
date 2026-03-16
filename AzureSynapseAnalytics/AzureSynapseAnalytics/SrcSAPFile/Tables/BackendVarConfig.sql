CREATE TABLE [SrcSAPFile].[BackendVarConfig] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [MANDT]         NVARCHAR (3)   NOT NULL,
    [NAME]          NVARCHAR (30)  NOT NULL,
    [TYPE]          NVARCHAR (1)   NOT NULL,
    [NUMB]          NVARCHAR (4)   NOT NULL,
    [SIGN]          NVARCHAR (1)   NULL,
    [OPTI]          NVARCHAR (2)   NULL,
    [LOW]           NVARCHAR (45)  NULL,
    [HIGH]          NVARCHAR (45)  NULL,
    [STREAM]        NVARCHAR (3)   NULL,
    [PURPOSE]       NVARCHAR (100) NULL,
    [TSTPNM]        NVARCHAR (12)  NULL,
    [TIMESTMP]      NVARCHAR (15)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

