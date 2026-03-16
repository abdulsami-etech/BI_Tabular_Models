CREATE PROC [DWCONSDL].[LoadFactGAGoalsEMEA] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactGAGoalsEMEA') is not null
		drop table #TempFactGAGoalsEMEA

	create table #TempFactGAGoalsEMEA with (distribution = round_robin, heap) as 
	

SELECT CONVERT(CHAR(40), '')	AS DWHashKey,
	   Id,
	   VisitDate,
  CASE WHEN G1 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID1,
  CASE WHEN G2 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID2,
  CASE WHEN G3 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID3,
  CASE WHEN G4 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID4,
  CASE WHEN G5 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID5,
  CASE WHEN G6 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID6,
  CASE WHEN G7 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID7,
  CASE WHEN G8 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID8,
  CASE WHEN G9 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID9,
  CASE WHEN G10 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID10,
  CASE WHEN G11 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID11,
  CASE WHEN G12 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID12,
  CASE WHEN G13 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID13,
  CASE WHEN G14 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID14,
  CASE WHEN G15 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID15,
  CASE WHEN G16 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID16,
  CASE WHEN G17 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID17,
  CASE WHEN G18 > 0 THEN 1 WHEN G1 = 0 THEN 0 END AS G_ID18,
  CASE WHEN G19 > 0 THEN 1 WHEN G2 = 0 THEN 0 END AS G_ID19
FROM (
SELECT Id,VisitDate,
  SUM(CASE WHEN (EventCategory IN ('Submit - Step7' ,'std-sa-form') 
  AND EventAction IN  ('Submit - Step7', 'complete-form'))
  THEN 1  ELSE 0 
  END) AS G1,
  SUM(CASE WHEN (EventCategory IN ('Info Kit' ,'Smile Guide') 
  AND (EventAction = 'Form Submit' OR EventAction LIKE  '/smile-guide.%'))
  THEN 1  ELSE 0 
  END) AS G2,
  SUM(CASE WHEN (EventCategory IN ('Conversions', 'docloc-overview-clicks', 'docloc-detail-clicks', 'Smile Assessment') 
  AND EventAction IN  ('Appt Request Completed', 'book-appointment-succeeded', 'Checkbox - Appointment Requested'))
  THEN 1  ELSE 0 
  END) AS G3,
  SUM(CASE WHEN (EventCategory LIKE '%PDF%'
  AND EventAction LIKE '%Questions for Consultant%')
  THEN 1  ELSE 0 
  END) AS G4,
  SUM(CASE WHEN (EventCategory LIKE '%Video Watch%'
  AND EventAction LIKE '%Video Watch%' AND EventLabel LIKE '%Video Watch%')
  THEN 1  ELSE 0 
  END) AS G5,
  SUM(CASE WHEN (EventCategory LIKE '%docloc-overview-clicks%'
  AND EventAction LIKE '%full-details%')
  THEN 1  ELSE 0 
  END) AS G6,
  SUM(CASE WHEN (EventCategory LIKE '%Contact Details Requested%'
  AND EventAction LIKE '%Click%')
  THEN 1  ELSE 0 
  END) AS G7,
  SUM(CASE WHEN (EventCategory IN ( 'Conversions', 'std-sa-steps-answer')
  AND EventAction IN ('Smile Assessment', '1') AND EventLabel IN ( 'Start','Adult', 'Parent of teenager' ))
  THEN 1  ELSE 0 
  END) AS G8,
  SUM(CASE WHEN (EventCategory LIKE '%DocLoc Search%'
  AND EventAction LIKE '%DocLoc Search%' AND EventLabel LIKE '%DocLoc Search%')
  THEN 1  ELSE 0 
  END) AS G9,
  SUM(CASE WHEN (EventCategory IN ( 'Conversions', 'docloc-overview-clicks', 'docloc-detail-clicks')
  AND EventAction IN ('Appt Request', 'book-appointment-gotoform') AND 
  (EventLabel = '0' OR EVentLabel = 'Start'  OR (EventLabel LIKE '[1-9]%' AND ISNUMERIC(EventLabel) = 1)))
  THEN 1  ELSE 0 
  END) AS G10,
  SUM(CASE WHEN (EventCategory LIKE '%Conversions%'
  AND EventAction LIKE '%Smile Assessment%' AND EventLabel LIKE '%Offer Accepted%')
  THEN 1  ELSE 0 
  END) AS G11,
  SUM(CASE WHEN (EventCategory IN ( 'Conversions', 'Smile Guide')
  AND (EventAction = 'Info Kit' OR EventAction LIKE  '/smile-guide.%')
   AND EventLabel IN ('Offer Accepted', 'Email','Email & SMS'))
  THEN 1  ELSE 0 
  END) AS G12,
  SUM(CASE WHEN EventCategory LIKE '%Smile Vis%'
  AND EventAction LIKE '%submit_button%'
  THEN 1  ELSE 0 
  END) AS G13,
  SUM(CASE WHEN EventCategory LIKE '%Smile Vis%'
  AND EventAction LIKE '%upload_photo%'
  THEN 1  ELSE 0 
  END) AS G14,
  SUM(CASE WHEN EventCategory LIKE '%Smile Vis%'
  AND EventAction LIKE '%see_visualization%'
  THEN 1  ELSE 0 
  END) AS G15,
  SUM(CASE WHEN EventCategory LIKE '%Smile Guide%'
  AND EventAction LIKE '%/smile-guide-for-parents%'
  THEN 1  ELSE 0 
  END) AS G16,
  SUM(CASE WHEN (EventCategory = 'phone-question-form'
  AND EventAction = 'conversion')
  THEN 1  ELSE 0 
  END) AS G17,
  SUM(CASE WHEN EventCategory LIKE '%Smile Vis%'
  AND EventAction LIKE '%home_visualise_smile%' AND EventLabel LIKE '%home_visualise_smile%'
  THEN 1  ELSE 0 
  END) AS G18,
  SUM(CASE WHEN EventCategory LIKE '%Smile View%'
  AND EventAction LIKE '%take_your_selfie%'
  THEN 1  ELSE 0 
  END) AS G19
FROM (SELECT DISTINCT Id, CONVERT(DATE, VisitDate) AS VisitDate, HitNumber,EventCategory, EventAction, EventLabel FROM  [SrcGoogleBigQuery].[GA_Sessionhits_EMEA]
WHERE VisitDate >= (SELECT ISNULL(MAX(VisitDate), '1900-01-01') from [DWCONSDL].[FactGAGoalsEMEA] )) tempTable0
GROUP BY Id,VisitDate) AS tempTable

