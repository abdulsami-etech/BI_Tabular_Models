CREATE TABLE [DWIRIS].[DimDateTime] (
    [SKDateTime]             INT          NOT NULL,
    [DWHash]                 CHAR (40)    NOT NULL,
    [KeyDateTime]            DATE         NOT NULL,
    [DateName]               VARCHAR (32) NOT NULL,
    [Year]                   SMALLINT     NOT NULL,
    [YearName]               VARCHAR (32) NOT NULL,
    [MonthStartDate]         DATE         NOT NULL,
    [MonthEndDate]           DATE         NULL,
    [MonthOfYear]            TINYINT      NOT NULL,
    [MonthName]              VARCHAR (32) NOT NULL,
    [MonthNameShort]         VARCHAR (10) NULL,
    [MonthNameNumeric]       VARCHAR (10) NULL,
    [WeekOfYear]             TINYINT      NOT NULL,
    [WeekOfYearName]         VARCHAR (32) NOT NULL,
    [WeekStartDate]          DATE         NULL,
    [WeekEndDate]            DATE         NULL,
    [WeekYear]               INT          NULL,
    [WeekOfQuarter]          INT          NULL,
    [WeekOfQuarterName]      VARCHAR (32) NULL,
    [DayOfWeek]              TINYINT      NOT NULL,
    [DayOfWeekName]          VARCHAR (32) NOT NULL,
    [DayOfMonth]             TINYINT      NOT NULL,
    [DayOfQuarter]           TINYINT      NOT NULL,
    [DayOfYear]              SMALLINT     NOT NULL,
    [QuarterStartDate]       DATE         NULL,
    [QuarterEndDate]         DATE         NULL,
    [QuarterOfYear]          TINYINT      NOT NULL,
    [QuarterName]            VARCHAR (32) NOT NULL,
    [QuarterNameShort]       VARCHAR (32) NOT NULL,
    [FiscalQuarterNameShort] VARCHAR (32) NULL,
    [FiscalYear]             INT          NULL,
    [HalfYearName]           VARCHAR (9)  NOT NULL,
    [IsWorkday]              BIT          NOT NULL,
    [IsWorkdayName]          VARCHAR (32) NOT NULL,
    [DayType]                VARCHAR (50) NULL,
    [WeekType]               VARCHAR (50) NULL,
    [MonthType]              VARCHAR (50) NULL,
    [QuarterType]            VARCHAR (50) NULL,
    [YearType]               VARCHAR (50) NULL
)
WITH (CLUSTERED INDEX([SKDateTime]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_DimDateTime_KeyTime]
    ON [DWIRIS].[DimDateTime]([KeyDateTime] ASC);

