CREATE TABLE [SrcSAPFile].[CostElementHier] (
    [LZBatchID]       INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [Level1]          NVARCHAR (60) NOT NULL,
    [Level2]          NVARCHAR (60) NULL,
    [Level2Sort]      NVARCHAR (2)  NULL,
    [Level3]          NVARCHAR (60) NULL,
    [Level3Sort]      NVARCHAR (2)  NULL,
    [Level4]          NVARCHAR (60) NULL,
    [Level4Sort]      NVARCHAR (2)  NULL,
    [Level5]          NVARCHAR (60) NULL,
    [Level5Sort]      NVARCHAR (2)  NULL,
    [Level6]          NVARCHAR (60) NULL,
    [Level6Sort]      NVARCHAR (2)  NULL,
    [Level7]          NVARCHAR (60) NULL,
    [Level7Sort]      NVARCHAR (2)  NULL,
    [Level8]          NVARCHAR (60) NULL,
    [Level8Sort]      NVARCHAR (2)  NULL,
    [Object]          NVARCHAR (18) NULL,
    [Controllingarea] NVARCHAR (4)  NULL,
    [CostElement]     NVARCHAR (18) NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

