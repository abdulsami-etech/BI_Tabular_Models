CREATE TABLE [SrcSAP].[TCURF] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [KURST]         NVARCHAR (4)  NOT NULL,
    [FCURR]         NVARCHAR (5)  NOT NULL,
    [TCURR]         NVARCHAR (5)  NOT NULL,
    [GDATU]         NVARCHAR (8)  NOT NULL,
    [FFACT]         DECIMAL (9)   NOT NULL,
    [TFACT]         DECIMAL (9)   NOT NULL,
    [ABWCT]         NVARCHAR (4)  NOT NULL,
    [ABWGA]         NVARCHAR (8)  NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [KURST], [FCURR], [TCURR], [GDATU]), DISTRIBUTION = HASH([KURST]));

