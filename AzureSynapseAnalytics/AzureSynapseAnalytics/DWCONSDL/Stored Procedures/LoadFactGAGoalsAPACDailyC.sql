CREATE PROC [DWCONSDL].[LoadFactGAGoalsAPACDailyC] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactGAGoalsAPACDailyC') is not null
		drop table #TempFactGAGoalsAPACDailyC

	create table #TempFactGAGoalsAPACDailyC with (distribution = round_robin, heap) as 
	
SELECT CONVERT(CHAR(40), '')	AS DWHashKey,
	   VisitDate,
	   CountryFromHostName,
  SUM(CASE WHEN G4 > 0 THEN 1 ELSE 0 END) AS G_ID4,
  SUM(CASE WHEN G5 > 0 THEN 1 ELSE 0 END) AS G_ID5,
  SUM(CASE WHEN G6 > 0 THEN 1 ELSE 0 END) AS G_ID6,
  SUM(CASE WHEN G7 > 0 THEN 1 ELSE 0 END) AS G_ID7
FROM (
SELECT Id,VisitDate, CountryFromHostName,
  SUM(CASE WHEN ( EventCategory = 'form submit' AND
  EventAction = 'success' AND EventLabel = 'free assessment')
  THEN 1  ELSE 0 
  END) AS G4,
  SUM(CASE WHEN (EventCategory = 'form submit' AND
  EventAction = 'success' AND EventLabel = 'request-appointment')
  THEN 1  ELSE 0 
  END) AS G5,
  SUM(CASE WHEN PagePath LIKE '%assessment/thankyou%'
  THEN 1  ELSE 0 
  END) AS G6,
  SUM(CASE WHEN PagePath LIKE '%request-appointment/thankyou%'
  THEN 1  ELSE 0 
  END) AS G7
FROM (SELECT DISTINCT SH.Id, CONVERT(DATE, SH.VisitDate) AS VisitDate, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName, SH.HitNumber, SH.EventCategory, SH.EventAction, SH.EventLabel, SH.PagePath FROM  [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from [DWCONSDL].[FactGAGoalsAPACDailyC] )) tempTable0
GROUP BY Id,VisitDate, CountryFromHostName) AS tempTable
GROUP By VisitDate, CountryFromHostName


update #TempFactGAGoalsAPACDailyC set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, G_ID4), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID5), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID6), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID7), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAGoalsAPACDailyC
		set	DWBatchID 				= 			@BatchID
		,	DWHashKey				=			src.DWHashKey
		,   G_ID4					=			src.G_ID4
		,	G_ID5					=			src.G_ID5
		,   G_ID6					=			src.G_ID6
		,	G_ID7					=			src.G_ID7
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAGoalsAPACDailyC src
	where DWCONSDL.FactGAGoalsAPACDailyC.VisitDate = src.VisitDate and DWCONSDL.FactGAGoalsAPACDailyC.CountryFromHostName = src.CountryFromHostName
		and DWCONSDL.FactGAGoalsAPACDailyC.DWHashKey != src.DWHashKey
	option (label = 'DWCONSDL.LoadFactGAGoalsAPACDailyC_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAGoalsAPACDailyC_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactGAGoalsAPACDailyC (
			DWBatchID
		,	DWHashKey
		,	VisitDate
		,	CountryFromHostName
		,	G_ID4
		,	G_ID5
		,	G_ID6
		,	G_ID7
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	VisitDate
		,	CountryFromHostName
		,	G_ID4
		,	G_ID5
		,	G_ID6
		,	G_ID7
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAGoalsAPACDailyC src
	where not exists(select * from DWCONSDL.FactGAGoalsAPACDailyC dst where dst.VisitDate = src.VisitDate and dst.CountryFromHostName = src.CountryFromHostName)
	option (label = 'DWCONSDL.LoadFactGAGoalsAPACDailyC_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAGoalsAPACDailyC_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end