CREATE VIEW [DWCaseMonitor].[CaseStateHistory] AS select  a.[DWBatchID]
      ,a.[SAPOrdernumber]
      ,a.[OrderStatus]
      ,a.[StartTime_UTC]
      ,a.[CompleteTime_UTC]
      ,a.[OrderStatusDateTime_UTC]
      ,a.[HistoryKey]
      ,a.[SourceSystem] 
	  , ctalls.SKCaseStateStatistic as SKCaseStateStatistic           
from dw.casestatehistory a
inner join dw.dimDate dt on cast(a.startTime_utc as date) = dt.KeyDate
left join
(select uo.at_ioscan_s as IsIOscan,
	uo.at_deliverabletype_s as deliverabletype,
	uo.at_country_s as countrycode,
	wo.order_number,
	row_number() over (partition by wo.order_number order by lt.at_actualplant_s) as RowNum
from
 [SrcMESCorp].work_order wo
INNER JOIN [SrcMESCorp].uda_order uo ON wo.order_key = uo.object_key 
inner join [SrcMESCorp].lot l with (nolock) on l.order_key = wo.order_key
INNER JOIN [SrcMESCorp].uda_lot lt ON lt.object_key=l.lot_key 
where uo.at_treatmentcategory_s='Primary'
and wo.creation_time > DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0))
) mesord on mesord.order_number=a.sapordernumber and mesord.rownum=1
left join dw.[CaseStateStatisticsAttributes] ctall on ctall.countrycode = mesord.countrycode
		and ctall.deliverabletype = mesord.deliverabletype
		and ctall.yearNum=-1
left join dw.[CaseStateStatistics] ctalls on ctalls.skcasestatestatistic = ctall.skcasestatestatistic
		and ctalls.operationName=a.orderstatus
		and ctalls.sourcesystem=a.sourcesystem
where  [StartTime_UTC] >Dateadd(day, -10, Getutcdate());