CREATE TABLE [SrcSAP].[CSLT] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [SPRAS]         NVARCHAR (1)  NOT NULL,
    [KOKRS]         NVARCHAR (4)  NOT NULL,
    [LSTAR]         NVARCHAR (6)  NOT NULL,
    [DATBI]         NVARCHAR (8)  NOT NULL,
    [KTEXT]         NVARCHAR (20) NOT NULL,
    [LTEXT]         NVARCHAR (40) NOT NULL,
    [MCTXT]         NVARCHAR (20) NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [SPRAS], [KOKRS], [LSTAR], [DATBI]), DISTRIBUTION = HASH([KOKRS]));

