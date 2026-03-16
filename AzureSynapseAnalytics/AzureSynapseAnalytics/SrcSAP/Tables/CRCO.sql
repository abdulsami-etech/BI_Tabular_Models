CREATE TABLE [SrcSAP].[CRCO] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [OBJTY]         NVARCHAR (2)  NOT NULL,
    [OBJID]         NVARCHAR (8)  NOT NULL,
    [LASET]         NVARCHAR (6)  NOT NULL,
    [ENDDA]         NVARCHAR (8)  NOT NULL,
    [LANUM]         NVARCHAR (4)  NOT NULL,
    [BEGDA]         NVARCHAR (8)  NOT NULL,
    [AEDAT_KOST]    NVARCHAR (8)  NOT NULL,
    [AENAM_KOST]    NVARCHAR (12) NOT NULL,
    [KOKRS]         NVARCHAR (4)  NOT NULL,
    [KOSTL]         NVARCHAR (10) NOT NULL,
    [LSTAR]         NVARCHAR (6)  NOT NULL,
    [LSTAR_REF]     NVARCHAR (1)  NOT NULL,
    [FORML]         NVARCHAR (6)  NOT NULL,
    [PRZ]           NVARCHAR (12) NOT NULL,
    [ACTXY]         NVARCHAR (1)  NOT NULL,
    [ACTXK]         NVARCHAR (4)  NOT NULL,
    [LEINH]         NVARCHAR (3)  NOT NULL,
    [BDE]           NVARCHAR (1)  NOT NULL,
    [SAKL]          NVARCHAR (1)  NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [OBJTY], [OBJID], [LASET], [ENDDA], [LANUM]), DISTRIBUTION = HASH([OBJID]));

