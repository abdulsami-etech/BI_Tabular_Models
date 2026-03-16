CREATE PROC [DWCONSDL].[LoadFactSmileViewLogs] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@MaxIdLoaded	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	SELECT @MaxIdLoaded = ISNULL(MAX(Id), 0) FROM [DWCONSDL].[FactSmileViewLogs]
	
	if object_id('tempdb..#TempFactSmileViewLogs') is not null
		drop table #TempFactSmileViewLogs

CREATE TABLE #TempFactSmileViewLogs WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) as 
	
WITH 
NADLVisitswithSV AS (
  SELECT  svl.session_id AS SessionID,MIN(svl.created_at) FirstsvVisit, MIN(cp.created_at) FirstDocLocVisit  --, cp.leadsource
  FROM SrcSmileView.smile_visualization_logs svl 
  INNER JOIN SrcNASA.contact_providers cp ON svl.session_id = cp.visitor_id
  WHERE  svl.created_at < cp.created_at AND cp.leadsource='Doc Locator'
  AND svl.id > @MaxIdLoaded
  GROUP BY svl.session_id 
),
NASAVisitswithSV AS (
   SELECT   svl.session_id AS SessionID,MIN(svl.created_at) FirstsvVisit, MIN(sa.created_at) FirstSAVisit      
   FROM SrcSmileView.smile_visualization_logs svl 
  INNER JOIN SrcNASA.smile_assessments sa ON svl.session_id = sa.visitor_id
  WHERE event_name = 'landing_page'  AND svl.created_at < sa.created_at
  AND svl.id > @MaxIdLoaded
  GROUP BY svl.session_id

),
simStart AS (
SELECT   session_id,simulation_id, MIN(CASE WHEN simulation_start_time = CONVERT(DATE,simulation_start_time) THEN created_at ELSE simulation_start_time END)  simulation_start_time
FROM  [SrcSmileView].[smile_visualization_logs]  
WHERE event_name='simulation_start' 
AND id > @MaxIdLoaded
GROUP BY  session_id,simulation_id),
simEnd AS (
SELECT  distinct  session_id 
 FROM  [SrcSmileView].[smile_visualization_logs]  
WHERE event_name='simulation_end' 
AND id > @MaxIdLoaded
),
smilesimulations as (
SELECT 		svl.id Id
		,	svl.event_name EventName
		,	svl.session_id SessionId
		,	svl.simulation_id SimulationID
		,	svl.lead_id LeadID
		,	svl.reason_code ReasonCode
		,	COALESCE(svl.simulation_start_time,ss.simulation_start_time) SimStartTime
		,	CASE WHEN svl.event_name='simulation_end' OR svl.event_name='simulation_fail' 
				 THEN CASE WHEN svl.simulation_end_time = CONVERT(DATE,svl.simulation_end_time) 
				 THEN svl.created_at ELSE svl.simulation_end_time END ELSE NULL END SimEndTime
		,	ISNULL(svl.country_code,'Unk') CountryCode
		,	ISNULL(svl.site_id,'Blank') SiteID
		,	CASE WHEN site_id IS NULL THEN 'SV' 
					WHEN site_id LIKE 'DOCLOC%' THEN 'In Clinic SV' 
					WHEN site_id IS NOT NULL  AND LEN(site_id) <5 THEN 'A/B Test SV'
					WHEN site_id IS NOT NULL AND LEN(site_id)>5 THEN 'In Clinic SV' END IsInClincSV
		,	svl.extra_data Reason
		,	svl.created_at EventTime
		,	CONVERT(DATE,created_at) AS DateKey 
		,	CASE WHEN event_name = 'free_consultation' AND se.session_id IS NOT NULL THEN 1 ELSE 0 END AS VisConProvPhotoSub
		,	CASE WHEN svl.event_name =  'time_taken_for_simulation' AND ISNUMERIC(svl.extra_data)=1 THEN CONVERT(decimal,svl.extra_data)/1000 END AS TimeTakenforsimFrontend
		,	created_at AS CreateDateTimestamp
FROM [SrcSmileView].[smile_visualization_logs] svl 
LEFT JOIN simStart ss ON svl.simulation_id = ss.simulation_id AND ss.session_id = svl.session_id
LEFT JOIN simEnd se ON svl.Session_ID =  se.Session_Id

WHERE   svl.event_name !='test' AND svl.session_id !='na'
AND (svl.id < 0 OR svl.id > 1611) ---  ID 1611 IS the last smoke test CASE before 7/30/2018 PDT 9am launch. 
AND svl.id > @MaxIdLoaded
)
SELECT CONVERT(CHAR(40), '')	AS DWHashKey
		,	ss.*, CASE WHEN SimStartTime IS NOT NULL AND SimEndTime IS NOT NULL THEN DATEDIFF(SECOND,SimStartTime,SimEndTime) ELSE NULL END AS Duration,
