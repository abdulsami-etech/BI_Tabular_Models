CREATE PROC [DWCONSDL].[LoadFactGASessions] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		
	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id ('DWCONSDL.Temp_FactGASessions', 'U') is not null
		drop table DWCONSDL.Temp_FactGASessions

	create table DWCONSDL.Temp_FactGASessions with (distribution = round_robin, heap) as 
	
SELECT  		CONVERT(CHAR(40), '')	AS DWHash
			,	CONVERT(CHAR(40), '')	AS DWHashKey
			,	FullVisitorId
			,	'CANADA' AS Region
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	SUM(Visits) AS VisitsInADay
			,	SUM(NewVisits) AS NewVisitsInADay
			,	SUM(Hits) AS HitsInADay
			,	SUM(PageViews) AS PageViewsInADay
			,	SUM(ScreenViews) AS ScreenViewsInADay
			,	SUM(TimeonSite) AS TimeonSiteInADay
			,	SUM(Bounces) AS BouncesInADay
FROM (SELECT DISTINCT FullVisitorId
			,	CONVERT(DATE, A.VisitDate) AS VisitDate
			,   VisitId
			,	Medium
			,	Source
			,	ChannelGrouping
			,	B.CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	Visits
			,	NewVisits
			,	Hits
			,	PageViews
			,	ScreenViews
			,	TimeonSite
			,	Bounces

FROM [SrcGoogleBigQuery].[GA_Sessions_CANADA] A
INNER JOIN 
(SELECT DISTINCT SH.Id, SH.VisitNumber, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of CANADA' END AS CountryFromHostName FROM  [SrcGoogleBigQuery].[GA_Sessionhits_CANADA] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'CANADA' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from DWCONSDL.FactGASessions WHERE Region = 'CANADA')) B
ON A.Id = B.Id AND A.VisitNumber = B.VisitNumber
WHERE A.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM DWCONSDL.FactGASessions WHERE Region = 'CANADA' )
 )  C
GROUP BY FullVisitorId
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			
UNION ALL

SELECT  		CONVERT(CHAR(40), '')	AS DWHash
			,	CONVERT(CHAR(40), '')	AS DWHashKey
			,	FullVisitorId
			,	'EMEA' AS Region
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	SUM(Visits) AS VisitsInADay
			,	SUM(NewVisits) AS NewVisitsInADay
			,	SUM(Hits) AS HitsInADay
			,	SUM(PageViews) AS PageViewsInADay
			,	SUM(ScreenViews) AS ScreenViewsInADay
			,	SUM(TimeonSite) AS TimeonSiteInADay
			,	SUM(Bounces) AS BouncesInADay
FROM (SELECT DISTINCT FullVisitorId
			,	CONVERT(DATE, A.VisitDate) AS VisitDate
			,   VisitId
			,	Medium
			,	Source
			,	ChannelGrouping
			,	B.CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	Visits
			,	NewVisits
			,	Hits
			,	PageViews
			,	ScreenViews
			,	TimeonSite
			,	Bounces

FROM [SrcGoogleBigQuery].[GA_Sessions_EMEA] A
INNER JOIN 
(SELECT DISTINCT SH.Id, SH.VisitNumber, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of EMEA' END AS CountryFromHostName FROM  [SrcGoogleBigQuery].[GA_Sessionhits_EMEA] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'EMEA' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from DWCONSDL.FactGASessions WHERE Region = 'EMEA')) B
ON A.Id = B.Id AND A.VisitNumber = B.VisitNumber
WHERE A.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM DWCONSDL.FactGASessions WHERE Region = 'EMEA' )
 )  C
GROUP BY FullVisitorId
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language

UNION ALL

SELECT  		CONVERT(CHAR(40), '')	AS DWHash
			,	CONVERT(CHAR(40), '')	AS DWHashKey
			,	FullVisitorId
			,	'US' AS Region
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	SUM(Visits) AS VisitsInADay
			,	SUM(NewVisits) AS NewVisitsInADay
			,	SUM(Hits) AS HitsInADay
			,	SUM(PageViews) AS PageViewsInADay
			,	SUM(ScreenViews) AS ScreenViewsInADay
			,	SUM(TimeonSite) AS TimeonSiteInADay
			,	SUM(Bounces) AS BouncesInADay
FROM (SELECT DISTINCT FullVisitorId
			,	CONVERT(DATE, A.VisitDate) AS VisitDate
			,   VisitId
			,	Medium
			,	Source
			,	ChannelGrouping
			,	B.CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	Visits
			,	NewVisits
			,	Hits
			,	PageViews
			,	ScreenViews
			,	TimeonSite
			,	Bounces

FROM [SrcGoogleBigQuery].[GA_Sessions_US] A
INNER JOIN 
(SELECT DISTINCT SH.Id, SH.VisitNumber, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of US' END AS CountryFromHostName FROM  [SrcGoogleBigQuery].[GA_Sessionhits_US] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'US' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from DWCONSDL.FactGASessions WHERE Region = 'US')) B
ON A.Id = B.Id AND A.VisitNumber = B.VisitNumber
WHERE A.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM DWCONSDL.FactGASessions WHERE Region = 'US' )
 )  C
