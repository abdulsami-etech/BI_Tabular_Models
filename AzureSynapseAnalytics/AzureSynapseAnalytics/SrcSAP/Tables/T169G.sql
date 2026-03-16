CREATE TABLE [SrcSAP].[T169G] (
    [LZBatchID]     INT             NOT NULL,
    [ADLSBatchID]   INT             NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)   NOT NULL,
    [MANDT]         NVARCHAR (3)    NOT NULL,
    [BUKRS]         NVARCHAR (4)    NOT NULL,
    [TOLSL]         NVARCHAR (2)    NOT NULL,
    [WERT1]         DECIMAL (13, 2) NOT NULL,
    [XW1JA]         NVARCHAR (1)    NOT NULL,
    [XW1NE]         NVARCHAR (1)    NOT NULL,
    [WERT2]         DECIMAL (13, 2) NOT NULL,
    [XW2JA]         NVARCHAR (1)    NOT NULL,
    [XW2NE]         NVARCHAR (1)    NOT NULL,
    [PROZ1]         DECIMAL (4, 2)  NOT NULL,
    [XP1JA]         NVARCHAR (1)    NOT NULL,
    [XP1NE]         NVARCHAR (1)    NOT NULL,
    [PROZ2]         DECIMAL (4, 2)  NOT NULL,
    [XP2JA]         NVARCHAR (1)    NOT NULL,
    [XP2NE]         NVARCHAR (1)    NOT NULL,
    [WAERS]         NVARCHAR (5)    NOT NULL
)
WITH (CLUSTERED INDEX([MANDT], [BUKRS], [TOLSL]), DISTRIBUTION = HASH([BUKRS]));

