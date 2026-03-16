CREATE VIEW [DWCaseMonitor].[CaseStateMonitor] AS WITH CurrentDayData as (
		select 'MES Corp' as SourceSystem 
		,b.at_DeliverableType_S as DeliverableType
		,b.at_country_s as CountryCode
		,toh.op_name as OperationName
		,DATEDIFF(ss,toh.start_time_u,isnull(toh.Complete_time_u,getdate())) DiffinSeconds
		,DATEDIFF(ss,toh.Complete_time_u,lead(toh.start_time_u,1) over(partition by toh.tobj_key order by toh.start_time_u)) as QueueTime
		,toh.op_name+'-'+lead(toh.op_name,1) over(partition by toh.tobj_key order by toh.start_time_u) as QueueName
		,a.order_number
		,lt.at_actualplant_s as Plant
		from [SrcMESCorp].work_order a with (nolock)
		inner join [SrcMESCorp].uda_order b with (nolock) on a.order_key = b.object_key
		inner join [SrcMESCorp].lot l with (nolock) on l.order_key = a.order_key
		INNER JOIN [SrcMESCorp].uda_lot lt ON lt.object_key=l.lot_key 
		inner join [SrcMESCorp].[TRACKED_OBJECT_HISTORY] toh with(nolock) on toh.tobj_key = l.lot_key  
		where b.at_TreatmentCategory_S='Primary'
		and cast(dateadd(HH,-8,toh.start_time_u) as date) = cast(dateadd(HH,-8,getdate()) as date)
		Union all
		select 'MES_AFAB_MX1' as SourceSystem
		,b.at_DeliverableType_S as DeliverableType
		,b.at_country_s as CountryCode
		,toh.op_name as OperationName
		,DATEDIFF(ss,toh.start_time_u,isnull(toh.Complete_time_u,getdate())) DiffinSeconds
		,DATEDIFF(ss,toh.Complete_time_u,lead(toh.start_time_u,1) over(partition by toh.tobj_key order by toh.start_time_u)) as QueueTime
		,toh.op_name+'-'+lead(toh.op_name,1) over(partition by toh.tobj_key order by toh.start_time_u) as QueueName
		,a.order_number
		, -1 as Plant
		from [SRCMES_AFAB_MX1].work_order a 
		inner join  [SRCMES_AFAB_MX1].uda_order b  on a.order_key = b.object_key
		inner join   [SRCMES_AFAB_MX1].lot l  on l.order_key = a.order_key
		inner join [SRCMES_AFAB_MX1].[TRACKED_OBJECT_HISTORY] toh on toh.tobj_key = l.lot_key  
		where b.at_TreatmentCategory_S='Primary'
		and cast(dateadd(HH,-8,toh.start_time_u) as date) = cast(dateadd(HH,-8,getdate()) as date)
		Union all
		select 'MES_AFAB_MX2' as SourceSystem
		,b.at_DeliverableType_S as DeliverableType
		,b.at_country_s as CountryCode
		,toh.op_name as OperationName
		,DATEDIFF(ss,toh.start_time_u,isnull(toh.Complete_time_u,getdate())) DiffinSeconds
		,DATEDIFF(ss,toh.Complete_time_u,lead(toh.start_time_u,1) over(partition by toh.tobj_key order by toh.start_time_u)) as QueueTime
		,toh.op_name+'-'+lead(toh.op_name,1) over(partition by toh.tobj_key order by toh.start_time_u) as QueueName
		,a.order_number
		, -1 as Plant
		from [SRCMES_AFAB_MX2].work_order a 
		inner join  [SRCMES_AFAB_MX2].uda_order b  on a.order_key = b.object_key
		inner join   [SRCMES_AFAB_MX2].lot l  on l.order_key = a.order_key
		inner join [SRCMES_AFAB_MX2].[TRACKED_OBJECT_HISTORY] toh on toh.tobj_key = l.lot_key  
		where b.at_TreatmentCategory_S='Primary'
		and cast(dateadd(HH,-8,toh.start_time_u) as date) = cast(dateadd(HH,-8,getdate()) as date)
		union all
		SELECT [SourceSystem]
			,'All' as DeliverableType
			,'All' as CountryCode
			, [OrderStatus]
			, 0 as DiffinSeconds
			,datediff(ss,[OrderStatusDateTime_UTC],lead([OrderStatusDateTime_UTC],1) over(partition by [SAPOrderNumber] order by [OrderStatusDateTime_UTC])) as queuetime
			,[OrderStatus]+'-'+lead([OrderStatus],1) over(partition by [SAPOrderNumber] order by [OrderStatusDateTime_UTC]) as QueueName
			,sapordernumber
			, -1 as Plant
		  FROM [dw].[CaseStatehistory]
		  where SourceSystem in ('IDS','MES_FAB_MX2','MES_FAB_MX1')
		  and cast(dateadd(HH,-8,[OrderStatusDateTime_UTC]) as date) = cast(dateadd(HH,-8,getdate()) as date)
)
select a.SourceSystem,
a.OperationName,
a.AbnormalRecords,
a.TotalRecords,
a.Email,
a.Plant,
a.PercentageThreshhold,
a.RecordsThreshhold,
a.AbnormalRecords*1.0/a.TotalRecords*100 as CurrentPercentage
 from (
		select b.SourceSystem,
		b.OperationName,
		sum(case when Deviation3<diffinseconds then 1 else 0 end) as [AbnormalRecords],
		count(1) TotalRecords,
		c.email,
		c.Plant,
		c.PercentageThreshhold,
		c.RecordsThreshhold
		from [DW].[CaseStateTraining] a
		inner join CurrentDayData b on a.OperationName=b.OperationName and a.DeliverableType=b.DeliverableType
		and a.CountryCode = b.CountryCode and a.sourcesystem=b.sourcesystem
		inner join dw.CaseStateAlertConfig c on c.SourceSystem = b.sourcesystem
		and c.OperationName=b.OperationName and c.Plant = b.Plant
		group by b.SourceSystem,b.OperationName,c.Email,c.Plant,c.PercentageThreshhold,
		c.RecordsThreshhold
		having sum(case when a.Deviation3<b.diffinseconds then 1 else 0 end)*100.0/count(1)>max(c.PercentageThreshhold)
		and sum(case when a.Deviation3<b.diffinseconds then 1 else 0 end)>max(c.RecordsThreshhold)
		Union all
		select b.SourceSystem,
		b.QueueName,
		sum(case when Deviation3<QueueTime then 1 else 0 end) as [Abnormal Records],
		count(1) TotalRecords,
		c.Email,
		c.Plant,
		c.PercentageThreshhold,
		c.RecordsThreshhold
		from [DW].[CaseStateTraining] a
		inner join CurrentDayData b on a.OperationName=b.QueueName and a.DeliverableType=b.DeliverableType
		and a.CountryCode = b.CountryCode and a.SourceSystem=b.SourceSystem
		inner join dw.CaseStateAlertConfig c on c.SourceSystem = b.SourceSystem
		and c.OperationName=b.QueueName and c.Plant=b.Plant
		group by b.sourcesystem,b.QueueName,c.email,c.Plant ,c.PercentageThreshhold,
		c.RecordsThreshhold
		having  sum(case when a.Deviation3<b.queuetime then 1 else 0 end)*100.0/count(1)>max(c.PercentageThreshhold)
		and sum(case when a.Deviation3<b.queuetime then 1 else 0 end)>max(c.RecordsThreshhold)
) a left join
[DW].[CaseStateAlertConfigHistory] b
on a.sourcesystem=b.sourcesystem
and a.OperationName=b.OperationName
and a.Plant = b.Plant
and cast(dateadd(HH,-8,b.[AlertSendOutDate]) as Date)=cast(dateadd(HH,-8,getdate()) as date)
where b.sourcesystem is null;