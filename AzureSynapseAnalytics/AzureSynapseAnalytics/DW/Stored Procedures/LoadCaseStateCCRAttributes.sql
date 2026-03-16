CREATE PROC [DW].[LoadCaseStateCCRAttributes] @BatchID [INT],@LastSuccessfullDWTimestamp [DATETIME2](0),@IsForceFullLoad [BIT] AS 
  BEGIN 
    DECLARE @RowsInserted INT = 0 , 
      @RowsUpdated        INT = 0 , 
      @totalRowsInserted  INT = 0 , 
      @totalRowsUpdated   INT = 0 , 
      @IsFullLoad         INT = 0 

    IF NOT EXISTS  ( SELECT * FROM   [DW].CaseStateCCAattributes) OR  @IsForceFullLoad=1 
	Begin
		SET @LastSuccessfullDWTimestamp = getutcdate()-30
	end
	else
	begin
		select @LastSuccessfullDWTimestamp=max(startDate) from [DW].CaseStateCCAattributes
	end
    if object_id('DW.Temp_ClincheckActualDuration','U') is not null
    drop table DW.Temp_ClincheckActualDuration

	
	CREATE TABLE [DW].Temp_ClincheckActualDuration (SAPOrderNumber bigint not null ) with (distribution = round_robin, heap)
	ALTER TABLE [DW].Temp_ClincheckActualDuration ADD CONSTRAINT PK_Temp_ClincheckActualDuration PRIMARY KEY NONCLUSTERED (SAPOrderNumber) NOT ENFORCED

	Insert into [DW].Temp_ClincheckActualDuration (SAPOrderNumber)
	select distinct sapordernumber
	from dw.casestatehistory 
	where (starttime_utc>=@LastSuccessfullDWTimestamp)
	and orderstatus='Clincheck'




    IF Object_id('tempdb..#Technician') IS NOT NULL 
    DROP TABLE #technician 

    SELECT Isnull(Max(tg.atr_name),'') AS dedicatedtechname, 
                    tpd.doctorid_s              AS clinicianid 
    INTO            #technician 
    FROM            [SrcMESCorp].at_at_techpreferreddoctor tpd 
    LEFT OUTER JOIN [SrcMESCorp].at_at_techprofile tp 
    ON              tpd.profileid_i = tp.atr_key 
    LEFT OUTER JOIN [SrcMESCorp].at_at_techgeneral tg 
    ON              tp.atr_key = tg.profileid_i 
    WHERE           tg.station_s='Setup & Stage' 
    GROUP BY        tpd.doctorid_s 

IF Object_id('tempdb..#tagging') IS NOT NULL 
    DROP TABLE #tagging    
