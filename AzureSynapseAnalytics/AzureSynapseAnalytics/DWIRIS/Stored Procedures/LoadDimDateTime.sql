CREATE PROC [DWIRIS].[LoadDimDateTime] @start_date [date],@finish_date [date] AS
begin
	set xact_abort on

	declare 
		    @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@Start_Month Date
		,	@Start_Quarter Date
		,	@WeekStartDate Date
		,	@WeekEndDate Date
		,	@WeekOfYear int
		,	@WeekOfYearName Varchar(32)
		,	@DayOfQuarter int


	if not exists (
		select *
		from DWIRIS.DimDateTime
	) 
	begin
		set datefirst 1
		--declare @start_date datetime = '20090101'
		--declare @finish_date  datetime = '20160101'

		while @start_date < @finish_date
		begin
			set @Start_Month = cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, @start_date), 0) AS DATE)  
			set @Start_Quarter = cast(DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @start_date), 0) AS DATE)
			set @WeekStartDate = cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE) 
			set @WeekEndDate = DateAdd(dd,6,@WeekStartDate)
			set @WeekOfYear  = datepart(iso_week, @start_date) 
			set @WeekOfYearName =  'Week '+ Str(@WeekOfYear,2) +', ' + Str(Year(DATEADD(day, 26 - DATEPART(isoww, @start_date), @start_date)),4)
			set @DayOfQuarter = datediff(day,@Start_Quarter,@start_date)+(1)		-- easier to understand formula
			
	INSERT INTO DWIRIS.DimDateTime (		
				SKDateTime,
				DWHash,
				KeyDateTime,
				DateName,
				Year,
				YearName, 
				MonthStartDate, 
				MonthEndDate, 
				MonthOfYear,
				MonthName, 
				MonthNameShort,
				MonthNameNumeric,
				WeekOfYear,
				WeekOfYearName,
				WeekStartDate,
				WeekEndDate, 
				WeekYear, 
				DayOfWeek, 
				DayOfWeekName, 
				DayOfMonth, 
				DayOfYear , 
				QuarterStartDate , 
				QuarterEndDate,
				QuarterOfYear, 
				QuarterName,
				QuarterNameShort, 
				HalfYearName,
				IsWorkday, 
				IsWorkdayName, 
				DayOfQuarter
			) 
	SELECT
				 CAST(convert(varchar(8), @start_date, 112) AS INT) -- SKDateTime
				, convert(char(40), '') --DWHash
				,@start_date -- KeyDateTime
				, cast(@start_date AS VARCHAR(32)) --DateName
				, year(@start_date) -- [Year]
				, cast(year(@start_date) AS VARCHAR(32)) -- YearName
				, @Start_Month		 -- MonthStartDate
				--, DateAdd(dd,-1,DateAdd(MONTH,1,@Start_Month)) -- MonthEndDate
				, EOMonth(@start_date) -- MonthEndDate
				, month(@start_date) -- MonthOfYear
				, datename(MM, @start_date) + ' ' + cast(year(@start_date) AS CHAR(4)) -- MonthName
				, SUBSTRING(CONVERT(varchar,@start_date, 113), 3, 10)		 --MonthNameShort
				, Str(datepart(year,@start_date),4) + '-'+replace(Str(datepart(mm,@start_date),2),' ','0') --MonthNameNumeric
				, @WeekOfYear --datepart(iso_week, @start_date) -- WeekOfYear
				--, convert(VARCHAR(32), cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE)) -- [WeekOfYearName]	using the Week Start Date as WeekOfYearName
				--, 'Week '+datename(iso_week, @start_date) +', '+ Cast(case datepart(iso_week, @start_date)  when 1 then year(DateAdd(dd,7,cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE)))
				--else year(cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE)) end as varchar) -- [WeekOfYearName]				
				, @WeekOfYearName
				, @WeekStartDate -- cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE) --WeekStartDate
				, @WeekEndDate   -- DateAdd(dd,7,cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE)) --Weekendate
				, case datepart(iso_week, @start_date)  
					when 1 then year(DateAdd(dd,7,cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE)))
					else year(cast(dateadd(DD, -(datepart(DW, @start_date) - 1), @start_date) AS DATE)) 
				  end -- WeekYear
				, datepart(DW, @start_date)  -- DayOfWeek
				, datename(DW, datepart(DW, @start_date) - 1) --DayOfWeekName
				, day(@start_date) -- DayOfMonth
				, datepart(DY, @start_date)  -- DayOfYear
				, @Start_Quarter -- QuarterStartDate
				, DateAdd(dd,-1,DateAdd(QUARTER,1,@Start_Quarter))  -- QuarterEndDate
				, datepart(Q, @start_date) -- QuarterOfYear
				, 'Q' + cast(datepart(Q, @start_date) AS CHAR(1)) + '.' + cast(year(@start_date) AS CHAR(4)) --  QuarterName
				, cast(year(@start_date) AS CHAR(4)) +' - Q' + cast(datepart(Q, @start_date) AS CHAR(1))    --  QuarterNameShort
				, convert(varchar(4), year(@start_date)) + ' - ' + case when month(@start_date) <= 6 then 'H1' else 'H2' end --HalfYearName
				, CASE WHEN datepart(WEEKDAY, @start_date) IN (6, 7) THEN 0 ELSE 1 END  -- IsWorkday
				, CASE WHEN datepart(WEEKDAY, @start_date) IN (6, 7) THEN 'Holiday' ELSE 'Workday' END -- IsWorkdayName
				, @DayOfQuarter
			
			set @start_date = dateadd(D, 1, @start_date)
		end


  
	end

