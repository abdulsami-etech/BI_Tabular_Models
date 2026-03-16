CREATE PROC [DWCONSDL].[LoadGASessionHits] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
		
	if object_id ('DWCONSDL.Temp_GASessionHits', 'U') is not null
		drop table DWCONSDL.Temp_GASessionHits

	create table DWCONSDL.Temp_GASessionHits with (distribution = round_robin, heap) as 
	
SELECT DWHash
			, DWHashKey
			, Id
			, GARegion
			, FullVisitorId
			, VisitNumber
			, VisitId
			, VisitStartTime
			, VisitStartDateTime
			, VisitDate
			, DataSource
			, ExperimentId
			, ExperimentVariant
			, HitNumber
			, [Hour]
			, IsEntrance
			, IsExit
			, IsInteraction
			, [Minute]
			, [Time]
			, Referer
			, HasSocialSourceReferral
			, SocialInteractionAction
			, SocialNetwork
			, [Type]
			, PagePath
			, PagePathLevel1
			, PagePathLevel2
			, PagePathLevel3
			, PagePathLevel4
			, PageTitle
			, SearchKeyword
			, EventCategory
			, EventAction
			, EventLabel
			, EventValue
			, [Index]
			, [Value]
			, Source
			, AdContent
			, Medium
			, ChannelGrouping
			, Campaign
			, DeviceCategory
			, Country
			, Hostname
			, CountryFromHostName
FROM [SrcGoogleBigQuery].[GASessionHits]


update DWCONSDL.Temp_GASessionHits set DWHash=
		convert(char(40),
			hashbytes('SHA1',    isnull(convert(nvarchar, FullVisitorId), N'N/A')
						+ N'|' + isnull(convert(nvarchar, VisitId), N'N/A')
						+ N'|' + isnull(convert(nvarchar, VisitStartTime), N'N/A')
						+ N'|' + isnull(convert(nvarchar, VisitStartDateTime), N'N/A')
						+ N'|' + isnull(convert(nvarchar, VisitDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, DataSource), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ExperimentVariant), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [Hour]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsEntrance), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsExit), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsInteraction), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [Minute]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [Time]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, Referer), N'N/A')
						+ N'|' + isnull(convert(nvarchar, HasSocialSourceReferral), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SocialInteractionAction), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SocialNetwork), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [Type]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PagePath), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PagePathLevel1), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PagePathLevel2), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PagePathLevel3), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PagePathLevel4), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PageTitle), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SearchKeyword), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventCategory), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventAction), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventLabel), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EventValue), N'N/A')
						+ N'|' + isnull(convert(nvarchar, [Value]), N'N/A')
						+ N'|' + isnull(convert(nvarchar, Source), N'N/A')
						+ N'|' + isnull(convert(nvarchar, AdContent), N'N/A')
						+ N'|' + isnull(convert(nvarchar, Medium), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ChannelGrouping), N'N/A')
						+ N'|' + isnull(convert(nvarchar, Campaign), N'N/A')
						+ N'|' + isnull(convert(nvarchar, DeviceCategory), N'N/A')
						+ N'|' + isnull(convert(nvarchar, Country), N'N/A')
						+ N'|' + isnull(convert(nvarchar, Hostname), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CountryFromHostName), N'N/A')
				)
			, 2)
			
