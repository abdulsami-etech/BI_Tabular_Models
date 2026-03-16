CREATE TABLE [Custom].[MESTechnicianTeamShift] (
    [TeamName]     VARCHAR (100) NULL,
    [MorningShift] BIT           NULL,
    [EveningShift] BIT           NULL
)
WITH (CLUSTERED INDEX([TeamName]), DISTRIBUTION = REPLICATE);

