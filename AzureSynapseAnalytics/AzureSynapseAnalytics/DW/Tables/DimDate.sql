CREATE TABLE [DW].[DimDate] (
    [SKDate]            INT          NOT NULL,
    [KeyDate]           DATE         NULL,
    [Date]              VARCHAR (10) NOT NULL,
    [CalendarDay]       TINYINT      NULL,
    [CalendarMonth]     TINYINT      NULL,
    [CalendarQuarter]   TINYINT      NULL,
    [CalendarYear]      SMALLINT     NULL,
    [DayNameLong]       VARCHAR (50) NULL,
    [DayNameShort]      VARCHAR (3)  NULL,
    [DayNumberOfWeek]   SMALLINT     NULL,
    [DayNumberOfYear]   INT          NULL,
    [DaySuffix]         VARCHAR (5)  NULL,
    [FiscalWeek]        TINYINT      NULL,
    [FiscalMonth]       TINYINT      NULL,
    [FiscalQuarter]     TINYINT      NULL,
    [FiscalYear]        SMALLINT     NULL,
    [FirstDayOfMonth]   DATETIME     NULL,
    [FirstDayOfQuarter] DATETIME     NULL,
    [FirstDayOfWeek]    DATETIME     NULL,
    [FirstDayOfYear]    DATETIME     NULL,
    [HolidayName]       VARCHAR (50) NULL,
    [IsHoliday]         BIT          NULL,
    [IsLastDayOfMonth]  BIT          NULL,
    [IsWeekday]         BIT          NULL,
    [LastDayOfMonth]    DATETIME     NULL,
    [LastDayOfQuarter]  DATETIME     NULL,
    [LastDayOfWeek]     DATETIME     NULL,
    [LastDayOfYear]     DATETIME     NULL,
    [MonthNameLong]     VARCHAR (50) NULL,
    [MonthNameShort]    VARCHAR (3)  NULL,
    [MonthYear]         CHAR (7)     NULL,
    [QuarterNameLong]   VARCHAR (50) NULL,
    [QuarterNameShort]  VARCHAR (50) NULL,
    [WeekOfMonth]       TINYINT      NULL,
    [WeekOfYear]        TINYINT      NULL
)
WITH (CLUSTERED INDEX([SKDate]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_DimDate_KeyDate]
    ON [DW].[DimDate]([KeyDate] ASC);

