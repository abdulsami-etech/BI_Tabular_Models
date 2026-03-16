CREATE TABLE [SrcSAP].[SKA1] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [KTOPL]         NVARCHAR (4)  NOT NULL,
    [SAKNR]         NVARCHAR (10) NOT NULL,
    [XBILK]         NVARCHAR (1)  NOT NULL,
    [SAKAN]         NVARCHAR (10) NOT NULL,
    [BILKT]         NVARCHAR (10) NOT NULL,
    [ERDAT]         NVARCHAR (8)  NOT NULL,
    [ERNAM]         NVARCHAR (12) NOT NULL,
    [GVTYP]         NVARCHAR (2)  NOT NULL,
    [KTOKS]         NVARCHAR (4)  NOT NULL,
    [MUSTR]         NVARCHAR (10) NOT NULL,
    [VBUND]         NVARCHAR (6)  NOT NULL,
    [XLOEV]         NVARCHAR (1)  NOT NULL,
    [XSPEA]         NVARCHAR (1)  NOT NULL,
    [XSPEB]         NVARCHAR (1)  NOT NULL,
    [XSPEP]         NVARCHAR (1)  NOT NULL,
    [MCOD1]         NVARCHAR (25) NOT NULL,
    [FUNC_AREA]     NVARCHAR (16) NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [KTOPL], [SAKNR]), DISTRIBUTION = HASH([SAKNR]));

