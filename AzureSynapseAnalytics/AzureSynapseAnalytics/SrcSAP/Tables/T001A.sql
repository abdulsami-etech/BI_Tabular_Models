CREATE TABLE [SrcSAP].[T001A] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [BUKRS]         NVARCHAR (4)  NOT NULL,
    [CURTP]         NVARCHAR (2)  NOT NULL,
    [KURST]         NVARCHAR (4)  NOT NULL,
    [CURSR]         NVARCHAR (1)  NOT NULL,
    [CURDT]         NVARCHAR (1)  NOT NULL,
    [CURTP2]        NVARCHAR (2)  NOT NULL,
    [KURST2]        NVARCHAR (4)  NOT NULL,
    [CURSR2]        NVARCHAR (1)  NOT NULL,
    [CURDT2]        NVARCHAR (1)  NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [BUKRS]), DISTRIBUTION = HASH([BUKRS]));

