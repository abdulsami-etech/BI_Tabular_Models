CREATE PROC [DWCONSDL].[LoadFactGAUMsCTDHistory] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0)
,@RunCANADA [bit], @LoadStartDateCANADA [date], @LoadEndDateCANADA [date]
,@RunEMEA [bit], @LoadStartDateEMEA [date], @LoadEndDateEMEA [date]
,@RunUS [bit], @LoadStartDateUS [date], @LoadEndDateUS [date] 
,@RunBRAZIL [bit], @LoadStartDateBRAZIL [date], @LoadEndDateBRAZIL [date] 
,@RunAPAC [bit], @LoadStartDateAPAC [date], @LoadEndDateAPAC [date]
,@RunLATAM [bit], @LoadStartDateLATAM [date], @LoadEndDateLATAM [date] AS
begin
	set nocount on
	set xact_abort on
	set datefirst 1;

	declare @RowsInserted	int = 0,	@RowsUpdated	int = 0,@RowsInserted_CANADA	int = 0,	@RowsUpdated_CANADA	int = 0
	,@RowsInserted_EMEA	int = 0,	@RowsUpdated_EMEA	int = 0,@RowsInserted_US	int = 0,	@RowsUpdated_US	int = 0
	,@RowsInserted_BRAZIL	int = 0,	@RowsUpdated_BRAZIL	int = 0 ,@RowsInserted_APAC	int = 0,	@RowsUpdated_APAC	int = 0
	,@RowsInserted_LATAM	int = 0,	@RowsUpdated_LATAM	int = 0
	
	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactGAUMsCTDHistory') is not null
		drop table #TempFactGAUMsCTDHistory


create table #TempFactGAUMsCTDHistory (
	[DWHash]                 	CHAR (40)      NOT NULL,
	[DWHashKey]                 CHAR (40)      NOT NULL,
	[Region]            		NVARCHAR (50)  NULL,
    [DateKey]                	DATE		   NULL,
	[CountryFromHostName]       NVARCHAR (200) NULL,
	[UVsWTD]					INT			   NULL,
	[UVsMTD]					INT			   NULL,
	[UVsQTD]					INT			   NULL,
	[UVsYTD]					INT			   NULL,
	[UPVsWTD]					INT			   NULL,
	[UPVsMTD]					INT			   NULL,
	[UPVsQTD]					INT			   NULL,
	[UPVsYTD]					INT			   NULL,
	[SessionsWTD]				INT			   NULL,
	[SessionsMTD]				INT			   NULL,
	[SessionsQTD]				INT			   NULL,
	[SessionsYTD]				INT			   NULL

) with (distribution = round_robin, heap)


-- EMEA REGION

IF @RunEMEA = 1
BEGIN

declare @CurrentDMaxDateEMEA date 
declare @CurrentSMaxDateEMEA date 
declare @CurrentSMinDateEMEA date 
declare @CurrentDateEMEA date
declare @CurrentMinDateEMEA DATE 
declare @CurrentMaxDateEMEA date 
declare @MaxCounterEMEA INT
declare @CounterEMEA INT = 0
declare @CurrentYearStartDateEMEA date
DECLARE @PreviousYearStartDateEMEA date
declare @CurrentYearEMEA int 
declare @CurrentWeekStartDateEMEA date
declare @CurrentWeekEndDateEMEA date
declare @CurrentMonthStartDateEMEA date
declare @CurrentMonthEndDateEMEA date
declare @CurrentQuarterStartDateEMEA date
declare @CurrentQuarterEndDateEMEA date

SELECT @CurrentDMaxDateEMEA =ISNULL(MAX(DateKey), '1900-01-01') FROM [DWCONSDL].[FactGAUMsCTD] WHERE Region = 'EMEA'

SELECT @CurrentSMaxDateEMEA =ISNULL(MAX(VisitDate), '1900-01-01')
, @CurrentSMinDateEMEA =ISNULL(MIN(VisitDate), '1900-01-01') FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA]


IF @CurrentSMinDateEMEA > @CurrentDMaxDateEMEA
	SET @CurrentMinDateEMEA = @CurrentSMinDateEMEA
ELSE
	SET @CurrentMinDateEMEA = @CurrentDMaxDateEMEA
	
IF @LoadStartDateEMEA IS NOT NULL
	SET @CurrentMinDateEMEA = @LoadStartDateEMEA
	
IF @LoadEndDateEMEA IS NOT NULL
	SET @CurrentMaxDateEMEA = @LoadEndDateEMEA
ELSE
	SET @CurrentMaxDateEMEA = @CurrentSMaxDateEMEA

SET @MaxCounterEMEA = DATEDIFF(dd, @CurrentMinDateEMEA, @CurrentMaxDateEMEA)

SET @PreviousYearStartDateEMEA	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentMinDateEMEA)-1, 0) 

WHILE ( @CounterEMEA <= @MaxCounterEMEA)
BEGIN
	SET @CurrentDateEMEA = DATEADD(dd, @CounterEMEA, @CurrentMinDateEMEA)
	SET @CurrentYearStartDateEMEA	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentDateEMEA), 0) 

SELECT @CurrentWeekStartDateEMEA = CalYWeekStartDate, @CurrentWeekEndDateEMEA = CalYWeekEndDate
,@CurrentMonthStartDateEMEA = MonthStartDate, @CurrentMonthEndDateEMEA = MonthEndDate
,@CurrentQuarterStartDateEMEA = QuarterStartDate, @CurrentQuarterEndDateEMEA = QuarterEndDate, @CurrentYearEMEA = [Year]
FROM [DW].[DimDateTime] WHERE DateKey = @CurrentDateEMEA;


INSERT INTO #TempFactGAUMsCTDHistory (
			DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
	)
