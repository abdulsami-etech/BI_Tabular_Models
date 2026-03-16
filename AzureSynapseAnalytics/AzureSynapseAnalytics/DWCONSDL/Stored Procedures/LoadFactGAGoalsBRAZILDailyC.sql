CREATE PROC [DWCONSDL].[LoadFactGAGoalsBRAZILDailyC] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactGAGoalsBRAZILDailyC') is not null
		drop table #TempFactGAGoalsBRAZILDailyC

	create table #TempFactGAGoalsBRAZILDailyC with (distribution = round_robin, heap) as 
	
SELECT CONVERT(CHAR(40), '')	AS DWHashKey,
	   VisitDate,
	   CountryFromHostName,
  SUM(CASE WHEN G1 > 0 THEN 1 ELSE 0 END) AS G_ID1,
  SUM(CASE WHEN G2 > 0 THEN 1 ELSE 0 END) AS G_ID2,
  SUM(CASE WHEN G3 > 0 THEN 1 ELSE 0 END) AS G_ID3,
  SUM(CASE WHEN G4 > 0 THEN 1 ELSE 0 END) AS G_ID4,
  SUM(CASE WHEN G5 > 0 THEN 1 ELSE 0 END) AS G_ID5,
  SUM(CASE WHEN G6 > 0 THEN 1 ELSE 0 END) AS G_ID6,
  SUM(CASE WHEN G7 > 0 THEN 1 ELSE 0 END) AS G_ID7,
  SUM(CASE WHEN G8 > 0 THEN 1 ELSE 0 END) AS G_ID8,
  SUM(CASE WHEN G9 > 0 THEN 1 ELSE 0 END) AS G_ID9
FROM (
SELECT Id,VisitDate, CountryFromHostName,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND 
  EventAction = 'DL Search Zip')
  THEN 1  ELSE 0 
  END) AS G1,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'DL Profile View')
  THEN 1  ELSE 0 
  END) AS G2,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'SA Submit')
  THEN 1  ELSE 0 
  END) AS G3,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'Smile View Submit')
  THEN 1  ELSE 0 
  END) AS G4,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'DLRA Submit')
  THEN 1  ELSE 0 
  END) AS G5,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'RA Submit')
  THEN 1  ELSE 0 
  END) AS G6,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'CU Submit')
  THEN 1  ELSE 0 
  END) AS G7,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'Adult Submit')
  THEN 1  ELSE 0 
  END) AS G8,
  SUM(CASE WHEN (
  --EventCategory = 'Prime Action' AND
  EventAction = 'Teen Submit')
  THEN 1  ELSE 0 
  END) AS G9
FROM (SELECT DISTINCT SH.Id, CONVERT(DATE, SH.VisitDate) AS VisitDate, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName, SH.HitNumber, SH.EventCategory, SH.EventAction, SH.EventLabel FROM  [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE  SH.EventCategory = 'Prime Action'  AND SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from [DWCONSDL].[FactGAGoalsBRAZILDailyC] )) tempTable0
GROUP BY Id,VisitDate, CountryFromHostName) AS tempTable
GROUP By VisitDate, CountryFromHostName


update #TempFactGAGoalsBRAZILDailyC set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, G_ID1), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID2), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID3), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID4), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID5), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID6), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID7), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID8), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID9), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAGoalsBRAZILDailyC
		set	DWBatchID 				= 			@BatchID
		,	DWHashKey				=			src.DWHashKey
		,	G_ID1					=			src.G_ID1
		,   G_ID2					=			src.G_ID2
		,	G_ID3					=			src.G_ID3
		,   G_ID4					=			src.G_ID4
		,	G_ID5					=			src.G_ID5
		,   G_ID6					=			src.G_ID6
		,	G_ID7					=			src.G_ID7
		,   G_ID8					=			src.G_ID8
		,   G_ID9					=			src.G_ID9
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAGoalsBRAZILDailyC src
	where DWCONSDL.FactGAGoalsBRAZILDailyC.VisitDate = src.VisitDate and DWCONSDL.FactGAGoalsBRAZILDailyC.CountryFromHostName = src.CountryFromHostName
		and DWCONSDL.FactGAGoalsBRAZILDailyC.DWHashKey != src.DWHashKey
	option (label = 'DWCONSDL.LoadFactGAGoalsBRAZILDailyC_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAGoalsBRAZILDailyC_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactGAGoalsBRAZILDailyC (
			DWBatchID
		,	DWHashKey
		,	VisitDate
		,	CountryFromHostName
		,	G_ID1
		,	G_ID2
		,	G_ID3
		,	G_ID4
		,	G_ID5
		,	G_ID6
		,	G_ID7
		,	G_ID8
		,	G_ID9
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	VisitDate
		,	CountryFromHostName
		,	G_ID1
		,	G_ID2
		,	G_ID3
		,	G_ID4
		,	G_ID5
		,	G_ID6
		,	G_ID7
		,	G_ID8
		,	G_ID9
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAGoalsBRAZILDailyC src
	where not exists(select * from DWCONSDL.FactGAGoalsBRAZILDailyC dst where dst.VisitDate = src.VisitDate and dst.CountryFromHostName = src.CountryFromHostName)
	option (label = 'DWCONSDL.LoadFactGAGoalsBRAZILDailyC_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAGoalsBRAZILDailyC_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end