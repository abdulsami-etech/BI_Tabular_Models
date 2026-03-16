CREATE PROC [DW].[usp_update_time_period_types] @CurrentDateOverride [DATETIME] AS
BEGIN

declare @currentDate date = cast(getDate() as date); --current day is changed to today from yesterday
	--- Override CurrentDate from the parameter 
	if @CurrentDateOverride is not null 
		set @currentDate= @CurrentDateOverride 

	--select @currentDate
	set datefirst 1;
	declare @currentYear int =year(@currentDate); 
	declare @currentQuarter date = DATEADD(quarter, DATEDIFF(quarter, 0, @currentDate), 0); 
	declare @currentMonth date = DATEADD(month, DATEDIFF(month, 0, @currentDate), 0); 
	declare @currentWeek date = DATEADD(DAY, 1-DATEPART(WEEKDAY, @currentDate), @currentDate);

	declare @NASalesCurrentQuarterEndDateKey Date 
	declare @NASalesCurrentDate Date
	declare @NASalesCurrentYear int, @NACumulativeBusinessDaysQTD int, @NACumulativeBusinessDaysYTD int
	declare @NASalesCurrentQuarterStartDate Date, @NASalesPriorQuarterStartDate Date, @NASalesSameQuarterLYStartDate Date
	declare @NASalesCurrentHYQuarter int
	select @NASalesCurrentQuarterEndDateKey = NASalesCurrentQuarterEndDateKey from [Custom].[MMD_NASalesCurrentQuarter];
	select @NASalesCurrentDate = case when @CurrentDate <= @NASalesCurrentQuarterEndDateKey then @currentDate else @NASalesCurrentQuarterEndDateKey end;

	 with diff as (--to simplify code
		select DateKey
			,  datediff(dd, Cast(@currentDate as date), DateKey) as dayDiff
			,  datediff(week, @currentWeek, DATEADD(DAY, 1-DATEPART(WEEKDAY, DateKey), DateKey)) as weekDiff
			,  datediff(month, @currentMonth, DATEADD(month, DATEDIFF(month, 0, DateKey), 0)) as monthDiff
			,  datediff(QUARTER, @currentQuarter, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, DateKey), 0)) as qtrDiff
			,  year(DateKey) - @currentYear  as yearDiff
		from DW.DimDateTime --where DateKey > '20131201'
	)
	update dt
	set DayType = Case when dayDiff = 0 then 'Current Day' 
					   when dayDiff = -1 then 'Previous Day' 
					   when dayDiff <-1 then 'Historical Days' 
					   when dayDiff >= 0 then 'Future Days' 
					   end
		, dt.weekType = case when weekDiff <= -2 then 'Historical Weeks' 
							 when weekDiff = -1 then 'Prior Week' 
							 when weekDiff = 0 then 'Current Week' 
							 else 'Future Weeks' 
							 end
		, dt.MonthType = case when monthDiff = -12 then 'Same Month Prior Year' 
							  when monthDiff <= -2 then 'Historical Months' 
							  when monthDiff = -1 then 'Prior Month' 
							  when monthDiff = 0 then 'Current Month' 
							  else 'Future Months' 
							  end 
		, dt.QuarterType= case when qtrDiff = -4 then 'Same Quarter Prior Year' 
							   when qtrDiff <= -2 then 'Historical Quarters' 
							   when qtrDiff = -1 then 'Prior Quarter' 
							   when qtrDiff = 0 then 'Current Quarter' 
							   else 'Future Quarters' 
							   end
		, dt.yearType =case when yearDiff <= -2 then 'Historical Years' 
							when yearDiff = -1 then 'Prior Year' 
							when yearDiff = 0 then 'Current Year' 
							else 'Future Years' 
							end
		, dt.NASalesCurrentDay = Case when  dt.datekey = @NASalesCurrentDate then 1 else 0 end
		--, dt.NABusinessDay = bd.IsBusinessDay 
		--, dt.NACumulativeBusinessDaysQTD = bd.CumulativeBusinessDaysQTD
		--, dt.NACumulativeBusinessDaysYTD = bd.CumulativeBusinessDaysYTD
	from DW.DimDateTime  dt
	inner join diff on diff.DateKey = dt.DateKey
	--left join (
	--	select *
	--		, Sum(IsBusinessDay) OVER(Partition by Year,Quarter Order By DateKey) as CumulativeBusinessDaysQTD
	--		, Sum(IsBusinessDay) OVER(Partition by Year Order By DateKey) as  CumulativeBusinessDaysYTD 
	--	from [Custom].MMD_NABDandSalesIndex
	--) bd 
	--	on dt.DateKey = bd.DateKey
	;

	select @NASalesCurrentYear = [Year]
		, @NASalesCurrentQuarterStartDate = QuarterStartDate
		, @NACumulativeBusinessDaysQTD = NACumulativeBusinessDaysQTD
		, @NACumulativeBusinessDaysYTD = NACumulativeBusinessDaysYTD
		, @NASalesPriorQuarterStartDate = DateAdd(q,-1,QuarterStartDate)
		, @NASalesSameQuarterLYStartDate = DateAdd(q,-4,QuarterStartDate)
		, @NASalesCurrentHYQuarter = case when QuarterOfYear in (1, 3) then QuarterOfYear else QuarterOfYear-1 end
	from DW.DimDateTime 
	where NASalesCurrentDay=1


	
	if @CurrentDate >= @NASalesCurrentQuarterEndDateKey  -- Full Quarter Completed
		update dt 
		set NAQTDBdays = Case When QuarterStartDate = @NASalesCurrentQuarterStartDate 
								   AND NACumulativeBusinessDaysQTD <=@NACumulativeBusinessDaysQTD 
							  then 'CQTD'
							  when  QuarterStartDate =@NASalesPriorQuarterStartDate  
							  then 'PQTD'
							  when  QuarterStartDate =@NASalesSameQuarterLYStartDate 
							  then 'LYQTD' 
							  end
			, NAYTDBdays = Case When [Year] = @NASalesCurrentYear 
									 and NACumulativeBusinessDaysYTD <= @NACumulativeBusinessDaysYTD 
								then 'CYTD'
								when [Year] = @NASalesCurrentYear-1 
									 --and (NACumulativeBusinessDaysYTD <= @NACumulativeBusinessDaysYTD or (month(@NASalesCurrentQuarterEndDateKey)=12 and day(@NASalesCurrentQuarterEndDateKey)=31)) --for full Year
									 and QuarterStartDate <= @NASalesSameQuarterLYStartDate 
								then 'LYYTD' 
								else null 
								end
			, NAHYTDBdays = Case When [Year] = @NASalesCurrentYear 
									  and QuarterOfYear >= @NASalesCurrentHYQuarter
									  and NACumulativeBusinessDaysYTD <= @NACumulativeBusinessDaysYTD 
								 then 'CHYTD'
								 end
		from DW.DimDateTime dt

	else
		update dt 
		set NAQTDBdays = Case When QuarterStartDate = @NASalesCurrentQuarterStartDate 
								   AND DateKey<= @CurrentDate 
								   and NACumulativeBusinessDaysQTD <= @NACumulativeBusinessDaysQTD 
							  then 'CQTD'
							  when QuarterStartDate = @NASalesPriorQuarterStartDate 
								   and NACumulativeBusinessDaysQTD <= @NACumulativeBusinessDaysQTD 
							  then 'PQTD'
							  when QuarterStartDate = @NASalesSameQuarterLYStartDate 
								   and NACumulativeBusinessDaysQTD <= @NACumulativeBusinessDaysQTD 
							  then 'LYQTD' 
							  else null 
							  end 
			, NAYTDBdays = Case When [Year] = @NASalesCurrentYear 
									 AND DateKey <= @CurrentDate 
									 and NACumulativeBusinessDaysYTD <= @NACumulativeBusinessDaysYTD 
								then 'CYTD'
								when [Year] = @NASalesCurrentYear-1 
								     and QuarterStartDate <= @NASalesSameQuarterLYStartDate 
									 and NACumulativeBusinessDaysYTD <= @NACumulativeBusinessDaysYTD 
								then 'LYYTD' 
								else null 
								end
			, NAHYTDBdays = Case When [Year] = @NASalesCurrentYear 
									  and QuarterOfYear >= @NASalesCurrentHYQuarter
									  AND DateKey <= @CurrentDate 
									  and NACumulativeBusinessDaysYTD <= @NACumulativeBusinessDaysYTD 
								 then 'CHYTD'
								 end
		from DW.DimDateTime dt

		select @CurrentDate AS CurrentDate , @NASalesCurrentQuarterEndDateKey AS NASalesCurrentQuarterEndDateKey

end