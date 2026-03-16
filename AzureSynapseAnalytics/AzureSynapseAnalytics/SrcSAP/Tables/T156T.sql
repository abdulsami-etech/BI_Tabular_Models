CREATE TABLE [SrcSAP].[T156T] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [SPRAS]         NVARCHAR (1)  NOT NULL,
    [BWART]         NVARCHAR (3)  NOT NULL,
    [SOBKZ]         NVARCHAR (1)  NOT NULL,
    [KZBEW]         NVARCHAR (1)  NOT NULL,
    [KZZUG]         NVARCHAR (1)  NOT NULL,
    [KZVBR]         NVARCHAR (1)  NOT NULL,
    [BTEXT]         NVARCHAR (20) NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [BWART]), DISTRIBUTION = HASH([BWART]));

