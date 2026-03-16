CREATE TABLE [SrcSAP].[CSSL] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [MANDT]         NVARCHAR (3)   NOT NULL,
    [KOKRS]         NVARCHAR (4)   NOT NULL,
    [KOSTL]         NVARCHAR (10)  NOT NULL,
    [LSTAR]         NVARCHAR (6)   NOT NULL,
    [GJAHR]         NVARCHAR (4)   NOT NULL,
    [CCKEY]         NVARCHAR (23)  NOT NULL,
    [LATYP]         NVARCHAR (1)   NOT NULL,
    [LEINH]         NVARCHAR (3)   NOT NULL,
    [AUSFK]         DECIMAL (5, 2) NOT NULL,
    [AUSEH]         NVARCHAR (3)   NOT NULL,
    [OBJNR]         NVARCHAR (22)  NOT NULL,
    [LATYPI]        NVARCHAR (1)   NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [KOKRS], [KOSTL], [LSTAR], [GJAHR]), DISTRIBUTION = HASH([KOKRS]));

