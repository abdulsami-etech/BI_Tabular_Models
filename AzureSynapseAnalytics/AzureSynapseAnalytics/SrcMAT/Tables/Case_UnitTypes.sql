CREATE TABLE [SrcMAT].[Case_UnitTypes] (
    [LZBatchID]                  INT           NOT NULL,
    [ADLSBatchID]                INT           NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0) NOT NULL,
    [UnitTypeID]                 INT           NOT NULL,
    [UnitTypeGenericDescription] VARCHAR (50)  NOT NULL,
    [ItemCode]                   VARCHAR (50)  NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