GROUP BY FullVisitorId
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language

UNION ALL

SELECT  		CONVERT(CHAR(40), '')	AS DWHash
			,	CONVERT(CHAR(40), '')	AS DWHashKey
			,	FullVisitorId
			,	'BRAZIL' AS Region
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	SUM(Visits) AS VisitsInADay
			,	SUM(NewVisits) AS NewVisitsInADay
			,	SUM(Hits) AS HitsInADay
			,	SUM(PageViews) AS PageViewsInADay
			,	SUM(ScreenViews) AS ScreenViewsInADay
			,	SUM(TimeonSite) AS TimeonSiteInADay
			,	SUM(Bounces) AS BouncesInADay
FROM (SELECT DISTINCT FullVisitorId
			,	CONVERT(DATE, A.VisitDate) AS VisitDate
			,   VisitId
			,	Medium
			,	Source
			,	ChannelGrouping
			,	B.CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	Visits
			,	NewVisits
			,	Hits
			,	PageViews
			,	ScreenViews
			,	TimeonSite
			,	Bounces

FROM [SrcGoogleBigQuery].[GA_Sessions_BRAZIL] A
INNER JOIN 
(SELECT DISTINCT SH.Id, SH.VisitNumber, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of BRAZIL' END AS CountryFromHostName FROM  [SrcGoogleBigQuery].[GA_Sessionhits_BRAZIL] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'BRAZIL' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from DWCONSDL.FactGASessions WHERE Region = 'BRAZIL')) B
ON A.Id = B.Id AND A.VisitNumber = B.VisitNumber
WHERE A.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM DWCONSDL.FactGASessions WHERE Region = 'BRAZIL' )
 )  C
GROUP BY FullVisitorId
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			
UNION ALL

SELECT  		CONVERT(CHAR(40), '')	AS DWHash
			,	CONVERT(CHAR(40), '')	AS DWHashKey
			,	FullVisitorId
			,	'APAC' AS Region
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	SUM(Visits) AS VisitsInADay
			,	SUM(NewVisits) AS NewVisitsInADay
			,	SUM(Hits) AS HitsInADay
			,	SUM(PageViews) AS PageViewsInADay
			,	SUM(ScreenViews) AS ScreenViewsInADay
			,	SUM(TimeonSite) AS TimeonSiteInADay
			,	SUM(Bounces) AS BouncesInADay
FROM (SELECT DISTINCT FullVisitorId
			,	CONVERT(DATE, A.VisitDate) AS VisitDate
			,   VisitId
			,	Medium
			,	Source
			,	ChannelGrouping
			,	B.CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	Visits
			,	NewVisits
			,	Hits
			,	PageViews
			,	ScreenViews
			,	TimeonSite
			,	Bounces

FROM [SrcGoogleBigQuery].[GA_Sessions_APAC] A
INNER JOIN 
(SELECT DISTINCT SH.Id, SH.VisitNumber, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of APAC' END AS CountryFromHostName FROM  [SrcGoogleBigQuery].[GA_Sessionhits_APAC] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'APAC' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from DWCONSDL.FactGASessions WHERE Region = 'APAC')) B
ON A.Id = B.Id AND A.VisitNumber = B.VisitNumber
WHERE A.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM DWCONSDL.FactGASessions WHERE Region = 'APAC' )
 )  C
GROUP BY FullVisitorId
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			
UNION ALL

SELECT  		CONVERT(CHAR(40), '')	AS DWHash
			,	CONVERT(CHAR(40), '')	AS DWHashKey
			,	FullVisitorId
			,	'LATAM' AS Region
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	SUM(Visits) AS VisitsInADay
			,	SUM(NewVisits) AS NewVisitsInADay
			,	SUM(Hits) AS HitsInADay
			,	SUM(PageViews) AS PageViewsInADay
			,	SUM(ScreenViews) AS ScreenViewsInADay
			,	SUM(TimeonSite) AS TimeonSiteInADay
			,	SUM(Bounces) AS BouncesInADay
FROM (SELECT DISTINCT FullVisitorId
			,	CONVERT(DATE, A.VisitDate) AS VisitDate
			,   VisitId
			,	Medium
			,	Source
			,	ChannelGrouping
			,	B.CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	Visits
			,	NewVisits
			,	Hits
			,	PageViews
			,	ScreenViews
			,	TimeonSite
			,	Bounces

FROM [SrcGoogleBigQuery].[GA_Sessions_LATAM] A
INNER JOIN 
(SELECT DISTINCT SH.Id, SH.VisitNumber, CASE WHEN CM.CountryFromHostName IS NOT NULL THEN CM.CountryFromHostName ELSE 'Rest of LATAM' END AS CountryFromHostName FROM  [SrcGoogleBigQuery].[GA_Sessionhits_LATAM] SH
LEFT JOIN [DWCONSDL].[GARegionHostNameToCountryMapping] CM ON SH.HostName = CM.HostName AND CM.GARegion = 'LATAM' AND CM.IsValid = 1
WHERE SH.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from DWCONSDL.FactGASessions WHERE Region = 'LATAM')) B
ON A.Id = B.Id AND A.VisitNumber = B.VisitNumber
WHERE A.VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') FROM DWCONSDL.FactGASessions WHERE Region = 'LATAM' )
 )  C
