CREATE VIEW [DWCaseMonitor].[CaseStateShipmentBatchAttributes] AS 
with capacity as (
select case when [Capacity]<12000 then '<12'
when [Capacity]<12500 then '12 - 12.5'
when [Capacity]<13000 then '12.5 - 13'
when [Capacity]<13500 then '13 - 13.5'
when [Capacity]<14000 then '13.5 - 14'
when [Capacity]<14500 then '14 - 14.5'
when [Capacity]<15000 then '14.5 - 15'
else '>15' end as Capacity
from (
		select sum(TemplateOrders)/7 as Capacity 
		from (
		select cast(starttime_utc as date) date,count(distinct sapordernumber) TemplateOrders
		from dw.casestatehistory
		where orderstatus like 'Template'
		and cast(starttime_utc as date) between cast(getdate()-7 as date) and cast(getdate()-1 as date)
		group by cast(starttime_utc as date)
		) a
	 )b
),

Backlog as (
				select case when [Backlog]<2 then '2'
				when [Backlog]<2.5 then '2.5'
				when [Backlog]<3 then '3'
				when [Backlog]<3.5 then '3.5'
				when [Backlog]<4 then '4'
				when [Backlog]<4.5 then '4.5'
				when [Backlog]<5 then '5'
				when [Backlog]<5.5 then '5.5'
				when [Backlog]<6 then '6'
				when [Backlog]<6.5 then '6.5'
				when [Backlog]<7 then '7'
				when [Backlog]<7.5 then '7.5'
				when [Backlog]<8 then '8'
				when [Backlog]<8.5 then '8.5'
				when [Backlog]<9 then '9'
				when [Backlog]<9.5 then '9.5'
				else '10' end as Backlog
				from (select round(sum(isnull(b.lower_Quantity__C,0)+isnull(b.Upper_Quantity__C,0))/1000000.0, 1) as Backlog
									from dw.casestatehistory a
									inner join [SrcSFDC].[Apttus_Config2__Order__c] b 
									on a.[SAPOrderNumber] = b.sap_order_id__C
									and a.sourceSystem in ('IDS')
									and a.orderstatus in ('ClinCheckAccepted','FirstSevenTreatmentPurchased')
									where b.shipped_date1__C is null
									) a
				),
AFABMachineCount as (select (select count(distinct p_line_name)  As AFABMachineCount from 
					[SrcMES_AFAB_MX1].[TRACKED_OBJECT_HISTORY] 
					WHERE cast([start_time] As Date) =cast(getutcdate()-1 as date))
						+
	(select count(distinct p_line_name)  As AFABMachineCount from 
					[SrcMES_AFAB_MX2].[TRACKED_OBJECT_HISTORY] 
					WHERE cast([start_time] As Date) =cast(getutcdate()-1 as date)) as AFABMachineCount
					),
FABMachineCount as (select (select count(distinct [location]) As FABMachineCount
					FROM [SrcMES_FAB_MX1].[ALGN_CARRIER_EVENT]
					where  cast([trx_time] as date) = cast(getutcdate()-1 as date))
					+
					(select count(distinct [location]) As FABMachineCount
					FROM [SrcMES_FAB_MX2].[ALGN_CARRIER_EVENT]
					where  cast([trx_time] as date) = cast(getutcdate()-1 as date)
					) as FABMachineCount),
FABHourCapacity as (select (select  sum(isnull(AFABHour,0))
   from (select DATEDIFF(hour,min([start_time]), max([start_time])) As AFABHour from 
					[SrcMES_AFAB_MX1].[TRACKED_OBJECT_HISTORY] 
					WHERE cast([start_time] As Date) =cast(getutcdate()-1 as date)
					group by p_line_name
					) a)
	+
	(select  sum(isnull(AFABHour,0))
   from (select DATEDIFF(hour,min([start_time]), max([start_time])) As AFABHour from 
					[SrcMES_AFAB_MX2].[TRACKED_OBJECT_HISTORY] 
					WHERE cast([start_time] As Date) =cast(getutcdate()-1 as date)
					group by p_line_name
					) a
	) as FABHourCapacity)

select a.clinicianid as Clinid
,Backlog
,Capacity
,isnull(fabmachine.FABMachineCount,0) as FABMachineCount
,isnull(fabhour.FABHourCapacity,0)FABHourCapacity
,isnull(Afab.AFABMachineCount,0)AFABMachineCount
,a.DoctorRegion as Region
from (
select doc.clinicianid,max(b.Promotion_Region__c) as DoctorRegion
from dwtops.dimdoctor doc
inner join srcsfdc.account b on doc.keydoctor=b.account_number__c
where doc.clinicianid is not null
group by doc.clinicianid
) a
cross join Backlog bak
cross join capacity cap
cross join AFABMachineCount afab
cross join FABMachineCount fabMachine
cross join FABHourCapacity fabhour;



