CREATE TABLE [SrcSAP].[T138V] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [VERSI]         NVARCHAR (2)  NOT NULL,
    [PSTAT]         NVARCHAR (15) NOT NULL,
    [ANZZL]         DECIMAL (2)   NOT NULL,
    [KZLEE]         NVARCHAR (1)  NOT NULL,
    [KZEIN]         NVARCHAR (1)  NOT NULL,
    [KZALL]         NVARCHAR (1)  NOT NULL
)
WITH (CLUSTERED INDEX([VERSI]), DISTRIBUTION = HASH([VERSI]));

