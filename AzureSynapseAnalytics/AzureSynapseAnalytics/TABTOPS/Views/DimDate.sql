CREATE VIEW [TABTOPS].[DimDate] AS select	SKDate
	,	Date
	,	KeyDate
	,	CalendarDay
	,	CalendarMonth
	,	CalendarQuarter
	,	CalendarYear
	,	WeekOfYear
	,   CASE WHEN WeekOfYear=53 then 1 else WeekOfYear end as WeekOfYearCustom
	,   DayNameShort
	,   IsLastDayOfMonth
	,   IsWeekday
	,   CASE WHEN KeyDate = DATEADD(wk, DATEDIFF(wk, 6, DATEADD(day,-1,KeyDate)), 6 + 7) THEN KeyDate ELSE DATEADD(wk, DATEDIFF(wk, 6, KeyDate), 6 + 7) END AS LastDayOfWeek
	,   MonthNameShort
	,   MonthYear
	,   QuarterNameShort
	,   WeekOfMonth
from DW.DimDate;