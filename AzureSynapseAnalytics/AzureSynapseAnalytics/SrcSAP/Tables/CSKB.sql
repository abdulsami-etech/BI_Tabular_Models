CREATE TABLE [SrcSAP].[CSKB] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [KOKRS]         NVARCHAR (4)  NOT NULL,
    [KSTAR]         NVARCHAR (10) NOT NULL,
    [DATBI]         NVARCHAR (8)  NOT NULL,
    [DATAB]         NVARCHAR (8)  NOT NULL,
    [KATYP]         NVARCHAR (2)  NOT NULL,
    [ERSDA]         NVARCHAR (8)  NOT NULL,
    [USNAM]         NVARCHAR (12) NOT NULL,
    [EIGEN]         NVARCHAR (8)  NOT NULL,
    [PLAZU]         NVARCHAR (1)  NOT NULL,
    [PLAOR]         NVARCHAR (1)  NOT NULL,
    [PLAUS]         NVARCHAR (2)  NOT NULL,
    [KOSTL]         NVARCHAR (10) NOT NULL,
    [AUFNR]         NVARCHAR (12) NOT NULL,
    [MGEFL]         NVARCHAR (1)  NOT NULL,
    [MSEHI]         NVARCHAR (3)  NOT NULL,
    [DEAKT]         NVARCHAR (1)  NOT NULL,
    [LOEVM]         NVARCHAR (1)  NOT NULL,
    [RECID]         NVARCHAR (2)  NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [KOKRS], [KSTAR], [DATBI]), DISTRIBUTION = HASH([KSTAR]));