update DWCONSDL.Temp_GASessionHits set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, GARegion), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Id), N'N/A')
				  + N'|' + isnull(convert(nvarchar, VisitNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, HitNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ExperimentId), N'N/A')
				  + N'|' + isnull(convert(nvarchar, [Index]), N'N/A')
				)
			, 2)

	
	update DWCONSDL.GASessionHits
		set	DWBatchID 					= 	 @BatchID
		,	DWHash    					=    src.DWHash
		,	FullVisitorId    			=    src.FullVisitorId
		,	VisitId    					=    src.VisitId
		,	VisitStartTime    			=    src.VisitStartTime
		,	VisitStartDateTime    		=    src.VisitStartDateTime
		,	VisitDate    				=    src.VisitDate
		,	DataSource    				=    src.DataSource
		,	ExperimentVariant    		=    src.ExperimentVariant
		,	[Hour]   					=    src.Hour
		,	IsEntrance    				=    src.IsEntrance
		,	IsExit    					=    src.IsExit
		,	IsInteraction   			=    src.IsInteraction
		,	[Minute]    				=    src.Minute
		,	[Time]    					=    src.Time
		,	Referer    					=    src.Referer
		,	HasSocialSourceReferral   	=    src.HasSocialSourceReferral
		,	SocialInteractionAction    	=    src.SocialInteractionAction
		,	SocialNetwork    			=    src.SocialNetwork
		,	[Type]    					=    src.Type
		,	PagePath    				=    src.PagePath
		,	PagePathLevel1    			=    src.PagePathLevel1
		,	PagePathLevel2    			=    src.PagePathLevel2
		,	PagePathLevel3    			=    src.PagePathLevel3
		,	PagePathLevel4    			=    src.PagePathLevel4
		,	PageTitle    				=    src.PageTitle
		,	SearchKeyword    			=    src.SearchKeyword
		,	EventCategory    			=    src.EventCategory
		,	EventAction    				=    src.EventAction
		,	EventLabel    				=    src.EventLabel
		,	EventValue    				=    src.EventValue
		,	[Value]    					=    src.Value
		,	Source    					=    src.Source
		,	AdContent    				=    src.AdContent
		,	Medium    					=    src.Medium
		,	ChannelGrouping    			=    src.ChannelGrouping
		,	Campaign    				=    src.Campaign
		,	DeviceCategory    			=    src.DeviceCategory
		,	Country    					=    src.Country
		,	Hostname    				=    src.Hostname
		,	CountryFromHostName    		=    src.CountryFromHostName
		,	ModifiedDate				=	 @CurrentDateTime
	from DWCONSDL.Temp_GASessionHits src
	where DWCONSDL.GASessionHits.DWHashKey = src.DWHashKey
		and (DWCONSDL.GASessionHits.DWHash != src.DWHash)
	option (label = 'DWCONSDL.LoadGASessionHits_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadGASessionHits_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.GASessionHits (
			DWBatchID
		,	DWHash
		,	DWHashKey
		,	Id
		,	GARegion
		,	FullVisitorId
		,	VisitNumber
		,	VisitId
		,	VisitStartTime
		,	VisitStartDateTime
		,	VisitDate
		,	DataSource
		,	ExperimentId
		,	ExperimentVariant
		,	HitNumber
		,	[Hour]
		,	IsEntrance
		,	IsExit
		,	IsInteraction
		,	[Minute]
		,	[Time]
		,	Referer
		,	HasSocialSourceReferral
		,	SocialInteractionAction
		,	SocialNetwork
		,	[Type]
		,	PagePath
		,	PagePathLevel1
		,	PagePathLevel2
		,	PagePathLevel3
		,	PagePathLevel4
		,	PageTitle
		,	SearchKeyword
		,	EventCategory
		,	EventAction
		,	EventLabel
		,	EventValue
		,	[Index]
		,	[Value]
		,	Source
		,	AdContent
		,	Medium
		,	ChannelGrouping
		,	Campaign
		,	DeviceCategory
		,	Country
		,	Hostname
		,	CountryFromHostName
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHash
		,	DWHashKey
		,	Id
		,	GARegion
		,	FullVisitorId
		,	VisitNumber
		,	VisitId
		,	VisitStartTime
		,	VisitStartDateTime
		,	VisitDate
		,	DataSource
		,	ExperimentId
		,	ExperimentVariant
		,	HitNumber
		,	[Hour]
		,	IsEntrance
		,	IsExit
		,	IsInteraction
		,	[Minute]
		,	[Time]
		,	Referer
		,	HasSocialSourceReferral
		,	SocialInteractionAction
		,	SocialNetwork
		,	[Type]
		,	PagePath
		,	PagePathLevel1
		,	PagePathLevel2
		,	PagePathLevel3
		,	PagePathLevel4
		,	PageTitle
		,	SearchKeyword
		,	EventCategory
		,	EventAction
		,	EventLabel
		,	EventValue
		,	[Index]
		,	[Value]
		,	Source
		,	AdContent
		,	Medium
		,	ChannelGrouping
		,	Campaign
		,	DeviceCategory
		,	Country
		,	Hostname
		,	CountryFromHostName
		,	@CurrentDateTime
		,	@CurrentDateTime
	from DWCONSDL.Temp_GASessionHits src
	where not exists(select * from DWCONSDL.GASessionHits dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DWCONSDL.LoadGASessionHits_Insert');
	
	UPDATE STATISTICS [DWCONSDL].[GASessionHits] (STATS_DWCONSDL_GASessionHits_DWHashKey);
	UPDATE STATISTICS [DWCONSDL].[GASessionHits] (STATS_DWCONSDL_GASessionHits_DWHash);
	
	if object_id ('DWCONSDL.Temp_GASessionHits', 'U') is not null
		drop table DWCONSDL.Temp_GASessionHits

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadGASessionHits_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end