GROUP BY FullVisitorId
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,   City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language			
			
		update DWCONSDL.Temp_FactGASessions set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						  isnull(convert(nvarchar, VisitsInADay), N'N/A')
				  + N'|' + isnull(convert(nvarchar, NewVisitsInADay ), N'N/A')
				  + N'|' + isnull(convert(nvarchar, HitsInADay ), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PageViewsInADay ), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ScreenViewsInADay ), N'N/A')
				  + N'|' + isnull(convert(nvarchar, TimeonSiteInADay), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BouncesInADay ), N'N/A')
				)
			, 2),
			DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, FullVisitorId), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Region), N'N/A')
				  + N'|' + isnull(convert(nvarchar, VisitDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Medium), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Source), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ChannelGrouping), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, City), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Metro), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Latitude), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Longitude), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Browser), N'N/A')
				  + N'|' + isnull(convert(nvarchar, DeviceCategory), N'N/A')
				  + N'|' + isnull(convert(nvarchar, MobileDeviceModel), N'N/A')
				  + N'|' + isnull(convert(nvarchar, MobileDeviceBranding), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Language), N'N/A')
				)
			, 2)

	if not exists (select * from DWCONSDL.FactGASessions where FullVisitorId = '-1')
	begin
		declare @Hash char(40) = ''

		insert into DWCONSDL.FactGASessions (				
				DWBatchID
			,	DWHash
			,	DWHashKey
			,	FullVisitorId
			,   Region
			,	VisitDate
			,	Medium
			,	Source
			,	ChannelGrouping
			,	CountryFromHostName
			,	City
			,	Metro
			,	Latitude
			,	Longitude
			,	Browser
			,	DeviceCategory
			,	MobileDeviceModel
			,	MobileDeviceBranding
			,	Language
			,	VisitsInADay
			,	NewVisitsInADay
			,	HitsInADay
			,	PageViewsInADay
			,	ScreenViewsInADay
			,	TimeonSiteInADay
			,	BouncesInADay
			,	CreatedDate
			,	ModifiedDate
		)
		values (
				@BatchID
			,	@Hash
			,	@Hash
			,	'-1'
			,	N'N/A'
			,	'19000101'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	0
			,	0
			,	0	
			,	0
			,	0
			,	0
			,	0
			,	'9999-12-31'
			,	'9999-12-31'
		)
	end

	update DWCONSDL.FactGASessions
		set	DWBatchID 				= 			@BatchID
		,	DWHash 					= 			src.DWHash
		,	VisitsInADay			=			src.VisitsInADay
		,	NewVisitsInADay			=			src.NewVisitsInADay
		,	HitsInADay				=			src.HitsInADay
		,	PageViewsInADay			=			src.PageViewsInADay
		,	ScreenViewsInADay		=			src.ScreenViewsInADay
		,	TimeonSiteInADay		=			src.TimeonSiteInADay
		,	BouncesInADay			=			src.BouncesInADay
		,	ModifiedDate			=	 		@CurrentDateTime
	from DWCONSDL.Temp_FactGASessions src
	where DWCONSDL.FactGASessions.DWHashKey = src.DWHashKey
		and DWCONSDL.FactGASessions.DWHash != src.DWHash
	option (label = 'DWCONSDL.LoadFactGASessions_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGASessions_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactGASessions (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	FullVisitorId
		,	Region
		,	VisitDate
		,	Medium
		,	Source
		,	ChannelGrouping
		,	CountryFromHostName
		,	City
		,	Metro
		,	Latitude
		,	Longitude
		,	Browser
		,	DeviceCategory
		,	MobileDeviceModel
		,	MobileDeviceBranding
		,	Language
		,	VisitsInADay
		,	NewVisitsInADay
		,	HitsInADay
		,	PageViewsInADay
		,	ScreenViewsInADay
		,	TimeonSiteInADay
		,	BouncesInADay
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	FullVisitorId
		,	Region
		,	VisitDate
		,	Medium
		,	Source
		,	ChannelGrouping
		,	CountryFromHostName
		,	City
		,	Metro
		,	Latitude
		,	Longitude
		,	Browser
		,	DeviceCategory
		,	MobileDeviceModel
		,	MobileDeviceBranding
		,	Language
		,	VisitsInADay
		,   NewVisitsInADay
		,	HitsInADay
		,	PageViewsInADay
		,	ScreenViewsInADay
		,	TimeonSiteInADay
		,	BouncesInADay
		,	@CurrentDateTime
		,	@CurrentDateTime
	from DWCONSDL.Temp_FactGASessions src
	where not exists(select * from DWCONSDL.FactGASessions dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadFactGASessions_Insert');
	
	if object_id ('DWCONSDL.Temp_FactGASessions', 'U') is not null
		drop table DWCONSDL.Temp_FactGASessions

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGASessions_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end