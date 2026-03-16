CREATE TABLE [DWTOPS].[FactKPIGoals] (
    [SKDate]            INT          NOT NULL,
    [Date]              DATE         NULL,
    [KeyPlant]          VARCHAR (64) NULL,
    [GroupRegion]       VARCHAR (64) NULL,
    [MetricDescription] VARCHAR (64) NULL,
    [Value]             FLOAT (53)   NULL
)
WITH (CLUSTERED INDEX([SKDate]), DISTRIBUTION = REPLICATE);

