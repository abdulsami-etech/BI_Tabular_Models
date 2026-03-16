CREATE TABLE [SrcMAT].[Wand] (
    [LZBatchID]       INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [EquipmentCardID] INT           NOT NULL,
    [Model]           NVARCHAR (50) NOT NULL,
    [MESCompleteTime] DATETIME      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

