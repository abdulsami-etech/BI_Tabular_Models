CREATE TABLE [DW].[CaseStateStatisticsAttributes] (
    [SKCaseStateStatistic] INT            IDENTITY (1, 1) NOT NULL,
    [YearNum]              INT            NOT NULL,
    [IsIoscan]             NVARCHAR (10)  NOT NULL,
    [WeekofYear]           INT            NOT NULL,
    [DeliverableType]      NVARCHAR (225) NOT NULL,
    [CountryCode]          NVARCHAR (10)  NOT NULL,
    CONSTRAINT [CaseStateStatisticsAttributes_PK_SKCaseStateStatistic] PRIMARY KEY NONCLUSTERED ([SKCaseStateStatistic] ASC) NOT ENFORCED,
    CONSTRAINT [CaseStateStatisticsAttributes_Unique] UNIQUE NONCLUSTERED ([YearNum] ASC, [IsIoscan] ASC, [WeekofYear] ASC, [CountryCode] ASC, [DeliverableType] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKCaseStateStatistic]), DISTRIBUTION = ROUND_ROBIN);

