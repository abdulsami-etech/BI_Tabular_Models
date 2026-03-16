CREATE TABLE [SrcSAP].[TPAR] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [PARVW]         NVARCHAR (2)  NOT NULL,
    [STEIN]         NVARCHAR (1)  NOT NULL,
    [UPARV]         NVARCHAR (2)  NOT NULL,
    [FEHGR]         NVARCHAR (2)  NOT NULL,
    [ERNAM]         NVARCHAR (12) NOT NULL,
    [NRART]         NVARCHAR (2)  NOT NULL,
    [HITYP]         NVARCHAR (1)  NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [PARVW]), DISTRIBUTION = HASH([PARVW]));

