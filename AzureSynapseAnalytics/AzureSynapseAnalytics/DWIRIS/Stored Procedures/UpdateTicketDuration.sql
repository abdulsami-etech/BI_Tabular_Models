CREATE PROC [DWIRIS].[UpdateTicketDuration] @SKTicket [int] AS
begin
	DECLARE 
	@start_date datetime, 
	@end_date datetime, 
	@BusinesshoursID [nchar](18) --'01mi0000000Xp2YAAS'

	SET @start_date = (select TicketOpenDateKey from DWIRIS.DimTicket where SKTicket = @SKTicket)
	SET @end_date = (select isnull(TicketClosedDateKey,getdate()) from DWIRIS.DimTicket where SKTicket = @SKTicket)
	SET @BusinesshoursID = (select isnull(BusinesshoursID,'01mi0000000Xp2YAAS') from DWIRIS.DimTicket where SKTicket = @SKTicket)


BEGIN TRY DROP TABLE #datenames END TRY BEGIN CATCH END CATCH
	
		select 
			@start_date as start_Date,
			DATENAME(weekday,@start_date) as start_date_name,
			@end_Date as end_date,
			DATENAME(weekday,isnull(@end_Date,getdate())) as end_date_name,
			@BusinesshoursID as BusinesshoursID
		into #datenames
						
BEGIN TRY DROP TABLE #schedule END TRY BEGIN CATCH END CATCH
		select 
				 [Id]
				,[Name]
				,datename
				,Start_time
				,End_time
		into #schedule
			from (
					select
						 [Id]
						,[Name]
						,'Monday' as datename
						,[MondayStartTime] as Start_time
						,[MondayEndTime]  as End_time
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Tuesday' as datename
						,[MondayStartTime]
						,[MondayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Wednesday' as datename
						,[MondayStartTime]
						,[MondayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Thursday' as datename
						,[MondayStartTime]
						,[MondayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Friday' as datename
						,[MondayStartTime]
						,[MondayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Saturday' as datename
						,[MondayStartTime]
						,[MondayEndTime]
					from [SrcSFDC].[BusinessHours]
					UNION ALL
					select
						[Id]
						,[Name]
						,'Sunday' as datename
						,[MondayStartTime]
						,[MondayEndTime]
					from [SrcSFDC].[BusinessHours]
				 ) t
		where t.[Id] = @BusinesshoursID

BEGIN TRY DROP TABLE #precalc END TRY BEGIN CATCH END CATCH

				select
					'First' as date_order,
					start_date_name as date_name, 
					start_date,
					BusinessHoursID
				into #precalc
				from #datenames
				UNION ALL
				select 
					'Between' as date_order,
					DayNameLong,
					convert(datetime,KeyDate),
					@BusinesshoursID
				from DW.DimDate
				where convert(datetime,KeyDate) > @start_Date and KeyDate < convert(date,@end_Date)
				UNION all
				select
					'Last' as date_order,
					end_date_name, 
					end_date,
					BusinessHoursID
				from #datenames


UPDATE DWIRIS.DimTicket
set [Ticket Net Hrs] = 
(
	select 
		round(sum(Duration)/60/60,0)
	from
		(select 
				t.*,
				sc.*,
				CASE
					WHEN t.date_order = 'First' then datediff(ss,cast(t.start_date as time),cast(sc.end_time as time))
					WHEN t.date_order = 'Between' then datediff(ss,cast(sc.start_time as time),cast(sc.end_time as time))
					WHEN t.date_order = 'Last' then datediff(ss,cast(sc.start_time as time),cast(t.start_date as time))
				end as Duration
			from #precalc t
			inner join #schedule	sc
				on t.BusinessHoursID = sc.[Id] and t.date_name = sc.datename
		) res
)
where DWIRIS.DimTicket.SKTicket = @SKTicket

end --procedure

