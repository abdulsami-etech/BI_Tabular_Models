CREATE PROC [DWCaseMonitor].[LoadCaseStatePercentile] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
 Declare @RowsInserted int,@RowsUpdated int
 IF Object_id('dw.CaseStateTrainingPrevious', 'U') IS NOT NULL 
 DROP TABLE dw.CaseStateTrainingPrevious 
 CREATE TABLE dw.CaseStateTrainingPrevious  WITH(DISTRIBUTION = ROUND_ROBIN,	CLUSTERED COLUMNSTORE INDEX) as 
 WITH Training as (
		SELECT a.[SourceSystem]
			,b.DeliverableType 
			,b.countrycode 
			,a.[OrderStatus] as OperationName
			,Datediff(ss,a.starttime_utc,Isnull(a.completetime_utc,Getutcdate())) as OperationTime  
			,DATEDIFF(ss,a.[completeTime_UTC],lead(a.[startTime_UTC],1) over(partition by a.[SAPOrderNumber] order by a.[startTime_UTC])) as queuetime
			,a.[OrderStatus]+'-'+lead(a.[OrderStatus],1) over(partition by a.[SAPOrderNumber] order by a.[startTime_UTC]) as QueueName
		  FROM [dw].[CaseStatehistory] a
		  inner join
				(select
					uo.at_deliverabletype_s as DeliverableType,
					uo.at_country_s as CountryCode,
					wo.order_number
					from [SrcMESCorp].work_order wo
					INNER JOIN [SrcMESCorp].uda_order uo ON wo.order_key = uo.object_key 
					where uo.at_treatmentcategory_s='Primary'
					and wo.creation_time>DATEADD(yy,-2,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0))
				) b on b.order_number=a.sapordernumber 
		  where [StartTime_UTC] >=DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0))
		  and completeTime_utc is not null and orderstatus is not null
		)
select  distinct SourceSystem,OperationName,DeliverableType,CountryCode,'OpTime' as Type,
 PERCENTILE_CONT(0.68) WITHIN GROUP (ORDER BY OperationTime) OVER (PARTITION BY SourceSystem,OperationName,DeliverableType,CountryCode)  as Deviation1,
 PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY OperationTime) OVER (PARTITION BY SourceSystem,OperationName,DeliverableType,CountryCode)  as Deviation2,
 PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY OperationTime) OVER (PARTITION BY SourceSystem,OperationName,DeliverableType,CountryCode)  as Deviation3
 from training
 where OperationTime is not null and OperationTime>=0
Union All
select distinct SourceSystem,QueueName,DeliverableType,CountryCode,'QueueTime' as Type,
 PERCENTILE_CONT(0.68) WITHIN GROUP (ORDER BY QueueTime) OVER (PARTITION BY SourceSystem,OperationName,DeliverableType,CountryCode) AS Deviation1,
 PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY QueueTime) OVER (PARTITION BY SourceSystem,OperationName,DeliverableType,CountryCode) AS Deviation2,
 PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY QueueTime) OVER (PARTITION BY SourceSystem,OperationName,DeliverableType,CountryCode) AS Deviation3  
from training
where queuetime is not null and queuetime>=0


  IF Object_id('dw.CaseStateTrainingOld', 'U') IS NOT NULL 
  Drop Table dw.CaseStateTrainingOld
  RENAME object dw.CaseStateTraining TO CaseStateTrainingOld 
  RENAME object dw.CaseStateTrainingPrevious TO CaseStateTraining
  DROP TABLE dw.CaseStateTrainingOld 

  select @RowsInserted = count(*) 
	from dw.CaseStateTraining
  SELECT @RowsInserted AS rowsinserted, 0 AS rowsupdated