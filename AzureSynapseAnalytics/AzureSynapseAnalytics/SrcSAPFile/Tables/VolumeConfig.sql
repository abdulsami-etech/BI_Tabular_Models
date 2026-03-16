CREATE TABLE [SrcSAPFile].[VolumeConfig] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [MANDT]         NVARCHAR (3)  NOT NULL,
    [NAME]          NVARCHAR (30) NOT NULL,
    [NUMB]          NVARCHAR (4)  NOT NULL,
    [SIGN]          NVARCHAR (1)  NOT NULL,
    [OPTI]          NVARCHAR (2)  NOT NULL,
    [OPERAND1]      NVARCHAR (64) NOT NULL,
    [OPERAND2]      NVARCHAR (64) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

