CREATE PROC [DWCaseMonitor].[LoadWeeklyCaseStatePercentile] @BatchID [INT],@LastSuccessfullDWTimestamp [DATETIME2](0) AS
  declare @RowsInserted int,@RowsUpdated int
  IF Object_id('tempdb..#CaseStateStatistics') IS NOT NULL 
  DROP TABLE #CaseStateStatistics
  IF Object_id('tempdb..#CaseStateStatisticsAttributes') IS NOT NULL 
  DROP TABLE #CaseStateStatisticsAttributes
  create table #CaseStateStatistics  WITH(DISTRIBUTION = ROUND_ROBIN,	CLUSTERED COLUMNSTORE INDEX) as 
  WITH training AS 
  ( 
              SELECT    a.[SourceSystem] , 
                        a.sapordernumber , 
                        dt.weekofyear , 
                        a.[OrderStatus] as OperationName , 
						Datediff(ss,a.starttime_utc,Isnull(a.completetime_utc,Getutcdate())) as diffinseconds,                                                                                         
                        Datediff(ss,a.[OrderStatusDateTime_UTC],Lead(a.[OrderStatusDateTime_UTC],1) OVER(partition BY a.[SAPOrderNumber] ORDER BY a.[OrderStatusDateTime_UTC])) AS queuetime , 
                        a.[OrderStatus]+'-'+Lead(a.[OrderStatus],1) OVER(partition BY a.[SAPOrderNumber] ORDER BY a.[OrderStatusDateTime_UTC]) AS queuename,
                        b.IsIoScan, 
						b.deliverableType, 
                        b.CountryCode  
			FROM       [dw].[CaseStatehistory] a 
            INNER JOIN dw.dimdate dt ON   dt.keydate=Cast(a.[OrderStatusDateTime_UTC] AS DATE) 
			INNER JOIN	(select a.order_number
							, case when isnull(b.at_ioscan_s,'')='' then 'false' else b.at_ioscan_s end as IsIoScan
							, b.at_deliverabletype_s as DeliverableType 
							, b.at_country_s as CountryCode
							, row_number() over (partition by a.order_number order by lt.at_actualplant_s) as RowNum
							  from	[SrcMESCorp].work_order a 
								 INNER JOIN [SrcMESCorp].uda_order b 
								 ON         a.order_key = b.object_key 
								 INNER JOIN [SrcMESCorp].lot l 
								 ON         l.order_key = a.order_key 
								 INNER JOIN [SrcMESCorp].uda_lot lt 
								 ON         lt.object_key=l.lot_key 
								 where b.at_treatmentcategory_s='Primary' 
								 and a.creation_time>=DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0))
							) b
				on b.order_number = a.sapordernumber and RowNum=1
             WHERE  a.[OrderStatusDateTime_UTC] BETWEEN Dateadd(yy,-1,Dateadd(yy,Datediff(yy,0,Getdate()),0)) AND        Dateadd(yy, Datediff(yy,0,Getdate()), -1) 
			 and starttime_utc is not null and completetime_utc is not null
	),

  final as (
	SELECT DISTINCT 
					SourceSystem, 
                    IsIoscan, 
                    WeekofYear, 
                    OperationName , 
                    DeliverableType, 
                    CountryCode, 
                    'Operation' AS OperationType,
                    Percentile_cont(0.68) within GROUP (ORDER BY diffinseconds) OVER (partition BY sourcesystem,IsIoscan,weekofyear,OperationName,DeliverableType,CountryCode) AS Deviation1,
                    percentile_cont(0.95) within GROUP (order BY diffinseconds) OVER (partition BY sourcesystem,IsIoscan,weekofyear,OperationName,DeliverableType,CountryCode) AS Deviation2,
                    percentile_cont(0.99) within GROUP (order BY diffinseconds) OVER (partition BY sourcesystem,IsIoscan,weekofyear,OperationName,DeliverableType,CountryCode) AS Deviation3
  FROM              training 
  WHERE	          diffinseconds is not null and diffinseconds>=0
  and operationname is not null

  UNION ALL 
  SELECT DISTINCT 
					SourceSystem, 
                    IsIoscan, 
                    WeekofYear, 
                    QueueName , 
                    DeliverableType, 
                    CountryCode,
					'Queue' AS OperationType,                                                                                                                                                                  
                    Percentile_cont(0.68) within GROUP (ORDER BY queuetime) OVER (partition BY sourcesystem,IsIoscan,weekofyear,OperationName,DeliverableType,CountryCode) AS deviation1,
                    percentile_cont(0.95) within GROUP (order BY queuetime) OVER (partition BY sourcesystem,IsIoscan,weekofyear,OperationName,DeliverableType,CountryCode) AS deviation2,
                    percentile_cont(0.99) within GROUP (order BY queuetime) OVER (partition BY sourcesystem,IsIoscan,weekofyear,OperationName,DeliverableType,CountryCode) AS deviation3
  FROM            training 
  WHERE           queuetime is not null and queuetime>=0
  )
  select
				  year(getdate()) as YearNum,
				  SourceSystem, 
                  IsIoscan, 
                  WeekofYear, 
                  OperationName, 
                  DeliverableType, 
                  CountryCode, 
                  OperationType,
                  Deviation1,
                  Deviation2,
                  Deviation3
  FROM            final 
  union all
  select        
				   -1 as YearNum,
				   case when sourcesystem='Corp' then 'MES Corp'
						when sourcesystem = 'MX1' then 'MES_AFAB_MX1'
						when sourcesystem = 'MX2' then 'MES_AFAB_MX2'
						else sourcesystem end as SourceSystem,
				   'false' as IsIoScan,
				   -1 as WeekofYear,
				   OperationName,
				   deliverableType,
				   CountryCode,
				   case when [Type]='OpTime' then 'Operation'
				   else 'Queue' end as OperationType,
				   Deviation1,
				   Deviation2,
				   Deviation3
			  from [DW].[CaseStateTraining]


   create table #CaseStateStatisticsAttributes  WITH(DISTRIBUTION = ROUND_ROBIN,	CLUSTERED COLUMNSTORE INDEX) as
   select distinct YearNum,
                   IsIoscan, 
                   WeekofYear, 
                   DeliverableType, 
                   CountryCode 
          from #CaseStateStatistics 

   Insert into [DW].[CaseStateStatisticsAttributes]
  (
				  YearNum,
                  IsIoscan, 
                  WeekofYear, 
                  DeliverableType, 
                  CountryCode
	)
	select 
				  src.YearNum,
                  src.IsIoscan, 
                  src.WeekofYear, 
                  src.DeliverableType, 
                  src.CountryCode 
    from #CaseStateStatisticsAttributes src
	where not Exists (select * from Dw.[CaseStateStatisticsAttributes] dst where 
						src.YearNum=dst.YearNum and
						src.WeekofYear= dst.WeekofYear and 
						src.CountryCode = dst.CountryCode and
						src.DeliverableType = dst.DeliverableType and
						src.IsIoScan = dst.IsIoScan
						)
     option (label = 'DW.#CaseStateStatisticsAttributes_Insert');

	 delete from [DW].CaseStateStatistics
	 where exists 
	 (select  sk.SKCaseStateStatistic,
				  src.OperationName, 
                  src.OperationType,
                  src.Deviation1,
                  src.Deviation2,
                  src.Deviation3,
				  src.sourcesystem
	   from #CaseStateStatistics src
	  inner join DW.CaseStateStatisticsattributes sk on src.YearNum=sk.YearNum and
						src.IsIoScan = sk.IsIoScan and
						src.WeekofYear= sk.WeekofYear and 
						src.CountryCode = sk.CountryCode and
						src.DeliverableType = sk.DeliverableType 
		where 
		sk.SKCaseStateStatistic = [DW].CaseStateStatistics.SKCaseStateStatistic
     	)
	option (Label = 'DW.CaseStateStatistics_Delete');


  Insert into [DW].CaseStateStatistics
  (
				  SKCaseStateStatistic,
				  OperationName, 
                  OperationType,
                  Deviation1,
                  Deviation2,
                  Deviation3,
				  SourceSystem,
				  IsGlobalStatistic

	)
	select 
				  sk.SKCaseStateStatistic,
				  src.OperationName, 
                  src.OperationType,
                  src.Deviation1,
                  src.Deviation2,
                  src.Deviation3,
				  src.sourcesystem,
				  'False'
	from #CaseStateStatistics src
	inner join DW.CaseStateStatisticsattributes sk on src.YearNum=sk.YearNum and
						src.IsIoScan = sk.IsIoScan and
						src.WeekofYear= sk.WeekofYear and 
    					src.CountryCode = sk.CountryCode and
						src.DeliverableType = sk.DeliverableType 

	option (label = 'DW.CaseStateStatistics_Insert');

	insert into dw.CaseStateStatistics
		(skcasestatestatistic,
			OperationName,
			OperationType,
			Deviation1,
			Deviation2,
			Deviation3,
			SourceSystem,
			IsGlobalStatistic
		)
			select 
			b.skcasestatestatistic,
			a.operationName,
			a.operationType,
			a.Deviation1,
			a.Deviation2,
			a.Deviation3,
			a.sourcesystem,
			'True'
			 from (
					select a.deliverableType,a.CountryCode,b.operationName,b.operationType,b.Deviation1,b.Deviation2,b.Deviation3,b.sourcesystem
					from [DW].[CaseStateStatisticsAttributes] a
					inner join dw.CaseStateStatistics b 
					on a.skcasestatestatistic = b.skcasestatestatistic 
					and YearNum=-1
				) a
			inner join [DW].[CaseStateStatisticsAttributes] b on a.deliverableType=b.deliverableType 
			and a.countrycode=b.countrycode
			left join  dw.CaseStateStatistics c on b.skcasestatestatistic = c.skcasestatestatistic  and a.sourcesystem=c.sourcesystem
			and a.operationname=c.operationname
			where c.operationname is null
			option (label = 'DW.CaseStateStatistics_InsertGlobal');

	exec CTRL.GetLastRowCount @Label = 'DW.CaseStateStatistics_InsertGlobal', @rc = @RowsInserted out

  SELECT @RowsInserted AS rowsinserted, 0 AS rowsupdated