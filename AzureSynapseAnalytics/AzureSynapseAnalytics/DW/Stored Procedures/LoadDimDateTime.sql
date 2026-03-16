CREATE PROC [DW].[LoadDimDateTime] @Start_Date [DATETIME],@End_Date [DATETIME] AS
BEGIN

Declare @Start_Month Date
Declare @Start_Quarter Date
Declare @WeekStartDate Date
Declare @WeekEndDate Date
Declare @WeekOfYear int
Declare @WeekOfYearName Varchar(32)
Declare @DayOfQuarter int


	SET NOCOUNT ON;
	SET DATEFIRST 1 ;
		--declare @Start_Date datetime = '20090101'
		--declare @End_Date  datetime = '20160101'

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
			      CAST(convert(varchar(8), date_value, 112) AS INT) as SKDate
				, convert(date, date_value)  as DateKey
				, cast(date_value AS VARCHAR(32)) as [DateName]
				, year(date_value) as [Year]
				, cast(year(date_value) AS VARCHAR(32)) as [YearName]
				, cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, date_value), 0) AS DATE) 		 as [MonthStartDate]
				, EOMonth(date_value) 		 as [MonthEndDate]
				, month(date_value) as [MonthOfYear]
				, datename(MM, date_value) + ' ' + cast(year(date_value) AS CHAR(4))  as [MonthName]
				, SUBSTRING(CONVERT(varchar,date_value, 113), 3, 10)		 as [MonthNameShort]
				, Str(datepart(year,date_value),4) + '-'+replace(Str(datepart(mm,date_value),2),' ','0') as [MonthNameNumeric]
				, datepart(iso_week, date_value)  as [WeekOfYear]
				
				, 'Week '+ Str(datepart(iso_week, date_value),2) +', ' + Str(Year(DATEADD(day, 26 - DATEPART(isoww, date_value), date_value)),4) as [WeekOfYearName]
				, cast(dateadd(DD, -(datepart(DW, date_value) - 1), date_value) AS DATE) as [WeekStartDate]
				, DateAdd(dd,6,cast(dateadd(DD, -(datepart(DW, date_value) - 1), date_value) AS DATE) ) as [WeekEndDate]
				, case datepart(iso_week, date_value)  when 1 then year(DateAdd(dd,7,cast(dateadd(DD, -(datepart(DW, date_value) - 1), date_value) AS DATE))) 
				else year(cast(dateadd(DD, -(datepart(DW, date_value) - 1), date_value) AS DATE)) end as [WeekYear]
				, datepart(DW, date_value)  as [DayOfWeek]
				, datename(DW, datepart(DW, date_value) - 1) as [DayOfWeekName]
				, day(date_value) as [DayOfMonth]
				, datepart(DY, date_value)  as [DayOfYear]
				, cast(DATEADD(QUARTER, DATEDIFF(QUARTER, 0, date_value), 0) AS DATE) as [QuarterStartDate]
				, DateAdd(dd,-1,DateAdd(QUARTER,1,cast(DATEADD(QUARTER, DATEDIFF(QUARTER, 0, date_value), 0) AS DATE)))  as [QuarterEndDate]
				, datepart(Q, date_value) as [QuarterOfYear]
				, 'Q' + cast(datepart(Q, date_value) AS CHAR(1)) + '.' + cast(year(date_value) AS CHAR(4)) as [QuarterName]
				, cast(year(date_value) AS CHAR(4)) +' - Q' + cast(datepart(Q, date_value) AS CHAR(1))   as [QuarterNameShort]
				, convert(varchar(4), year(date_value)) + ' - ' + case when month(date_value) <= 6 then 'H1' else 'H2' end as [HalfYearName]
				, CASE WHEN datepart(WEEKDAY, date_value) IN (6, 7) THEN 0 ELSE 1 END  as [IsWorkday]
				, CASE WHEN datepart(WEEKDAY, date_value) IN (6, 7) THEN 'Holiday' ELSE 'Workday' END as [IsWorkdayName]
				, datediff(day,cast(DATEADD(QUARTER, DATEDIFF(QUARTER, 0, date_value), 0) AS DATE),date_value)+(1) as [DayOfQuarter]
		INTO #dates
		FROM dates
		WHERE rownum <= DATEDIFF(dd, @Start_Date, @End_Date)+1
	
	IF NOT EXISTS (select * from DW.DimDateTime where SKDate = 99991231)
	BEGIN
		INSERT INTO DW.DimDateTime (
				SKDate, DateKey, [DateName]
				, [Year], YearName
				, MonthStartDate, MonthEndDate , MonthOfYear, [MonthName], MonthNameShort,MonthNameNumeric 
				, WeekOfYear, WeekOfYearName,WeekStartDate ,[WeekEndDate],WeekYear
				, [DayOfWeek], DayOfWeekName, [DayOfMonth], [DayOfYear] , QuarterStartDate , QuarterEndDate
				, QuarterOfYear, QuarterName ,QuarterNameShort, HalfYearName
				, IsWorkday, IsWorkdayName, DayOfQuarter
			) 

		select
			99991231, --SKDate
			CAST(N'9999-12-31' AS Date), --DateKey
			N'999912', --[DateName]
			9999,
			N'Never',
			CAST(N'9999-12-01' AS Date),
			CAST(N'9999-12-31' AS Date),
			12,
			N'Never',
			NULL,
			NULL,
			0,
			N'Never',
			NULL,
			NULL,
			NULL,
			0,
			N'Never',
			0,
			0,
			NULL,
			NULL,
			0,
			N'Never',
			N'Never',
			N'Never',
			0,
			N'Never',
			0
	END



		INSERT INTO DW.DimDateTime (
				SKDate, DateKey, [DateName]
				, [Year], YearName
				, MonthStartDate, MonthEndDate , MonthOfYear, [MonthName], MonthNameShort,MonthNameNumeric 
				, WeekOfYear, WeekOfYearName,WeekStartDate ,[WeekEndDate],WeekYear
				, [DayOfWeek], DayOfWeekName, [DayOfMonth], [DayOfYear] , QuarterStartDate , QuarterEndDate
				, QuarterOfYear, QuarterName ,QuarterNameShort, HalfYearName
				, IsWorkday, IsWorkdayName, DayOfQuarter
			) 
		select 
			SKDate, DateKey, [DateName]
				, [Year], YearName
				, MonthStartDate, MonthEndDate , MonthOfYear, [MonthName], MonthNameShort,MonthNameNumeric 
				, WeekOfYear, WeekOfYearName,WeekStartDate ,[WeekEndDate],WeekYear
				, [DayOfWeek], DayOfWeekName, [DayOfMonth], [DayOfYear] , QuarterStartDate , QuarterEndDate
				, QuarterOfYear, QuarterName ,QuarterNameShort, HalfYearName
				, IsWorkday, IsWorkdayName, DayOfQuarter
		from #dates
		
	
   Update [DW].[DimDateTime]
   set WeekOfQuarter = Case when WeekOfYear <14 then WeekOfYear when weekOfYear < 27 then WeekOfYear-13 when weekOfYear < 40 then WeekOfYear-26 else weekOfYear - 39 end     
   Where WeekOfQuarter is null
  
  Update dt 
   set WeekOfQuarterName =  case when WeekOfQuarter=1 then 'Week '+Replace(Str(WeekOfQuarter,2),' ','0') +', '+fweek.QuarterNameShort when WeekOfQuarter >=13 then 
   'Week '+Replace(Str(WeekOfQuarter,2),' ','0') +', '+lweek.QuarterNameShort else 'Week '+Replace(Str(WeekOfQuarter,2),' ','0') +', '+dt.QuarterNameShort end ,
   FiscalQuarterNameShort = case when WeekOfQuarter=1 then  fweek.QuarterNameShort when WeekOfQuarter >=13 then 
   lweek.QuarterNameShort else  dt.QuarterNameShort end  ,
   FiscalYear= case when WeekOfQuarter=1 then  fweek.yr when WeekOfQuarter >=13 then lweek.yr else  dt.[year] end  
   from [DW].[DimDateTime] dt left join (select distinct WeekEndDate, max(QuarterNameShort) QuarterNameShort ,Max(year) yr  from [DW].[DimDateTime] where WeekOfQuarter = 1 group by WeekEndDate) fweek on dt.WeekEndDate = fweek.WeekEndDate   
   left join (select distinct WeekStartDate, Min(QuarterNameShort) QuarterNameShort , Min(year) yr from [DW].[DimDateTime] where WeekOfQuarter >= 13 group by WeekStartDate ) lweek on dt.WeekStartDate = lweek.WeekStartDate   
   Where WeekOfQuarterName is null


   update [DW].[DimDateTime]
	SET CalQWeekStartDate	=	case when WeekOfQuarter=1 and QuarterStartDate>WeekStartDate then QuarterStartDate
								when weekOfQuarter>=13 and QuarterStartDate>WeekStartDate then QuarterStartDate
								else WeekStartDate end
		,CalQWeekEndDate	=	case when WeekOfQuarter=1 and QuarterEndDate<WeekEndDate then QuarterEndDate
								when weekOfQuarter>=13 and QuarterEndDate<WeekEndDate then QuarterEndDate
								else WeekEndDate end 
		,CalYWeekStartDate	=	case when WeekOfYear=1 and QuarterStartDate>WeekStartDate then QuarterStartDate
								when WeekOfYear>=52 and QuarterStartDate>WeekStartDate then QuarterStartDate
								else WeekStartDate end
		,CalYWeekEndDate	=	case when WeekOfYear=1 and QuarterEndDate<WeekEndDate then QuarterEndDate
								when WeekOfYear>=52 and QuarterEndDate<WeekEndDate then QuarterEndDate
								else WeekEndDate end

	;WITH CalWeek (SKDate, CalQ_WeekOfQuarter, CalY_WeekOfYear) AS
	(
		SELECT SKDate, Dense_Rank() over (Partition by QuarterStartDate order by CalQWeekEndDate) AS CalQ_WeekOfQuarter
					 , Dense_Rank() over (Partition by Year order by CalYWeekEndDate) AS CalY_WeekOfYear
		FROM [DW].[DimDateTime]
	)
	update [DW].[DimDateTime]
	SET  CalQWeekOfQuarter	=	CalQ_WeekOfQuarter 
		,CalYWeekOfYear =	CalY_WeekOfYear
	FROM CalWeek CW INNER JOIN [DW].[DimDateTime] DDT ON DDT.SKDate = CW.SKDate

   update [DW].[DimDateTime]
		set MonthNameShort = 'Never'
		,	MonthNameNumeric = '9999-12'
		,	WeekStartDate = '99991231'
		,	WeekEndDate = '99991231'
		,	WeekYear = 9999
		,	QuarterStartDate = '99991231'
		,	QuarterEndDate = '99991231'
	where SKDate = 99991231


end
