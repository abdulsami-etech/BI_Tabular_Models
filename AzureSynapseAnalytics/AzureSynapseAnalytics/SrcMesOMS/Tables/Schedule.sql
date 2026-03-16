CREATE TABLE [SrcMesOMS].[Schedule] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [scheduleID]         INT           NOT NULL,
    [scheduleName]       VARCHAR (50)  NOT NULL,
    [hasChangeDay]       BIT           NOT NULL,
    [loadProduction]     BIT           NOT NULL,
    [loadProductionDate] DATETIME      NULL,
    [isActive]           BIT           NOT NULL,
    [scheduleNumber]     INT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