select sapordernumber,
starttime_utc,
keyteamregion,
dedicatedtechname,
plantnumber,
holiday,
[priority],
producttype
into #tagging 
 from 
    (SELECT     a.sapordernumber, 
               a.starttime_utc, 
               l.uda_5                        AS keyteamregion, 
               Isnull(d.dedicatedtechname,'') AS dedicatedtechname, 
               c.at_plantoa_s                 AS plantnumber, 
               CASE 
                          WHEN b.[Day] IS NOT NULL THEN 1 
                          ELSE 0 
               END AS holiday, 
               l.priority, 
               c.at_deliverabletype_s AS producttype,
			   row_number() over(partition by a.sapordernumber order by starttime_utc) as rownum
    FROM       dw.casestatehistory a 
    INNER JOIN [SrcMESCorp].work_order wo 
    ON         a.sapordernumber = wo.order_number 
    INNER JOIN srcmescorp.uda_order c 
    ON         wo.order_key = c.object_key 
    INNER JOIN dwtops.dimdoctor doc 
    ON         doc.keydoctor = c.at_doctorid_s 
    INNER JOIN [SrcMESCorp].lot l 
    ON         l.order_key = wo.order_key 
    LEFT JOIN  #technician d 
    ON         d.clinicianid = doc.clinicianid 
    LEFT JOIN  [SrcMESCorp].[DC_at_CalendarHoliday] b 
    ON         c.at_plantoa_s = b.servicecenter 
    AND        ( 
                          Cast(b.[day] AS DATE) =Cast(Dateadd(day,1,a.starttime_utc) AS DATE) 
               OR         Cast(b.[day] AS DATE) =Cast(Dateadd(day,2,starttime_utc) AS DATE)) 
    AND        Isnull(comment,'')<>'test holiday' 
    WHERE      a.orderstatus='Tagging' 
    AND        ( 
                     a.starttime_utc>=@LastSuccessfullDWTimestamp 
               ) 
    AND        c.at_deliverabletype_s not in ('VIVERA_RETAINER','INVISALIGN_RETAINER','CLEAR_ALIGNER_GO','RD_PROGRESS_SCAN','WARRANTY_RETAINER','WARRANTY_DEFECTIVE_ALIGNER','ATTACHMENT_TEMPLATE','REPLACEMENT_ALIGNER') 
    ) a
	where rownum=1;
     
  WITH backlog AS 
    ( 
               SELECT     b.operationname AS orderstatus, 
                          a.keyteamregion, 
                          a.[DgnCompleteDateTime] AS starttime_utc, 
                          Getutcdate()          AS completetime_utc, 
                          d.dedicatedtechname 
               FROM       [DWTOPS].[FactLotCurrent] a 
               INNER JOIN [DWTOPS].[DimOperation] b 
               ON         a.[SKOperation]=b.[SKOperation] 
               INNER JOIN [DWTOPS].[DimDoctor] c 
               ON         c.skdoctor = a.skdoctor 
               LEFT JOIN  #technician d 
               ON         d.clinicianid = c.clinicianid 
               WHERE      b.[OperationName] IN ('Setup & Stage', 
                                                'DDT Bite0') 
               AND        dgnstartdatetime IS NULL 
               UNION ALL 
               SELECT orderstatus, 
                      uda_5, 
                      starttime_utc, 
                      completetime_utc, 
                      dedicatedtechname 
               FROM   ( 
                              SELECT op_name as Orderstatus, 
											  lo.uda_5, 
											  t.begin_time_u as starttime_utc,   
											  t.end_time_u as completetime_utc,
											  d.dedicatedtechname 
							  FROM [SrcMESCorp].[TOBJ_QUEUE_HISTORY] t
							  inner join SrcMESCorp.Lot lo on lo.lot_key = t.tobj_key
							  inner join SrcMESCorp.Work_Order wo on wo.order_key = lo.order_key
							  INNER JOIN srcmescorp.uda_order c ON  wo.order_key = c.object_key 
							  INNER JOIN  (select distinct keydoctor,clinicianid from dwtops.dimdoctor)  doc ON  doc.keydoctor = c.at_doctorid_s 
							  LEFT JOIN  #technician d ON d.clinicianid = doc.clinicianid 
							  left join (
								select    s.route_key
									,    s.site_num
									,    q.queue_key
									,    s.route_step_name
									,    o.op_key
									,    o.op_name
								from SrcMESCorp.ROUTE_ARC arc
								inner join SrcMESCorp.ROUTE_QUEUE q on arc.from_node_key = q.queue_key
								inner join SrcMESCorp.ROUTE_STEP s on arc.to_node_key = s.route_step_key
								inner join SrcMESCorp.OPERATION o on s.op_key = o.op_key

								where arc.main_path = 1
							) QRS on QRS.queue_key = t.queue_key
							  where op_name in ('DDT Bite0','Setup & Stage')
							  and end_time_u is not null

                                                   AND    ( 
                                                                 begin_time_u>=@LastSuccessfullDWTimestamp
                                                         ) )  a
)
    INSERT INTO DW.CaseStateCCAattributes 
                ( 
                            [DWBatchID] , 
                            [SAPOrdernumber] , 
                            [StartDate] , 
                            [ScanType] , 
                            [Team] , 
                            [ProductType] , 
                            [Region] , 
                            [DDTbacklog] , 
                            [SSbacklog] , 
                            [DayNumberofWeek] , 
                            [WeekOfYear] , 
                            [PriorityBucket] , 
                            [DedicatedTech] , 
                            [UpcomingHoliday] , 
                            [EveningShift] , 
                            [MorningShift] , 
                            [PredictedTime] , 
                            [ActualTime] , 
                            [Capacity] , 
                            [TreatmentType] 
                ) 
				select [DWBatchID] , 
                            [SAPOrdernumber] , 
                            [StartDate] , 
                            [ScanType] , 
                            [Team] , 
                            [ProductType] , 
                            [Region] , 
                            [DDTbacklog] , 
                            [SSbacklog] , 
                            [DayNumberofWeek] , 
                            [WeekOfYear] , 
                            [PriorityBucket] , 
                            [DedicatedTech] , 
                            [UpcomingHoliday] , 
                            [EveningShift] , 
                            [MorningShift] , 
                            [PredictedTime] , 
                            [ActualTime] , 
                            [Capacity] , 
                            [TreatmentType]
							from (
							SELECT     @BatchID          AS dwbatchid, 
									   a.sapordernumber      AS sapordernumber, 
									   a.starttime_utc       AS startdate, 
									   isnull(b.scan_type__c,'')        AS scantype, 
									   isnull(amr.keyteamregion,'')         AS Team, 
									   isnull(amr.producttype,'')       AS producttype, 
									   isnull(b.promotion_region__c,'') AS region, 
									   isnull(ddt.ddtbacklog,0) as ddtbacklog , 
									   isnull(ss.ssbacklog,0) as ssbacklog, 
									   isnull(dt.daynumberofweek,1) as daynumberofweek, 
									   isnull(dt.weekofyear,1) AS weekofyear, 
									   prioritybucket = 
									   CASE 
												  WHEN amr.[priority]<100 THEN 1 
												  WHEN amr.[priority]>=100 
												  AND  amr.[priority]<200 THEN 2 
												  WHEN amr.[priority]>=200 
												  AND  amr.[priority]<300 THEN 3 
												  WHEN amr.[priority]>=300 
												  AND  amr.[priority]<400 THEN 4 
												  WHEN amr.[priority]>=400 
												  AND  amr.[priority]<500 THEN 5 
												  ELSE 6 
									   END, 
									   CASE 
												  WHEN amr.dedicatedtechname='' THEN 0 
												  ELSE 1 
									   END               AS dedicatedtech , 
									   isnull(AMR.Holiday,0) as UpcomingHoliday , 
									   isnull(ts.EveningShift,1) as EveningShift , 
									   isnull(ts.MorningShift,1) as MorningShift, 
									   predictedtime=       0, 
									   actualtime=          0, 
									   isnull(cap.capacity,0) as capacity , 
									   isnull(b.treatment_category__c,'') AS treatmenttype,
									   row_Number() over(partition by a.sapordernumber order by a.starttime_utc) as rownum
										FROM       dw.casestatehistory a 
										INNER JOIN [SrcSFDC].[Apttus_Config2__Order__c] b 
										ON         a.[SAPOrderNumber] = b.sap_order_id__c 
										INNER JOIN dw.dimdate dt 
										ON         dt.keydate = Cast(a.starttime_utc AS DATE) 
										INNER JOIN #tagging AMR 
										ON         amr.sapordernumber = a.sapordernumber
										LEFT JOIN [Custom].[MESTechnicianTeamShift] ts on TS.TeamName = AMR.keyteamregion
										LEFT JOIN 
												   ( 
															  SELECT     dt.firstdayofweek, 
																		 Dateadd(day,7,dt.firstdayofweek) AS lastdayofweek, 
																		 Count(1)                      AS capacity 
															  FROM       dw.casestatehistory a 
															  INNER JOIN dw.dimdate dt 
															  ON         Cast(dt.keydate AS DATETIME) = Cast(completetime_utc AS DATE)
															  WHERE      a.orderstatus='setup & stage' 
															  GROUP BY   dt.firstdayofweek, 
																		 Dateadd(day,7,dt.firstdayofweek) ) cap 
										ON         Dateadd(week,-1,dt.keydate) BETWEEN cap.firstdayofweek AND        cap.lastdayofweek
										LEFT JOIN 
												   ( 
															  SELECT     a.sapordernumber, 
																		 Count(1) AS ddtbacklog 
															  FROM       #tagging a 
															  INNER JOIN backlog b 
															  ON         a.starttime_utc BETWEEN b.starttime_utc AND        b.completetime_utc
															  AND        a.keyteamregion = b.keyteamregion 
															  AND        b.orderstatus = 'DDT Bite0' 
															  GROUP BY   a.sapordernumber )DDT 
										ON         ddt.sapordernumber = a.sapordernumber 
										LEFT JOIN 
												   ( 
															  SELECT     a.sapordernumber, 
																		 Count(1) AS ssbacklog 
															  FROM       #tagging a 
															  INNER JOIN backlog b 
															  ON         a.starttime_utc BETWEEN b.starttime_utc AND        b.completetime_utc
															  AND        a.keyteamregion = b.keyteamregion 
															  AND        Isnull(a.dedicatedtechname,'') = Isnull(b.dedicatedtechname,'')
															  AND        b.orderstatus = 'Setup & Stage' 
															  GROUP BY   a.sapordernumber )SS 
										ON         ss.sapordernumber = a.sapordernumber 
										WHERE      a.orderstatus='Tagging' 
										AND        NOT EXISTS 
												   ( 
														  SELECT * 
														  FROM   dw.casestateccaattributes s 
														  WHERE  s.sapordernumber = a.sapordernumber ) 
							) a where rownum=1
												OPTION (label = 'DW.CaseStateCCRAttributes_Insert');
     
		EXEC ctrl.getlastrowcount  @Label = 'DW.CaseStateCCRAttributes_Insert',  @rc = @RowsInserted out 
 
		update a
		set ActualTime = isnull(b.ActualTime,0),
		DWBatchid = @BatchID
		from DW.CaseStateCCAattributes  a
		inner join (
					select Sapordernumber,
					datediff(hour,min(starttime_utc),max(starttime_utc))/24.0 as ActualTime
							from 
								(
									select a.sapordernumber,orderstatus,
									row_number() over(partition by a.sapordernumber order by starttime_utc) as rownum,
									starttime_utc,completetime_utc	
									from dw.Temp_ClincheckActualDuration a
									inner join dw.casestatehistory b on a.sapordernumber = b.sapordernumber
									where orderstatus in ('Tagging','Clincheck')
								) a
							where (orderstatus='Tagging' and rownum=1) or (orderstatus='Clincheck' and rownum=2)
							group by Sapordernumber
					) b on a.sapordernumber = b.sapordernumber
		option (label = 'LoadCaseStateCCRAttributes');
		exec CTRL.GetLastRowCount @Label = 'LoadCaseStateCCRAttributes', @rc = @RowsUpdated out
	
	if object_id('DW.Temp_ClincheckActualDuration', 'U') is not null
	drop table DW.Temp_ClincheckActualDuration
   SELECT @RowsInserted AS rowsinserted , @RowsUpdated AS rowsUpdated

  END