update #TempFactGAGoalsEMEA set DWHashKey=
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
				  + N'|' + isnull(convert(nvarchar, G_ID10), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID11), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID12), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID13), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID14), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID15), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID16), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID17), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID18), N'N/A')
				  + N'|' + isnull(convert(nvarchar, G_ID19), N'N/A')
				)
			, 2)

	
	update DWCONSDL.FactGAGoalsEMEA
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
		,	G_ID10					=			src.G_ID10
		,   G_ID11					=			src.G_ID11
		,	G_ID12					=			src.G_ID12
		,   G_ID13					=			src.G_ID13
		,	G_ID14					=			src.G_ID14
		,   G_ID15					=			src.G_ID15
		,	G_ID16					=			src.G_ID16
		,   G_ID17					=			src.G_ID17
		,	G_ID18					=			src.G_ID18
		,   G_ID19					=			src.G_ID19
		,	ModifiedDate			=			@CurrentDateTime
	from #TempFactGAGoalsEMEA src
	where DWCONSDL.FactGAGoalsEMEA.Id = src.Id
		and DWCONSDL.FactGAGoalsEMEA.DWHashKey != src.DWHashKey
	option (label = 'DWCONSDL.LoadFactGAGoalsEMEA_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAGoalsEMEA_Update', @rc = @RowsUpdated out

	insert into DWCONSDL.FactGAGoalsEMEA (
			DWBatchID
		,	DWHashKey
		,	Id
		,	VisitDate
		,	G_ID1
		,	G_ID2
		,	G_ID3
		,	G_ID4
		,	G_ID5
		,	G_ID6
		,	G_ID7
		,	G_ID8
		,	G_ID9
		,	G_ID10
		,	G_ID11
		,	G_ID12
		,	G_ID13
		,	G_ID14
		,	G_ID15
		,	G_ID16
		,	G_ID17
		,	G_ID18
		,	G_ID19
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	Id
		,	VisitDate
		,	G_ID1
		,	G_ID2
		,	G_ID3
		,	G_ID4
		,	G_ID5
		,	G_ID6
		,	G_ID7
		,	G_ID8
		,	G_ID9
		,	G_ID10
		,	G_ID11
		,	G_ID12
		,	G_ID13
		,	G_ID14
		,	G_ID15
		,	G_ID16
		,	G_ID17
		,	G_ID18
		,	G_ID19
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactGAGoalsEMEA src
	where not exists(select * from DWCONSDL.FactGAGoalsEMEA dst where dst.Id = src.Id)
	option (label = 'DWCONSDL.LoadFactGAGoalsEMEA_Insert');
	
	UPDATE STATISTICS [DWCONSDL].[FactGAGoalsEMEA] (STATS_DWCONSDL_FactGAGoalsEMEA_Id);
	UPDATE STATISTICS [DWCONSDL].[FactGAGoalsEMEA] (STATS_DWCONSDL_FactGAGoalsEMEA_VisitDate);

	exec CTRL.GetLastRowCount @Label = 'DWCONSDL.LoadFactGAGoalsEMEA_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end