CREATE PROC [DWIRIS].[UpdateDateTimeTypes] @CurrentDateOverride [date] AS
BEGIN

	declare @currentDate date = dateadd(day, -1, cast(getDate() as date)); --current day is yesterday
	
	--select @currentDate
	set datefirst 1;
	declare @currentYear int =year(@currentDate); 
	declare @currentQuarter date = DATEADD(quarter, DATEDIFF(quarter, 0, @currentDate), 0); 
	declare @currentMonth date = DATEADD(month, DATEDIFF(month, 0, @currentDate), 0); 
	declare @currentWeek date = DATEADD(DAY, 1-DATEPART(WEEKDAY, @currentDate), @currentDate);
	
	
		select t.*
			,  datediff(dd, Cast(@currentDate as date), KeyDateTime) as dayDiff
			,  datediff(week, @currentWeek, DATEADD(DAY, 1-DATEPART(WEEKDAY, KeyDateTime), KeyDateTime)) as weekDiff
			,  datediff(month, @currentMonth, DATEADD(month, DATEDIFF(month, 0, KeyDateTime), 0)) as monthDiff
			,  datediff(QUARTER, @currentQuarter, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, KeyDateTime), 0)) as qtrDiff
			,  year(KeyDateTime) - @currentYear  as yearDiff
		into #tempdatetime
		from DWIRIS.DimDateTime t
	
	update #tempdatetime
	set DayType = Case when dayDiff = 0 then 'Current Day' 
					   when dayDiff = -1 then 'Previous Day' 
					   when dayDiff <-1 then 'Historical Days' 
					   when dayDiff >= 0 then 'Future Days' 
					   end
		, weekType = case when weekDiff <= -2 then 'Historical Weeks' 
							 when weekDiff = -1 then 'Prior Week' 
							 when weekDiff = 0 then 'Current Week' 
							 else 'Future Weeks' 
							 end
		, MonthType = case when monthDiff = -12 then 'Same Month Prior Year' 
							  when monthDiff <= -2 then 'Historical Months' 
							  when monthDiff = -1 then 'Prior Month' 
							  when monthDiff = 0 then 'Current Month' 
							  else 'Future Months' 
							  end 
		, QuarterType= case when qtrDiff = -4 then 'Same Quarter Prior Year' 
							   when qtrDiff <= -2 then 'Historical Quarters' 
							   when qtrDiff = -1 then 'Prior Quarter' 
							   when qtrDiff = 0 then 'Current Quarter' 
							   else 'Future Quarters' 
							   end
		, yearType =case when yearDiff <= -2 then 'Historical Years' 
							when yearDiff = -1 then 'Prior Year' 
							when yearDiff = 0 then 'Current Year' 
							else 'Future Years' 
							end

	Update DWIRIS.DimDateTime 
	set 
		DayType = dt.DayType,
		weekType = dt.weekType,
		MonthType = dt.MonthType,
		QuarterType = dt.QuarterType,
		yearType = dt.yearType
	from #tempdatetime dt
where dt.KeyDateTime = DWIRIS.DimDateTime.KeyDateTime

end