INSERT DWIRIS.DimDateTime
			([SKDateTime],
			[DWHash],
			[KeyDateTime], 
			[DateName], 
			[Year], 
			[YearName], 
			[MonthStartDate], 
			[MonthEndDate], 
			[MonthOfYear], 
			[MonthName], 
			[MonthNameShort], 
			[MonthNameNumeric], 
			[WeekOfYear], 
			[WeekOfYearName], 
			[WeekStartDate], 
			[WeekEndDate], 
			[WeekYear], 
			[DayOfWeek], 
			[DayOfWeekName], 
			[DayOfMonth], 
			[DayOfYear], 
			[QuarterStartDate], 
			[QuarterEndDate], 
			[QuarterOfYear], 
			[QuarterName], 
			[QuarterNameShort], 
			HalfYearName, 
			[IsWorkday], 
			[IsWorkdayName], 
			[WeekType], 
			[MonthType], 
			[QuarterType], 
			[YearType], 
			DayOfQuarter
			)
SELECT 
		99991231,
		convert(char(40), ''),
  		CAST(N'9999-12-31' AS Date),
        N'999912',
        9999,
        N'N/A',
        CAST(N'9999-12-01' AS Date),
        CAST(N'9999-12-31' AS Date),
        12,
        N'N/A',
        NULL,
        NULL,
        0,
        N'N/A',
        NULL,
        NULL,
        NULL,
        0,
        N'N/A',
        0,
        0,
        NULL,
        NULL,
        0,
        N'N/A',
        N'N/A',
		N'N/A',
        0,
        N'N/A',
        NULL,
        NULL,
        NULL,
        NULL,
		0
		

 Update DWIRIS.DimDateTime 
 set WeekOfQuarter = Case 
						when WeekOfYear < 14 then WeekOfYear 
						when weekOfYear < 27 then WeekOfYear - 13
						when weekOfYear < 40 then WeekOfYear - 26
						else weekOfYear - 39 
					end
  Where WeekOfQuarter is null 
 
 IF OBJECT_ID('tempdb..#fweek') IS NOT NULL
		DROP TABLE #fweek
	
	select distinct
               WeekEndDate,
               max(QuarterNameShort) QuarterNameShort,
               Max(year) yr 
			into #fweek
            from
               DWIRIS.DimDateTime 
            where
               WeekOfQuarter = 1 
            group by
               WeekEndDate

IF OBJECT_ID('tempdb..#lweek') IS NOT NULL
		DROP TABLE #lweek
	
	select distinct
               WeekStartDate,
               Min(QuarterNameShort) QuarterNameShort,
               Min(year) yr
			into #lweek    
            from
               DWIRIS.DimDateTime 
            where
               WeekOfQuarter >= 13 
            group by
               WeekStartDate 