SELECT 	 CONVERT(CHAR(40), '')	AS DWHash
			, CONVERT(CHAR(40), '')	AS DWHashKey
			,'EMEA' AS Region
			, @CurrentDateEMEA AS DateKey
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateEMEA AND @CurrentDateEMEA THEN SH.FullVisitorId ELSE NULL END) AS UVsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateEMEA AND @CurrentDateEMEA THEN SH.FullVisitorId ELSE NULL END) AS UVsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateEMEA AND @CurrentDateEMEA THEN SH.FullVisitorId ELSE NULL END) AS UVsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateEMEA AND @CurrentDateEMEA THEN SH.FullVisitorId ELSE NULL END) AS UVsYTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentWeekStartDateEMEA AND @CurrentDateEMEA  THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsWTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentMonthStartDateEMEA AND @CurrentDateEMEA THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsMTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentQuarterStartDateEMEA AND @CurrentDateEMEA THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsQTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentYearStartDateEMEA AND @CurrentDateEMEA THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsYTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateEMEA AND @CurrentDateEMEA  THEN SH.Id ELSE NULL END) AS SessionsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateEMEA AND @CurrentDateEMEA THEN SH.Id ELSE NULL END) AS SessionsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateEMEA AND @CurrentDateEMEA THEN SH.Id ELSE NULL END) AS SessionsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateEMEA AND @CurrentDateEMEA THEN SH.Id ELSE NULL END) AS SessionsYTD
FROM [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SH
--INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SH.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE  SH.VisitDate >= @CurrentYearStartDateEMEA and SH.VisitDate <= @CurrentDateEMEA
GROUP BY CM.CountryFromHostName

    SET @CounterEMEA  = @CounterEMEA  + 1
END

update #TempFactGAUMsCTDHistory set DWHashKey =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, DateKey), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)
		,DWHash =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, UVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsYTD), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMsCTD
		set	DWBatchID 				= 			@BatchID
		,	DWHash					=			src.DWHash
		,	UVsWTD					=			src.UVsWTD
		,	UVsMTD					=			src.UVsMTD
		,	UVsQTD					=			src.UVsQTD
		,	UVsYTD					=			src.UVsYTD
		,   UPVsWTD					=			src.UPVsWTD
		,   UPVsMTD					=			src.UPVsMTD
		,   UPVsQTD					=			src.UPVsQTD
		,   UPVsYTD					=			src.UPVsYTD
		,   SessionsWTD				=			src.SessionsWTD
		,   SessionsMTD				=			src.SessionsMTD
		,   SessionsQTD				=			src.SessionsQTD
		,   SessionsYTD				=			src.SessionsYTD
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where DWCONSDL.FactGAUMsCTD.DWHashKey = src.DWHashKey
		and DWCONSDL.FactGAUMsCTD.DWHash != src.DWHash
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_EMEA');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_EMEA', @rc = @RowsUpdated_EMEA out

	insert into DWCONSDL.FactGAUMsCTD (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where not exists(select * from DWCONSDL.FactGAUMsCTD dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_EMEA');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_EMEA', @rc = @RowsInserted_EMEA out
	
	UPDATE [DWCONSDL].[FactGAUMsCTD]
SET UVsWTDPY = Sub.UVsWTDPY,UVsMTDPY = Sub.UVsMTDPY,UVsQTDPY = Sub.UVsQTDPY,UVsYTDPY = Sub.UVsYTDPY
   ,UPVsWTDPY = Sub.UPVsWTDPY,UPVsMTDPY = Sub.UPVsMTDPY,UPVsQTDPY = Sub.UPVsQTDPY,UPVsYTDPY = Sub.UPVsYTDPY
   ,SessionsWTDPY = Sub.SessionsWTDPY,SessionsMTDPY = Sub.SessionsMTDPY,SessionsQTDPY = Sub.SessionsQTDPY,SessionsYTDPY = Sub.SessionsYTDPY
FROM (
SELECT DWHashKey
		,   LAG(UVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsWTDPY
		,   LAG(UVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsMTDPY
		,   LAG(UVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsQTDPY
		,   LAG(UVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsYTDPY
		,   LAG(UPVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsWTDPY
		,   LAG(UPVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsMTDPY
		,   LAG(UPVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsQTDPY
		,   LAG(UPVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsYTDPY
		,   LAG(SessionsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsWTDPY
		,   LAG(SessionsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsMTDPY
		,   LAG(SessionsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsQTDPY
		,   LAG(SessionsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsYTDPY
     FROM [DWCONSDL].[FactGAUMsCTD] F
	 INNER JOIN [DW].[DimDateTime] D ON F.DateKey = D.DateKey
	 WHERE F.Region = 'EMEA'  AND F.DateKey >=  @PreviousYearStartDateEMEA
	 ) Sub
WHERE [DWCONSDL].[FactGAUMsCTD].DWHashKey = Sub.DWHashKey AND DWBatchID = @BatchID

END

-- CANADA REGION

IF @RunCANADA = 1
BEGIN

TRUNCATE TABLE #TempFactGAUMsCTDHistory

declare @CurrentDMaxDateCANADA date 
declare @CurrentSMaxDateCANADA date 
declare @CurrentSMinDateCANADA date 
declare @CurrentDateCANADA date
declare @CurrentMinDateCANADA DATE 
declare @CurrentMaxDateCANADA date 
declare @MaxCounterCANADA INT
declare @CounterCANADA INT = 0
declare @CurrentYearStartDateCANADA date
DECLARE @PreviousYearStartDateCANADA date
declare @CurrentYearCANADA int 
declare @CurrentWeekStartDateCANADA date
declare @CurrentWeekEndDateCANADA date
declare @CurrentMonthStartDateCANADA date
declare @CurrentMonthEndDateCANADA date
declare @CurrentQuarterStartDateCANADA date
declare @CurrentQuarterEndDateCANADA date

SELECT @CurrentDMaxDateCANADA =ISNULL(MAX(DateKey), '1900-01-01') FROM [DWCONSDL].[FactGAUMsCTD] WHERE Region = 'CANADA'

SELECT @CurrentSMaxDateCANADA =ISNULL(MAX(VisitDate), '1900-01-01')
, @CurrentSMinDateCANADA =ISNULL(MIN(VisitDate), '1900-01-01') FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA]


IF @CurrentSMinDateCANADA > @CurrentDMaxDateCANADA
	SET @CurrentMinDateCANADA = @CurrentSMinDateCANADA
ELSE
	SET @CurrentMinDateCANADA = @CurrentDMaxDateCANADA
	
IF @LoadStartDateCANADA IS NOT NULL
	SET @CurrentMinDateCANADA = @LoadStartDateCANADA
	
IF @LoadEndDateCANADA IS NOT NULL
	SET @CurrentMaxDateCANADA = @LoadEndDateCANADA
ELSE
	SET @CurrentMaxDateCANADA = @CurrentSMaxDateCANADA

SET @MaxCounterCANADA = DATEDIFF(dd, @CurrentMinDateCANADA, @CurrentMaxDateCANADA)

SET @PreviousYearStartDateCANADA	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentMinDateCANADA)-1, 0) 

WHILE ( @CounterCANADA <= @MaxCounterCANADA)
BEGIN
	SET @CurrentDateCANADA = DATEADD(dd, @CounterCANADA, @CurrentMinDateCANADA)
	SET @CurrentYearStartDateCANADA	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentDateCANADA), 0) 

SELECT @CurrentWeekStartDateCANADA = CalYWeekStartDate, @CurrentWeekEndDateCANADA = CalYWeekEndDate
,@CurrentMonthStartDateCANADA = MonthStartDate, @CurrentMonthEndDateCANADA = MonthEndDate
,@CurrentQuarterStartDateCANADA = QuarterStartDate, @CurrentQuarterEndDateCANADA = QuarterEndDate, @CurrentYearCANADA = [Year]
FROM [DW].[DimDateTime] WHERE DateKey = @CurrentDateCANADA;


INSERT INTO #TempFactGAUMsCTDHistory (
			DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
	)
SELECT 	 CONVERT(CHAR(40), '')	AS DWHash
			, CONVERT(CHAR(40), '')	AS DWHashKey
			,'CANADA' AS Region
			, @CurrentDateCANADA AS DateKey
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateCANADA AND @CurrentDateCANADA THEN SH.FullVisitorId ELSE NULL END) AS UVsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateCANADA AND @CurrentDateCANADA THEN SH.FullVisitorId ELSE NULL END) AS UVsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateCANADA AND @CurrentDateCANADA THEN SH.FullVisitorId ELSE NULL END) AS UVsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateCANADA AND @CurrentDateCANADA THEN SH.FullVisitorId ELSE NULL END) AS UVsYTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentWeekStartDateCANADA AND @CurrentDateCANADA  THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsWTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentMonthStartDateCANADA AND @CurrentDateCANADA THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsMTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentQuarterStartDateCANADA AND @CurrentDateCANADA THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsQTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentYearStartDateCANADA AND @CurrentDateCANADA THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsYTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateCANADA AND @CurrentDateCANADA  THEN SH.Id ELSE NULL END) AS SessionsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateCANADA AND @CurrentDateCANADA THEN SH.Id ELSE NULL END) AS SessionsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateCANADA AND @CurrentDateCANADA THEN SH.Id ELSE NULL END) AS SessionsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateCANADA AND @CurrentDateCANADA THEN SH.Id ELSE NULL END) AS SessionsYTD
FROM [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SH
--INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SH.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE  SH.VisitDate >= @CurrentYearStartDateCANADA and SH.VisitDate <= @CurrentDateCANADA
GROUP BY CM.CountryFromHostName

    SET @CounterCANADA  = @CounterCANADA  + 1
END

update #TempFactGAUMsCTDHistory set DWHashKey =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, DateKey), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)
		,DWHash =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, UVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsYTD), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMsCTD
		set	DWBatchID 				= 			@BatchID
		,	DWHash					=			src.DWHash
		,	UVsWTD					=			src.UVsWTD
		,	UVsMTD					=			src.UVsMTD
		,	UVsQTD					=			src.UVsQTD
		,	UVsYTD					=			src.UVsYTD
		,   UPVsWTD					=			src.UPVsWTD
		,   UPVsMTD					=			src.UPVsMTD
		,   UPVsQTD					=			src.UPVsQTD
		,   UPVsYTD					=			src.UPVsYTD
		,   SessionsWTD				=			src.SessionsWTD
		,   SessionsMTD				=			src.SessionsMTD
		,   SessionsQTD				=			src.SessionsQTD
		,   SessionsYTD				=			src.SessionsYTD
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where DWCONSDL.FactGAUMsCTD.DWHashKey = src.DWHashKey
		and DWCONSDL.FactGAUMsCTD.DWHash != src.DWHash
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_CANADA');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_CANADA', @rc = @RowsUpdated_CANADA out

	insert into DWCONSDL.FactGAUMsCTD (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where not exists(select * from DWCONSDL.FactGAUMsCTD dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_CANADA');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_CANADA', @rc = @RowsInserted_CANADA out
	
	UPDATE [DWCONSDL].[FactGAUMsCTD]
SET UVsWTDPY = Sub.UVsWTDPY,UVsMTDPY = Sub.UVsMTDPY,UVsQTDPY = Sub.UVsQTDPY,UVsYTDPY = Sub.UVsYTDPY
   ,UPVsWTDPY = Sub.UPVsWTDPY,UPVsMTDPY = Sub.UPVsMTDPY,UPVsQTDPY = Sub.UPVsQTDPY,UPVsYTDPY = Sub.UPVsYTDPY
   ,SessionsWTDPY = Sub.SessionsWTDPY,SessionsMTDPY = Sub.SessionsMTDPY,SessionsQTDPY = Sub.SessionsQTDPY,SessionsYTDPY = Sub.SessionsYTDPY
FROM (
SELECT DWHashKey
		,   LAG(UVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsWTDPY
		,   LAG(UVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsMTDPY
		,   LAG(UVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsQTDPY
		,   LAG(UVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsYTDPY
		,   LAG(UPVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsWTDPY
		,   LAG(UPVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsMTDPY
		,   LAG(UPVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsQTDPY
		,   LAG(UPVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsYTDPY
		,   LAG(SessionsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsWTDPY
		,   LAG(SessionsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsMTDPY
		,   LAG(SessionsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsQTDPY
		,   LAG(SessionsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsYTDPY
     FROM [DWCONSDL].[FactGAUMsCTD] F
	 INNER JOIN [DW].[DimDateTime] D ON F.DateKey = D.DateKey
	 WHERE F.Region = 'CANADA'  AND F.DateKey >=  @PreviousYearStartDateCANADA
	 ) Sub
WHERE [DWCONSDL].[FactGAUMsCTD].DWHashKey = Sub.DWHashKey AND DWBatchID = @BatchID

END


-- US REGION

IF @RunUS = 1
BEGIN

TRUNCATE TABLE #TempFactGAUMsCTDHistory

declare @CurrentDMaxDateUS date 
declare @CurrentSMaxDateUS date 
declare @CurrentSMinDateUS date 
declare @CurrentDateUS date
declare @CurrentMinDateUS DATE 
declare @CurrentMaxDateUS date 
declare @MaxCounterUS INT
declare @CounterUS INT = 0
declare @CurrentYearStartDateUS date
DECLARE @PreviousYearStartDateUS date
declare @CurrentYearUS int 
declare @CurrentWeekStartDateUS date
declare @CurrentWeekEndDateUS date
declare @CurrentMonthStartDateUS date
declare @CurrentMonthEndDateUS date
declare @CurrentQuarterStartDateUS date
declare @CurrentQuarterEndDateUS date

SELECT @CurrentDMaxDateUS =ISNULL(MAX(DateKey), '1900-01-01') FROM [DWCONSDL].[FactGAUMsCTD] WHERE Region = 'US'

SELECT @CurrentSMaxDateUS =ISNULL(MAX(VisitDate), '1900-01-01')
, @CurrentSMinDateUS =ISNULL(MIN(VisitDate), '1900-01-01') FROM [SrcGoogleBigQuery].[GA_Sessionhits_US]


IF @CurrentSMinDateUS > @CurrentDMaxDateUS
	SET @CurrentMinDateUS = @CurrentSMinDateUS
ELSE
	SET @CurrentMinDateUS = @CurrentDMaxDateUS
	
IF @LoadStartDateUS IS NOT NULL
	SET @CurrentMinDateUS = @LoadStartDateUS
	
IF @LoadEndDateUS IS NOT NULL
	SET @CurrentMaxDateUS = @LoadEndDateUS
ELSE
	SET @CurrentMaxDateUS = @CurrentSMaxDateUS

SET @MaxCounterUS = DATEDIFF(dd, @CurrentMinDateUS, @CurrentMaxDateUS)

SET @PreviousYearStartDateUS	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentMinDateUS)-1, 0) 

WHILE ( @CounterUS <= @MaxCounterUS)
BEGIN
	SET @CurrentDateUS = DATEADD(dd, @CounterUS, @CurrentMinDateUS)
	SET @CurrentYearStartDateUS	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentDateUS), 0) 

SELECT @CurrentWeekStartDateUS = CalYWeekStartDate, @CurrentWeekEndDateUS = CalYWeekEndDate
,@CurrentMonthStartDateUS = MonthStartDate, @CurrentMonthEndDateUS = MonthEndDate
,@CurrentQuarterStartDateUS = QuarterStartDate, @CurrentQuarterEndDateUS = QuarterEndDate, @CurrentYearUS = [Year]
FROM [DW].[DimDateTime] WHERE DateKey = @CurrentDateUS;


INSERT INTO #TempFactGAUMsCTDHistory (
			DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
	)
SELECT 	 CONVERT(CHAR(40), '')	AS DWHash
			, CONVERT(CHAR(40), '')	AS DWHashKey
			,'US' AS Region
			, @CurrentDateUS AS DateKey
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateUS AND @CurrentDateUS THEN SH.FullVisitorId ELSE NULL END) AS UVsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateUS AND @CurrentDateUS THEN SH.FullVisitorId ELSE NULL END) AS UVsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateUS AND @CurrentDateUS THEN SH.FullVisitorId ELSE NULL END) AS UVsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateUS AND @CurrentDateUS THEN SH.FullVisitorId ELSE NULL END) AS UVsYTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentWeekStartDateUS AND @CurrentDateUS  THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsWTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentMonthStartDateUS AND @CurrentDateUS THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsMTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentQuarterStartDateUS AND @CurrentDateUS THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsQTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentYearStartDateUS AND @CurrentDateUS THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsYTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateUS AND @CurrentDateUS  THEN SH.Id ELSE NULL END) AS SessionsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateUS AND @CurrentDateUS THEN SH.Id ELSE NULL END) AS SessionsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateUS AND @CurrentDateUS THEN SH.Id ELSE NULL END) AS SessionsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateUS AND @CurrentDateUS THEN SH.Id ELSE NULL END) AS SessionsYTD
FROM [SrcGoogleBigQuery].[GA_Sessionhits_US] SH
--INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SH.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE  SH.VisitDate >= @CurrentYearStartDateUS and SH.VisitDate <= @CurrentDateUS
GROUP BY CM.CountryFromHostName

    SET @CounterUS  = @CounterUS  + 1
END

update #TempFactGAUMsCTDHistory set DWHashKey =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, DateKey), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)
		,DWHash =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, UVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsYTD), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMsCTD
		set	DWBatchID 				= 			@BatchID
		,	DWHash					=			src.DWHash
		,	UVsWTD					=			src.UVsWTD
		,	UVsMTD					=			src.UVsMTD
		,	UVsQTD					=			src.UVsQTD
		,	UVsYTD					=			src.UVsYTD
		,   UPVsWTD					=			src.UPVsWTD
		,   UPVsMTD					=			src.UPVsMTD
		,   UPVsQTD					=			src.UPVsQTD
		,   UPVsYTD					=			src.UPVsYTD
		,   SessionsWTD				=			src.SessionsWTD
		,   SessionsMTD				=			src.SessionsMTD
		,   SessionsQTD				=			src.SessionsQTD
		,   SessionsYTD				=			src.SessionsYTD
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where DWCONSDL.FactGAUMsCTD.DWHashKey = src.DWHashKey
		and DWCONSDL.FactGAUMsCTD.DWHash != src.DWHash
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_US');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_US', @rc = @RowsUpdated_US out

	insert into DWCONSDL.FactGAUMsCTD (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where not exists(select * from DWCONSDL.FactGAUMsCTD dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_US');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_US', @rc = @RowsInserted_US out
	
	UPDATE [DWCONSDL].[FactGAUMsCTD]
SET UVsWTDPY = Sub.UVsWTDPY,UVsMTDPY = Sub.UVsMTDPY,UVsQTDPY = Sub.UVsQTDPY,UVsYTDPY = Sub.UVsYTDPY
   ,UPVsWTDPY = Sub.UPVsWTDPY,UPVsMTDPY = Sub.UPVsMTDPY,UPVsQTDPY = Sub.UPVsQTDPY,UPVsYTDPY = Sub.UPVsYTDPY
   ,SessionsWTDPY = Sub.SessionsWTDPY,SessionsMTDPY = Sub.SessionsMTDPY,SessionsQTDPY = Sub.SessionsQTDPY,SessionsYTDPY = Sub.SessionsYTDPY
FROM (
SELECT DWHashKey
		,   LAG(UVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsWTDPY
		,   LAG(UVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsMTDPY
		,   LAG(UVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsQTDPY
		,   LAG(UVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsYTDPY
		,   LAG(UPVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsWTDPY
		,   LAG(UPVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsMTDPY
		,   LAG(UPVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsQTDPY
		,   LAG(UPVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsYTDPY
		,   LAG(SessionsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsWTDPY
		,   LAG(SessionsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsMTDPY
		,   LAG(SessionsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsQTDPY
		,   LAG(SessionsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsYTDPY
     FROM [DWCONSDL].[FactGAUMsCTD] F
	 INNER JOIN [DW].[DimDateTime] D ON F.DateKey = D.DateKey
	 WHERE F.Region = 'US'  AND F.DateKey >=  @PreviousYearStartDateUS
	 ) Sub
WHERE [DWCONSDL].[FactGAUMsCTD].DWHashKey = Sub.DWHashKey AND DWBatchID = @BatchID

END


-- BRAZIL REGION

IF @RunBRAZIL = 1
BEGIN

TRUNCATE TABLE #TempFactGAUMsCTDHistory

declare @CurrentDMaxDateBRAZIL date 
declare @CurrentSMaxDateBRAZIL date 
declare @CurrentSMinDateBRAZIL date 
declare @CurrentDateBRAZIL date
declare @CurrentMinDateBRAZIL DATE 
declare @CurrentMaxDateBRAZIL date 
declare @MaxCounterBRAZIL INT
declare @CounterBRAZIL INT = 0
declare @CurrentYearStartDateBRAZIL date
DECLARE @PreviousYearStartDateBRAZIL date
declare @CurrentYearBRAZIL int 
declare @CurrentWeekStartDateBRAZIL date
declare @CurrentWeekEndDateBRAZIL date
declare @CurrentMonthStartDateBRAZIL date
declare @CurrentMonthEndDateBRAZIL date
declare @CurrentQuarterStartDateBRAZIL date
declare @CurrentQuarterEndDateBRAZIL date

SELECT @CurrentDMaxDateBRAZIL =ISNULL(MAX(DateKey), '1900-01-01') FROM [DWCONSDL].[FactGAUMsCTD] WHERE Region = 'BRAZIL'

SELECT @CurrentSMaxDateBRAZIL =ISNULL(MAX(VisitDate), '1900-01-01')
, @CurrentSMinDateBRAZIL =ISNULL(MIN(VisitDate), '1900-01-01') FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL]


IF @CurrentSMinDateBRAZIL > @CurrentDMaxDateBRAZIL
	SET @CurrentMinDateBRAZIL = @CurrentSMinDateBRAZIL
ELSE
	SET @CurrentMinDateBRAZIL = @CurrentDMaxDateBRAZIL
	
IF @LoadStartDateBRAZIL IS NOT NULL
	SET @CurrentMinDateBRAZIL = @LoadStartDateBRAZIL
	
IF @LoadEndDateBRAZIL IS NOT NULL
	SET @CurrentMaxDateBRAZIL = @LoadEndDateBRAZIL
ELSE
	SET @CurrentMaxDateBRAZIL = @CurrentSMaxDateBRAZIL

SET @MaxCounterBRAZIL = DATEDIFF(dd, @CurrentMinDateBRAZIL, @CurrentMaxDateBRAZIL)

SET @PreviousYearStartDateBRAZIL	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentMinDateBRAZIL)-1, 0) 

WHILE ( @CounterBRAZIL <= @MaxCounterBRAZIL)
BEGIN
	SET @CurrentDateBRAZIL = DATEADD(dd, @CounterBRAZIL, @CurrentMinDateBRAZIL)
	SET @CurrentYearStartDateBRAZIL	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentDateBRAZIL), 0) 

SELECT @CurrentWeekStartDateBRAZIL = CalYWeekStartDate, @CurrentWeekEndDateBRAZIL = CalYWeekEndDate
,@CurrentMonthStartDateBRAZIL = MonthStartDate, @CurrentMonthEndDateBRAZIL = MonthEndDate
,@CurrentQuarterStartDateBRAZIL = QuarterStartDate, @CurrentQuarterEndDateBRAZIL = QuarterEndDate, @CurrentYearBRAZIL = [Year]
FROM [DW].[DimDateTime] WHERE DateKey = @CurrentDateBRAZIL;


INSERT INTO #TempFactGAUMsCTDHistory (
			DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
	)
SELECT 	 CONVERT(CHAR(40), '')	AS DWHash
			, CONVERT(CHAR(40), '')	AS DWHashKey
			,'BRAZIL' AS Region
			, @CurrentDateBRAZIL AS DateKey
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateBRAZIL AND @CurrentDateBRAZIL THEN SH.FullVisitorId ELSE NULL END) AS UVsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateBRAZIL AND @CurrentDateBRAZIL THEN SH.FullVisitorId ELSE NULL END) AS UVsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateBRAZIL AND @CurrentDateBRAZIL THEN SH.FullVisitorId ELSE NULL END) AS UVsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateBRAZIL AND @CurrentDateBRAZIL THEN SH.FullVisitorId ELSE NULL END) AS UVsYTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentWeekStartDateBRAZIL AND @CurrentDateBRAZIL  THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsWTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentMonthStartDateBRAZIL AND @CurrentDateBRAZIL THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsMTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentQuarterStartDateBRAZIL AND @CurrentDateBRAZIL THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsQTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentYearStartDateBRAZIL AND @CurrentDateBRAZIL THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsYTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateBRAZIL AND @CurrentDateBRAZIL  THEN SH.Id ELSE NULL END) AS SessionsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateBRAZIL AND @CurrentDateBRAZIL THEN SH.Id ELSE NULL END) AS SessionsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateBRAZIL AND @CurrentDateBRAZIL THEN SH.Id ELSE NULL END) AS SessionsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateBRAZIL AND @CurrentDateBRAZIL THEN SH.Id ELSE NULL END) AS SessionsYTD
FROM [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SH
--INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SH.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE  SH.VisitDate >= @CurrentYearStartDateBRAZIL and SH.VisitDate <= @CurrentDateBRAZIL
GROUP BY CM.CountryFromHostName

    SET @CounterBRAZIL  = @CounterBRAZIL  + 1
END

update #TempFactGAUMsCTDHistory set DWHashKey =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, DateKey), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)
		,DWHash =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, UVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsYTD), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMsCTD
		set	DWBatchID 				= 			@BatchID
		,	DWHash					=			src.DWHash
		,	UVsWTD					=			src.UVsWTD
		,	UVsMTD					=			src.UVsMTD
		,	UVsQTD					=			src.UVsQTD
		,	UVsYTD					=			src.UVsYTD
		,   UPVsWTD					=			src.UPVsWTD
		,   UPVsMTD					=			src.UPVsMTD
		,   UPVsQTD					=			src.UPVsQTD
		,   UPVsYTD					=			src.UPVsYTD
		,   SessionsWTD				=			src.SessionsWTD
		,   SessionsMTD				=			src.SessionsMTD
		,   SessionsQTD				=			src.SessionsQTD
		,   SessionsYTD				=			src.SessionsYTD
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where DWCONSDL.FactGAUMsCTD.DWHashKey = src.DWHashKey
		and DWCONSDL.FactGAUMsCTD.DWHash != src.DWHash
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_BRAZIL');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_BRAZIL', @rc = @RowsUpdated_BRAZIL out

	insert into DWCONSDL.FactGAUMsCTD (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where not exists(select * from DWCONSDL.FactGAUMsCTD dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_BRAZIL');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_BRAZIL', @rc = @RowsInserted_BRAZIL out
	
	UPDATE [DWCONSDL].[FactGAUMsCTD]
SET UVsWTDPY = Sub.UVsWTDPY,UVsMTDPY = Sub.UVsMTDPY,UVsQTDPY = Sub.UVsQTDPY,UVsYTDPY = Sub.UVsYTDPY
   ,UPVsWTDPY = Sub.UPVsWTDPY,UPVsMTDPY = Sub.UPVsMTDPY,UPVsQTDPY = Sub.UPVsQTDPY,UPVsYTDPY = Sub.UPVsYTDPY
   ,SessionsWTDPY = Sub.SessionsWTDPY,SessionsMTDPY = Sub.SessionsMTDPY,SessionsQTDPY = Sub.SessionsQTDPY,SessionsYTDPY = Sub.SessionsYTDPY
FROM (
SELECT DWHashKey
		,   LAG(UVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsWTDPY
		,   LAG(UVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsMTDPY
		,   LAG(UVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsQTDPY
		,   LAG(UVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsYTDPY
		,   LAG(UPVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsWTDPY
		,   LAG(UPVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsMTDPY
		,   LAG(UPVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsQTDPY
		,   LAG(UPVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsYTDPY
		,   LAG(SessionsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsWTDPY
		,   LAG(SessionsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsMTDPY
		,   LAG(SessionsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsQTDPY
		,   LAG(SessionsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsYTDPY
     FROM [DWCONSDL].[FactGAUMsCTD] F
	 INNER JOIN [DW].[DimDateTime] D ON F.DateKey = D.DateKey
	 WHERE F.Region = 'BRAZIL'  AND F.DateKey >=  @PreviousYearStartDateBRAZIL
	 ) Sub
WHERE [DWCONSDL].[FactGAUMsCTD].DWHashKey = Sub.DWHashKey AND DWBatchID = @BatchID

END


-- APAC REGION

IF @RunAPAC = 1
BEGIN

declare @CurrentDMaxDateAPAC date 
declare @CurrentSMaxDateAPAC date 
declare @CurrentSMinDateAPAC date 
declare @CurrentDateAPAC date
declare @CurrentMinDateAPAC DATE 
declare @CurrentMaxDateAPAC date 
declare @MaxCounterAPAC INT
declare @CounterAPAC INT = 0
declare @CurrentYearStartDateAPAC date
DECLARE @PreviousYearStartDateAPAC date
declare @CurrentYearAPAC int 
declare @CurrentWeekStartDateAPAC date
declare @CurrentWeekEndDateAPAC date
declare @CurrentMonthStartDateAPAC date
declare @CurrentMonthEndDateAPAC date
declare @CurrentQuarterStartDateAPAC date
declare @CurrentQuarterEndDateAPAC date

SELECT @CurrentDMaxDateAPAC =ISNULL(MAX(DateKey), '1900-01-01') FROM [DWCONSDL].[FactGAUMsCTD] WHERE Region = 'APAC'

SELECT @CurrentSMaxDateAPAC =ISNULL(MAX(VisitDate), '1900-01-01')
, @CurrentSMinDateAPAC =ISNULL(MIN(VisitDate), '1900-01-01') FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC]


IF @CurrentSMinDateAPAC > @CurrentDMaxDateAPAC
	SET @CurrentMinDateAPAC = @CurrentSMinDateAPAC
ELSE
	SET @CurrentMinDateAPAC = @CurrentDMaxDateAPAC
	
IF @LoadStartDateAPAC IS NOT NULL
	SET @CurrentMinDateAPAC = @LoadStartDateAPAC
	
IF @LoadEndDateAPAC IS NOT NULL
	SET @CurrentMaxDateAPAC = @LoadEndDateAPAC
ELSE
	SET @CurrentMaxDateAPAC = @CurrentSMaxDateAPAC

SET @MaxCounterAPAC = DATEDIFF(dd, @CurrentMinDateAPAC, @CurrentMaxDateAPAC)

SET @PreviousYearStartDateAPAC	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentMinDateAPAC)-1, 0) 

WHILE ( @CounterAPAC <= @MaxCounterAPAC)
BEGIN
	SET @CurrentDateAPAC = DATEADD(dd, @CounterAPAC, @CurrentMinDateAPAC)
	SET @CurrentYearStartDateAPAC	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentDateAPAC), 0) 

SELECT @CurrentWeekStartDateAPAC = CalYWeekStartDate, @CurrentWeekEndDateAPAC = CalYWeekEndDate
,@CurrentMonthStartDateAPAC = MonthStartDate, @CurrentMonthEndDateAPAC = MonthEndDate
,@CurrentQuarterStartDateAPAC = QuarterStartDate, @CurrentQuarterEndDateAPAC = QuarterEndDate, @CurrentYearAPAC = [Year]
FROM [DW].[DimDateTime] WHERE DateKey = @CurrentDateAPAC;


INSERT INTO #TempFactGAUMsCTDHistory (
			DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
	)
SELECT 	 CONVERT(CHAR(40), '')	AS DWHash
			, CONVERT(CHAR(40), '')	AS DWHashKey
			,'APAC' AS Region
			, @CurrentDateAPAC AS DateKey
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateAPAC AND @CurrentDateAPAC THEN SH.FullVisitorId ELSE NULL END) AS UVsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateAPAC AND @CurrentDateAPAC THEN SH.FullVisitorId ELSE NULL END) AS UVsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateAPAC AND @CurrentDateAPAC THEN SH.FullVisitorId ELSE NULL END) AS UVsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateAPAC AND @CurrentDateAPAC THEN SH.FullVisitorId ELSE NULL END) AS UVsYTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentWeekStartDateAPAC AND @CurrentDateAPAC  THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsWTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentMonthStartDateAPAC AND @CurrentDateAPAC THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsMTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentQuarterStartDateAPAC AND @CurrentDateAPAC THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsQTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentYearStartDateAPAC AND @CurrentDateAPAC THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsYTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateAPAC AND @CurrentDateAPAC  THEN SH.Id ELSE NULL END) AS SessionsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateAPAC AND @CurrentDateAPAC THEN SH.Id ELSE NULL END) AS SessionsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateAPAC AND @CurrentDateAPAC THEN SH.Id ELSE NULL END) AS SessionsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateAPAC AND @CurrentDateAPAC THEN SH.Id ELSE NULL END) AS SessionsYTD
FROM [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SH
--INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SH.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE  SH.VisitDate >= @CurrentYearStartDateAPAC and SH.VisitDate <= @CurrentDateAPAC
GROUP BY CM.CountryFromHostName

    SET @CounterAPAC  = @CounterAPAC  + 1
END

update #TempFactGAUMsCTDHistory set DWHashKey =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, DateKey), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)
		,DWHash =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, UVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsYTD), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMsCTD
		set	DWBatchID 				= 			@BatchID
		,	DWHash					=			src.DWHash
		,	UVsWTD					=			src.UVsWTD
		,	UVsMTD					=			src.UVsMTD
		,	UVsQTD					=			src.UVsQTD
		,	UVsYTD					=			src.UVsYTD
		,   UPVsWTD					=			src.UPVsWTD
		,   UPVsMTD					=			src.UPVsMTD
		,   UPVsQTD					=			src.UPVsQTD
		,   UPVsYTD					=			src.UPVsYTD
		,   SessionsWTD				=			src.SessionsWTD
		,   SessionsMTD				=			src.SessionsMTD
		,   SessionsQTD				=			src.SessionsQTD
		,   SessionsYTD				=			src.SessionsYTD
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where DWCONSDL.FactGAUMsCTD.DWHashKey = src.DWHashKey
		and DWCONSDL.FactGAUMsCTD.DWHash != src.DWHash
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_APAC');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_APAC', @rc = @RowsUpdated_APAC out

	insert into DWCONSDL.FactGAUMsCTD (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where not exists(select * from DWCONSDL.FactGAUMsCTD dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_APAC');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_APAC', @rc = @RowsInserted_APAC out
	
	UPDATE [DWCONSDL].[FactGAUMsCTD]
SET UVsWTDPY = Sub.UVsWTDPY,UVsMTDPY = Sub.UVsMTDPY,UVsQTDPY = Sub.UVsQTDPY,UVsYTDPY = Sub.UVsYTDPY
   ,UPVsWTDPY = Sub.UPVsWTDPY,UPVsMTDPY = Sub.UPVsMTDPY,UPVsQTDPY = Sub.UPVsQTDPY,UPVsYTDPY = Sub.UPVsYTDPY
   ,SessionsWTDPY = Sub.SessionsWTDPY,SessionsMTDPY = Sub.SessionsMTDPY,SessionsQTDPY = Sub.SessionsQTDPY,SessionsYTDPY = Sub.SessionsYTDPY
FROM (
SELECT DWHashKey
		,   LAG(UVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsWTDPY
		,   LAG(UVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsMTDPY
		,   LAG(UVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsQTDPY
		,   LAG(UVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsYTDPY
		,   LAG(UPVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsWTDPY
		,   LAG(UPVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsMTDPY
		,   LAG(UPVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsQTDPY
		,   LAG(UPVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsYTDPY
		,   LAG(SessionsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsWTDPY
		,   LAG(SessionsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsMTDPY
		,   LAG(SessionsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsQTDPY
		,   LAG(SessionsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsYTDPY
     FROM [DWCONSDL].[FactGAUMsCTD] F
	 INNER JOIN [DW].[DimDateTime] D ON F.DateKey = D.DateKey
	 WHERE F.Region = 'APAC'  AND F.DateKey >=  @PreviousYearStartDateAPAC
	 ) Sub
WHERE [DWCONSDL].[FactGAUMsCTD].DWHashKey = Sub.DWHashKey AND DWBatchID = @BatchID

END

-- LATAM REGION

IF @RunLATAM = 1
BEGIN

declare @CurrentDMaxDateLATAM date 
declare @CurrentSMaxDateLATAM date 
declare @CurrentSMinDateLATAM date 
declare @CurrentDateLATAM date
declare @CurrentMinDateLATAM DATE 
declare @CurrentMaxDateLATAM date 
declare @MaxCounterLATAM INT
declare @CounterLATAM INT = 0
declare @CurrentYearStartDateLATAM date
DECLARE @PreviousYearStartDateLATAM date
declare @CurrentYearLATAM int 
declare @CurrentWeekStartDateLATAM date
declare @CurrentWeekEndDateLATAM date
declare @CurrentMonthStartDateLATAM date
declare @CurrentMonthEndDateLATAM date
declare @CurrentQuarterStartDateLATAM date
declare @CurrentQuarterEndDateLATAM date

SELECT @CurrentDMaxDateLATAM =ISNULL(MAX(DateKey), '1900-01-01') FROM [DWCONSDL].[FactGAUMsCTD] WHERE Region = 'LATAM'

SELECT @CurrentSMaxDateLATAM =ISNULL(MAX(VisitDate), '1900-01-01')
, @CurrentSMinDateLATAM =ISNULL(MIN(VisitDate), '1900-01-01') FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM]


IF @CurrentSMinDateLATAM > @CurrentDMaxDateLATAM
	SET @CurrentMinDateLATAM = @CurrentSMinDateLATAM
ELSE
	SET @CurrentMinDateLATAM = @CurrentDMaxDateLATAM
	
IF @LoadStartDateLATAM IS NOT NULL
	SET @CurrentMinDateLATAM = @LoadStartDateLATAM
	
IF @LoadEndDateLATAM IS NOT NULL
	SET @CurrentMaxDateLATAM = @LoadEndDateLATAM
ELSE
	SET @CurrentMaxDateLATAM = @CurrentSMaxDateLATAM

SET @MaxCounterLATAM = DATEDIFF(dd, @CurrentMinDateLATAM, @CurrentMaxDateLATAM)

SET @PreviousYearStartDateLATAM	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentMinDateLATAM)-1, 0) 

WHILE ( @CounterLATAM <= @MaxCounterLATAM)
BEGIN
	SET @CurrentDateLATAM = DATEADD(dd, @CounterLATAM, @CurrentMinDateLATAM)
	SET @CurrentYearStartDateLATAM	= DATEADD(yy, DATEDIFF(yy, 0, @CurrentDateLATAM), 0) 

SELECT @CurrentWeekStartDateLATAM = CalYWeekStartDate, @CurrentWeekEndDateLATAM = CalYWeekEndDate
,@CurrentMonthStartDateLATAM = MonthStartDate, @CurrentMonthEndDateLATAM = MonthEndDate
,@CurrentQuarterStartDateLATAM = QuarterStartDate, @CurrentQuarterEndDateLATAM = QuarterEndDate, @CurrentYearLATAM = [Year]
FROM [DW].[DimDateTime] WHERE DateKey = @CurrentDateLATAM;


INSERT INTO #TempFactGAUMsCTDHistory (
			DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
	)
SELECT 	 CONVERT(CHAR(40), '')	AS DWHash
			, CONVERT(CHAR(40), '')	AS DWHashKey
			,'LATAM' AS Region
			, @CurrentDateLATAM AS DateKey
			,   CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateLATAM AND @CurrentDateLATAM THEN SH.FullVisitorId ELSE NULL END) AS UVsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateLATAM AND @CurrentDateLATAM THEN SH.FullVisitorId ELSE NULL END) AS UVsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateLATAM AND @CurrentDateLATAM THEN SH.FullVisitorId ELSE NULL END) AS UVsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateLATAM AND @CurrentDateLATAM THEN SH.FullVisitorId ELSE NULL END) AS UVsYTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentWeekStartDateLATAM AND @CurrentDateLATAM  THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsWTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentMonthStartDateLATAM AND @CurrentDateLATAM THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsMTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentQuarterStartDateLATAM AND @CurrentDateLATAM THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsQTD
			,	COUNT(DISTINCT CASE WHEN [SH].[Type] = 'PAGE' AND SH.VisitDate BETWEEN @CurrentYearStartDateLATAM AND @CurrentDateLATAM THEN CONCAT(SH.Id,Pagepath) ELSE NULL END) AS UPVsYTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentWeekStartDateLATAM AND @CurrentDateLATAM  THEN SH.Id ELSE NULL END) AS SessionsWTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentMonthStartDateLATAM AND @CurrentDateLATAM THEN SH.Id ELSE NULL END) AS SessionsMTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentQuarterStartDateLATAM AND @CurrentDateLATAM THEN SH.Id ELSE NULL END) AS SessionsQTD
			,	COUNT(DISTINCT CASE WHEN SH.VisitDate BETWEEN @CurrentYearStartDateLATAM AND @CurrentDateLATAM THEN SH.Id ELSE NULL END) AS SessionsYTD
FROM [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SH
--INNER JOIN [DW].[DimDateTime] DDT ON CONVERT(DATE, SH.VisitDate) = DDT.DateKey
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE  SH.VisitDate >= @CurrentYearStartDateLATAM and SH.VisitDate <= @CurrentDateLATAM
GROUP BY CM.CountryFromHostName

    SET @CounterLATAM  = @CounterLATAM  + 1
END

update #TempFactGAUMsCTDHistory set DWHashKey =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, DateKey), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)
		,DWHash =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, UVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, UPVsYTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsWTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsMTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsQTD), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SessionsYTD), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAUMsCTD
		set	DWBatchID 				= 			@BatchID
		,	DWHash					=			src.DWHash
		,	UVsWTD					=			src.UVsWTD
		,	UVsMTD					=			src.UVsMTD
		,	UVsQTD					=			src.UVsQTD
		,	UVsYTD					=			src.UVsYTD
		,   UPVsWTD					=			src.UPVsWTD
		,   UPVsMTD					=			src.UPVsMTD
		,   UPVsQTD					=			src.UPVsQTD
		,   UPVsYTD					=			src.UPVsYTD
		,   SessionsWTD				=			src.SessionsWTD
		,   SessionsMTD				=			src.SessionsMTD
		,   SessionsQTD				=			src.SessionsQTD
		,   SessionsYTD				=			src.SessionsYTD
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where DWCONSDL.FactGAUMsCTD.DWHashKey = src.DWHashKey
		and DWCONSDL.FactGAUMsCTD.DWHash != src.DWHash
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_LATAM');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Update_LATAM', @rc = @RowsUpdated_LATAM out

	insert into DWCONSDL.FactGAUMsCTD (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	Region
		,	DateKey
		,	CountryFromHostName
		,	UVsWTD
		,	UVsMTD
		,	UVsQTD
		,	UVsYTD
		,	UPVsWTD
		,	UPVsMTD
		,	UPVsQTD
		,	UPVsYTD
		,	SessionsWTD
		,	SessionsMTD
		,	SessionsQTD
		,	SessionsYTD
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAUMsCTDHistory src
	where not exists(select * from DWCONSDL.FactGAUMsCTD dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_LATAM');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAUMsCTDHistory_Insert_LATAM', @rc = @RowsInserted_LATAM out
	
	UPDATE [DWCONSDL].[FactGAUMsCTD]
SET UVsWTDPY = Sub.UVsWTDPY,UVsMTDPY = Sub.UVsMTDPY,UVsQTDPY = Sub.UVsQTDPY,UVsYTDPY = Sub.UVsYTDPY
   ,UPVsWTDPY = Sub.UPVsWTDPY,UPVsMTDPY = Sub.UPVsMTDPY,UPVsQTDPY = Sub.UPVsQTDPY,UPVsYTDPY = Sub.UPVsYTDPY
   ,SessionsWTDPY = Sub.SessionsWTDPY,SessionsMTDPY = Sub.SessionsMTDPY,SessionsQTDPY = Sub.SessionsQTDPY,SessionsYTDPY = Sub.SessionsYTDPY
FROM (
SELECT DWHashKey
		,   LAG(UVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsWTDPY
		,   LAG(UVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsMTDPY
		,   LAG(UVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsQTDPY
		,   LAG(UVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UVsYTDPY
		,   LAG(UPVsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsWTDPY
		,   LAG(UPVsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsMTDPY
		,   LAG(UPVsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsQTDPY
		,   LAG(UPVsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS UPVsYTDPY
		,   LAG(SessionsWTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsWTDPY
		,   LAG(SessionsMTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsMTDPY
		,   LAG(SessionsQTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsQTDPY
		,   LAG(SessionsYTD) OVER (PARTITION BY Region, CountryFromHostName,D.MonthOfYear,D.DayOfMonth ORDER BY  D.Year) AS SessionsYTDPY
     FROM [DWCONSDL].[FactGAUMsCTD] F
	 INNER JOIN [DW].[DimDateTime] D ON F.DateKey = D.DateKey
	 WHERE F.Region = 'LATAM'  AND F.DateKey >=  @PreviousYearStartDateLATAM
	 ) Sub
WHERE [DWCONSDL].[FactGAUMsCTD].DWHashKey = Sub.DWHashKey AND DWBatchID = @BatchID

END

SET @RowsInserted = @RowsInserted_EMEA + @RowsInserted_CANADA + @RowsInserted_US + @RowsInserted_BRAZIL + @RowsInserted_APAC + @RowsInserted_LATAM
SET @RowsUpdated = @RowsUpdated_EMEA + @RowsUpdated_CANADA + @RowsUpdated_US + @RowsUpdated_BRAZIL + @RowsUpdated_APAC + @RowsUpdated_LATAM
	
SELECT @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

