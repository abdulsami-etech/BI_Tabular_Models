CREATE PROC [DW].[LoadDimDate] @Start_Date [DATETIME],@End_Date [DATETIME] AS
begin

	IF OBJECT_ID('tempdb..#dates') IS NOT NULL
		DROP TABLE #dates

	;WITH dates (date_value, rownum) AS
	(
		SELECT 
			DATEADD(dd, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1, @Start_Date)
			, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
		FROM sys.all_columns a
		CROSS JOIN sys.all_columns b
	)
	select 
		CAST(convert(varchar(8), date_value, 112) AS INT) as [SKDate],
		convert(date, date_value) as KeyDate,
		convert(varchar(10), date_value, 120) AS [Date],
		datepart(dd, date_value) as CalendarDay,
		datepart(mm, date_value) as CalendarMonth,
		datepart(qq, date_value) as CalendarQuarter,
		datepart(yy, date_value) AS CalendarYear,
		datename(dw, date_value) AS DayNameLong,
		cast(datename(dw, date_value) as varchar(3)) as DayNameShort,
		datepart(dw, date_value) AS DayNumberOfWeek,
		datepart(dy, date_value) AS DayNumberOfYear,
		datename(dd, date_value) +
			CASE
				WHEN datepart(dd, date_value) % 100 IN (11,12,13) THEN 'th'
				WHEN datepart(dd, date_value) % 10 = 1 THEN 'st'
				WHEN datepart(dd, date_value) % 10 = 2 THEN 'nd'
				WHEN datepart(dd, date_value) % 10 = 3 THEN 'rd'
				ELSE 'th'
			END AS DaySuffix,
		NULL AS FiscalWeek,
		NULL AS FiscalMonth,
		NULL AS FiscalQuarter,
		NULL AS FiscalYear,
		DATEADD(month, DATEDIFF(month, 0, date_value), 0) AS FirstDayOfMonth,
		DATEADD(qq, DATEDIFF(qq, 0, date_value), 0) AS FirstDayOfQuarter,
		DATEADD(wk, DATEDIFF(wk, 0, date_value), 0) AS FirstDayOfWeek,
		DATEADD(yy, DATEDIFF(yy, 0, date_value), 0) AS FirstDayOfYear,
		CASE WHEN datepart(dy, date_value) = 1 THEN 'New Year''s Day' ELSE NULL END HolidayName,
		CASE WHEN datepart(dy, date_value) = 1 THEN 1 ELSE 0 END IsHoliday,
		CASE WHEN date_Value = DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, date_value) + 1, 0)) THEN 1 ELSE 0 END AS IsLastDayOfMonth,
		CASE WHEN datepart(dw, date_value) BETWEEN 2 AND 6 THEN 1 ELSE 0 END IsWeekday,
		DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, date_value) + 1, 0)) AS LastDayOfMonth,
		DATEADD(d, -1, DATEADD(qq, DATEDIFF(qq, 0, date_value) + 1, 0))LastDayOfQuarter,
		DATEADD(d, -1, DATEADD(dw, DATEDIFF(dw, 0, date_value) + 1, 0))LastDayOfWeek,
		DATEADD(d, -1, DATEADD(yy, DATEDIFF(yy, 0, date_value) + 1, 0))LastDayOfYear,
		datename(mm, date_value) AS MonthNameLong,
		cast(datename(mm, date_value) as varchar(3)) AS MonthNameShort,
		right('00' + convert(varchar(2),month(date_value)),2) + '-' + datename(yyyy, date_value) AS MonthYear,
		'Quarter ' + datename(qq, date_value) AS QuarterNameLong,
		'Q' + datename(qq, date_value) AS QuarterNameShort,
		datepart(day, datediff(day, 0, date_value)/7 * 7)/7 + 1 AS WeekOfMonth,
		datepart(wk, date_value) AS WeekOfYear
	INTO #dates
	FROM dates
	WHERE rownum <= DATEDIFF(dd, @Start_Date, @End_Date)

	TRUNCATE TABLE [DW].[DimDate];

	INSERT INTO [DW].[DimDate] (
		[SKDate],
		KeyDate,
		[Date],
		CalendarDay,
		CalendarMonth,
		CalendarQuarter,
		CalendarYear,
		DayNameLong,
		DayNameShort,
		DayNumberOfWeek,
		DayNumberOfYear,
		DaySuffix,
		FiscalWeek,
		FiscalMonth,
		FiscalQuarter,
		FiscalYear,
		FirstDayOfMonth,
		FirstDayOfQuarter,
		FirstDayOfWeek,
		FirstDayOfYear,
		HolidayName,
		IsHoliday,
		IsLastDayOfMonth,
		IsWeekday,
		LastDayOfMonth,
		LastDayOfQuarter,
		LastDayOfWeek,
		LastDayOfYear,
		MonthNameLong,
		MonthNameShort,
		MonthYear,
		QuarterNameLong,
		QuarterNameShort,
		WeekOfMonth,
		WeekOfYear
	)
	SELECT -1 as [SKDate],
		NULL as KeyDate,
		'NA' AS [Date],
		NULL as CalendarDay,
		NULL as CalendarMonth,
		NULL as CalendarQuarter,
		NULL AS CalendarYear,
		'NA' AS DayNameLong,
		'NA' as DayNameShort,
		NULL AS DayNumberOfWeek,
		NULL AS DayNumberOfYear,
		'NA' AS DaySuffix,
		NULL AS FiscalWeek,
		NULL AS FiscalMonth,
		NULL AS FiscalQuarter,
		NULL AS FiscalYear,
		NULL AS FirstDayOfMonth,
		NULL AS FirstDayOfQuarter,
		NULL AS FirstDayOfWeek,
		NULL AS FirstDayOfYear,
		NULL AS HolidayName,
		NULL AS IsHoliday,
		NULL AS IsLastDayOfMonth,
		NULL AS IsWeekday,
		NULL AS LastDayOfMonth,
		NULL AS LastDayOfQuarter,
		NULL AS LastDayOfWeek,
		NULL AS LastDayOfYear,
		'NA' AS MonthNameLong,
		'NA' AS MonthNameShort,
		'NA' AS MonthYear,
		'NA' AS QuarterNameLong,
		'NA' AS QuarterNameShort,
		NULL AS WeekOfMonth,
		NULL AS WeekOfYear

	union all

	SELECT 
		[SKDate],
		KeyDate,
		[Date],
		CalendarDay,
		CalendarMonth,
		CalendarQuarter,
		CalendarYear,
		DayNameLong,
		DayNameShort,
		DayNumberOfWeek,
		DayNumberOfYear,
		DaySuffix,
		FiscalWeek,
		FiscalMonth,
		FiscalQuarter,
		FiscalYear,
		FirstDayOfMonth,
		FirstDayOfQuarter,
		FirstDayOfWeek,
		FirstDayOfYear,
		HolidayName,
		IsHoliday,
		IsLastDayOfMonth,
		IsWeekday,
		LastDayOfMonth,
		LastDayOfQuarter,
		LastDayOfWeek,
		LastDayOfYear,
		MonthNameLong,
		MonthNameShort,
		MonthYear,
		QuarterNameLong,
		QuarterNameShort,
		WeekOfMonth,
		WeekOfYear	
	FROM #dates

end
