CREATE VIEW [DWCaseMonitor].[CaseStateCCAABatchAttributes] AS WITH backlog AS 
    ( 
               SELECT     b.operationname AS orderstatus, 
                          a.keyteamregion, 
                          a.[DgnCompleteDateTime] AS starttime_utc, 
                          Getutcdate()          AS completetime_utc
                        
               FROM       [DWTOPS].[FactLotCurrent] a 
               INNER JOIN [DWTOPS].[DimOperation] b 
               ON         a.[SKOperation]=b.[SKOperation] 
               INNER JOIN [DWTOPS].[DimDoctor] c 
               ON         c.skdoctor = a.skdoctor 
               WHERE      b.[OperationName] IN ('Setup & Stage', 
                                                'DDT Bite0') 
               AND        dgnstartdatetime IS NULL 
             ),
dedicated as (
  SELECT Isnull(Max(tg.atr_name),'') AS dedicatedtechname, 
                    tpd.doctorid_s              AS clinicianid 

    FROM            [SrcMESCorp].at_at_techpreferreddoctor tpd 
    LEFT OUTER JOIN [SrcMESCorp].at_at_techprofile tp 
    ON              tpd.profileid_i = tp.atr_key 
    LEFT OUTER JOIN [SrcMESCorp].at_at_techgeneral tg 
    ON              tp.atr_key = tg.profileid_i 
    WHERE           tg.station_s='Setup & Stage' 
    GROUP BY        tpd.doctorid_s 
	)


select doc.clinicianid as Clinid
,doc.DoctorRegionMES  as Team
,isnull(ddt.ddtbacklog,0) as DDTbacklog 
,isnull(ss.SSbacklog,0) as SSbacklog
,case when dt.clinicianid is null then 0 else 1 end as DedicatedTech
,case when (select top 1 creation_time
from [SrcMESCorp].[DC_at_CalendarHoliday] where servicecenter=2803
and cast(creation_time as date) 
between cast(getdate()-2 as date) 
and cast(getdate() as date)) is null then 0 else 1 end as UpcomingHoliday
,isnull(ts.MorningShift,1) as MorningShift
,isnull(ts.EveningShift,1) as EveningShift
,Capacity = ( 
			SELECT     Count(1)  AS capacity 
			FROM       dw.casestatehistory a 
			WHERE      a.orderstatus='setup & stage'
			and completetime_utc between getutcdate()-7 and getutcdate()
			)
,doc.Region
from (select doc.clinicianid,max(doc.DoctorRegionMES) as DoctorRegionMES,
max(b.Promotion_Region__c) as Region
from dwtops.dimdoctor doc
inner join srcsfdc.account b on doc.keydoctor=b.account_number__c
where doc.clinicianid is not null
group by doc.clinicianid
) doc
left join(
			  SELECT     keyteamregion, 
    			 Count(1) AS ddtbacklog 
			  FROM       backlog 
			  where        orderstatus = 'DDT Bite0' 
			  GROUP BY   keyteamregion
		) as ddt on ddt.keyteamregion = DoctorRegionMES
left join(
			  SELECT     keyteamregion, 
    			 Count(1) AS ssbacklog 
			  FROM       backlog 
			  where        orderstatus = 'Setup & Stage' 
			  GROUP BY   keyteamregion
		) as ss on ss.keyteamregion = DoctorRegionMES

left join  
[Custom].[MESTechnicianTeamShift] ts on doc.DoctorRegionMES = TeamName
left join dedicated dt on dt.clinicianid = doc.clinicianid;
GO