CASE WHEN ss.EventName LIKE '%negative%' THEN 1 ELSE 0 END AS NegativeFeedbackEvent  
 ,CASE WHEN ss.EventName  = 'simulation_start' THEN   RANK()   
         OVER (   
           PARTITION BY ss.SessionId  
           ORDER BY SimulationID   ) ELSE NULL END AS   RetryCount
,   RANK()   
         OVER (   
           PARTITION BY ss.SessionId, ss.EventName
   ORDER BY  ss.SessionId,ss.CreateDateTimestamp)    SessionEventOccurance
, RANK()   
         OVER (   
           PARTITION BY ss.SessionId, ss.EventName, ss.SimulationID
   ORDER BY  ss.SessionId,ss.CreateDateTimestamp)    SessionSimulationEventOccurance
, CASE WHEN nadl.SessionID IS NOT NULL AND nadl.FirstDocLocVisit > ss.CreateDateTimestamp THEN 'After' 
WHEN nadl.SessionID IS NOT NULL AND nadl.FirstDocLocVisit < ss.CreateDateTimestamp THEN 'Before' ELSE 'None' END NADLVisit
, CASE WHEN nasa.SessionID IS NOT NULL AND nasa.FirstSAVisit > ss.CreateDateTimestamp THEN 'After' 
WHEN nasa.SessionID IS NOT NULL AND nasa.FirstSAVisit < ss.CreateDateTimestamp THEN 'Before' ELSE 'None' END NASAVisit
FROM smilesimulations ss
LEFT JOIN NADLVISitswithSV nadl on ss.SessionId = nadl.SessionID
LEFT JOIN NASAVISitsWithSV nasa on ss.SessionId = nasa.SessionID


	insert into DWCONSDL.FactSmileViewLogs (
			DWBatchID
		,	DWHashKey
		,	Id	
		,	EventName
		,	SessionId
		,	SimulationID
		,	LeadID
		,	ReasonCode
		,	SimStartTime		
		,	SimEndTime	
		,	CountryCode
		,	SiteID
		,	IsInClincSV
		,	Reason
		,	EventTime
		,	DateKey
		,	VisConProvPhotoSub
		,	TimeTakenforsimFrontend
		,	CreateDateTimestamp
		,	Duration
		,	NegativeFeedbackEvent
		,	RetryCount
		,	SessionEventOccurance
		,	SessionSimulationEventOccurance
		,	NADLVisit
		,	NASAVisit
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	Id	
		,	EventName
		,	SessionId
		,	SimulationID
		,	LeadID
		,	ReasonCode
		,	SimStartTime		
		,	SimEndTime	
		,	CountryCode
		,	SiteID
		,	IsInClincSV
		,	Reason
		,	EventTime
		,	DateKey
		,	VisConProvPhotoSub
		,	TimeTakenforsimFrontend
		,	CreateDateTimestamp
		,	Duration
		,	NegativeFeedbackEvent
		,	RetryCount
		,	SessionEventOccurance
		,	SessionSimulationEventOccurance
		,	NADLVisit
		,	NASAVisit
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactSmileViewLogs src
	where not exists(select * from DWCONSDL.FactSmileViewLogs dst where dst.Id = src.Id)
	option (label = 'DWCONSDL.LoadFactSmileViewLogs_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactSmileViewLogs_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
