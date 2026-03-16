CREATE TABLE [Custom].[MMD_NASalesCurrentQuarter] (
    [NASalesCurrentQuarterEndDateKey] DATE NOT NULL,
    CONSTRAINT [PK_NASalesCurrentQuarterEndDateIDX] PRIMARY KEY NONCLUSTERED ([NASalesCurrentQuarterEndDateKey] ASC) NOT ENFORCED
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