IF OBJECT_ID('tempdb..#tempDimDateTim') IS NOT NULL
		DROP TABLE #tempDimDateTim

select 
	[SKDateTime]
           ,[DWHash]
           ,[KeyDateTime]
           ,[DateName]
           ,[Year]
           ,[YearName]
           ,[MonthStartDate]
           ,[MonthEndDate]
           ,[MonthOfYear]
           ,[MonthName]
           ,[MonthNameShort]
           ,[MonthNameNumeric]
           ,[WeekOfYear]
           ,[WeekOfYearName]
           ,[WeekStartDate]
           ,[WeekEndDate]
           ,[WeekYear]
           ,[WeekOfQuarter]
           , Case
							when WeekOfQuarter = 1 then 'Week ' + Replace(Str(WeekOfQuarter, 2), ' ', '0') + ', ' + (select #fweek.QuarterNameShort from #fweek where dt.WeekEndDate = #fweek.WeekEndDate)
							when WeekOfQuarter >= 13 then 'Week ' + Replace(Str(WeekOfQuarter, 2), ' ', '0') + ', ' + (select #lweek.QuarterNameShort from #lweek where dt.WeekStartDate = #lweek.WeekStartDate)
						 else 'Week ' + Replace(Str(WeekOfQuarter, 2), ' ', '0') + ', ' + dt.QuarterNameShort 
						 end as [WeekOfQuarterName]
           ,[DayOfWeek]
           ,[DayOfWeekName]
           ,[DayOfMonth]
           ,[DayOfQuarter]
           ,[DayOfYear]
           ,[QuarterStartDate]
           ,[QuarterEndDate]
           ,[QuarterOfYear]
           ,[QuarterName]
           ,[QuarterNameShort]
           ,case
								when WeekOfQuarter = 1 then (select #fweek.QuarterNameShort from #fweek where dt.WeekEndDate = #fweek.WeekEndDate)
								when WeekOfQuarter >= 13 then (select #lweek.QuarterNameShort from #lweek where dt.WeekStartDate = #lweek.WeekStartDate)
							 else dt.QuarterNameShort 
							 end as [FiscalQuarterNameShort]
           ,case
					when WeekOfQuarter = 1 then (select #fweek.yr from #fweek where dt.WeekEndDate = #fweek.WeekEndDate) 
					when WeekOfQuarter >= 13 then (select #lweek.yr from #lweek where dt.WeekStartDate = #lweek.WeekStartDate)
				 else dt.[year] 
				end as [FiscalYear]
           ,[HalfYearName]
           ,[IsWorkday]
           ,[IsWorkdayName]
           ,[DayType]
           ,[WeekType]
           ,[MonthType]
           ,[QuarterType]
           ,[YearType]
	into #tempDimDateTim
	from DWIRIS.DimDateTime dt 
   Where
      WeekOfQuarterName is null 

 IF OBJECT_ID('DWIRIS.DimDateTime') IS NOT NULL
		truncate TABLE DWIRIS.DimDateTime

insert into DWIRIS.DimDateTime([SKDateTime]
           ,[DWHash]
           ,[KeyDateTime]
           ,[DateName]
           ,[Year]
           ,[YearName]
           ,[MonthStartDate]
           ,[MonthEndDate]
           ,[MonthOfYear]
           ,[MonthName]
           ,[MonthNameShort]
           ,[MonthNameNumeric]
           ,[WeekOfYear]
           ,[WeekOfYearName]
           ,[WeekStartDate]
           ,[WeekEndDate]
           ,[WeekYear]
           ,[WeekOfQuarter]
           ,[WeekOfQuarterName]
           ,[DayOfWeek]
           ,[DayOfWeekName]
           ,[DayOfMonth]
           ,[DayOfQuarter]
           ,[DayOfYear]
           ,[QuarterStartDate]
           ,[QuarterEndDate]
           ,[QuarterOfYear]
           ,[QuarterName]
           ,[QuarterNameShort]
           ,[FiscalQuarterNameShort]
           ,[FiscalYear]
           ,[HalfYearName]
           ,[IsWorkday]
           ,[IsWorkdayName]
           ,[DayType]
           ,[WeekType]
           ,[MonthType]
           ,[QuarterType]
           ,[YearType])
select 
	[SKDateTime]
           ,[DWHash]
           ,[KeyDateTime]
           ,[DateName]
           ,[Year]
           ,[YearName]
           ,[MonthStartDate]
           ,[MonthEndDate]
           ,[MonthOfYear]
           ,[MonthName]
           ,[MonthNameShort]
           ,[MonthNameNumeric]
           ,[WeekOfYear]
           ,[WeekOfYearName]
           ,[WeekStartDate]
           ,[WeekEndDate]
           ,[WeekYear]
           ,[WeekOfQuarter]
           ,[WeekOfQuarterName]
           ,[DayOfWeek]
           ,[DayOfWeekName]
           ,[DayOfMonth]
           ,[DayOfQuarter]
           ,[DayOfYear]
           ,[QuarterStartDate]
           ,[QuarterEndDate]
           ,[QuarterOfYear]
           ,[QuarterName]
           ,[QuarterNameShort]
           ,[FiscalQuarterNameShort]
           ,[FiscalYear]
           ,[HalfYearName]
           ,[IsWorkday]
           ,[IsWorkdayName]
           ,[DayType]
           ,[WeekType]
           ,[MonthType]
           ,[QuarterType]
           ,[YearType]
from #tempDimDateTim

update
         DWIRIS.DimDateTime 
      set
         MonthNameShort = 'N/A',
         MonthNameNumeric = '9999-12',
         WeekStartDate = '99991231',
         WeekEndDate = '99991231',
         WeekYear = 9999,
         QuarterStartDate = '99991231',
         QuarterEndDate = '99991231' 
      where
         KeyDateTime = '99991231'

--update HASH
	update DWIRIS.DimDateTime set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         convert(nvarchar,ISNULL([DateName],''))
					+'|'+convert(nvarchar,ISNULL([Year],''))
					+'|'+convert(nvarchar,ISNULL([YearName],''))
					+'|'+convert(nvarchar,ISNULL([MonthStartDate],''))
					+'|'+convert(nvarchar,ISNULL([MonthEndDate],''))
					+'|'+convert(nvarchar,ISNULL([MonthOfYear],''))
					+'|'+convert(nvarchar,ISNULL([MonthName],''))
					+'|'+convert(nvarchar,ISNULL([MonthNameShort],''))
					+'|'+convert(nvarchar,ISNULL([MonthNameNumeric],''))
					+'|'+convert(nvarchar,ISNULL([WeekOfYear],''))
					+'|'+convert(nvarchar,ISNULL([WeekOfYearName],''))
					+'|'+convert(nvarchar,ISNULL([WeekStartDate],''))
					+'|'+convert(nvarchar,ISNULL([WeekEndDate],''))
					+'|'+convert(nvarchar,ISNULL([WeekYear],''))
					+'|'+convert(nvarchar,ISNULL([DayOfWeek],''))
					+'|'+convert(nvarchar,ISNULL([DayOfWeekName ],''))
					+'|'+convert(nvarchar,ISNULL([DayOfMonth],''))
					+'|'+convert(nvarchar,ISNULL([DayOfYear],''))
					+'|'+convert(nvarchar,ISNULL([QuarterStartDate],''))
					+'|'+convert(nvarchar,ISNULL([QuarterEndDate],''))
					+'|'+convert(nvarchar,ISNULL([QuarterOfYear ],''))
					+'|'+convert(nvarchar,ISNULL([QuarterName],''))
					+'|'+convert(nvarchar,ISNULL([QuarterNameShort],''))
					+'|'+convert(nvarchar,ISNULL([HalfYearName],''))
					+'|'+convert(nvarchar,ISNULL([IsWorkday],''))
					+'|'+convert(nvarchar,ISNULL([IsWorkdayName ],''))
					+'|'+convert(nvarchar,ISNULL([DayOfQuarter],''))
				)
			,2)
end
