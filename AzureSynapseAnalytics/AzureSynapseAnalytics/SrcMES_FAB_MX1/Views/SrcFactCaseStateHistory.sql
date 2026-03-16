CREATE VIEW [SrcMES_FAB_MX1].[SrcFactCaseStateHistory]
AS SELECT ac.adlsbatchid                                 AS ADLSBatchID, 
       ac.adlstimestamp                              AS ADLSTimestamp, 
       ac.lzbatchid                                 AS LZBatchID, 
       ub.x_orderno_s                                AS [SAPOrdernumber], 
       ac.[reporting_location]                          AS  [OrderStatus],
	 MAX(ac.[trx_time])                               AS [StartTime_UTC], 
	 MAX(ac.[trx_time])                               AS [CompleteTime_UTC],
	 MAX(ac.[trx_time])                               AS [OrderStatusDateTime_UTC],
	 CONCAT(ub.x_orderno_s,ac.trx_key)        AS [HistoryKey],
	'MES_FAB_MX1'                                  AS [SourceSystem] 

FROM   [SrcMES_FAB_MX1].batch a WITH (nolock) 
       INNER JOIN [SrcMES_FAB_MX1].uda_batch ub WITH (nolock) 
               ON ub.object_key = a.batch_key and ub.x_orderno_s is not null
       INNER JOIN [SrcMES_FAB_MX1].sublot s WITH (nolock) 
               ON s.batch_key = a.batch_key 
       INNER JOIN [SrcMES_FAB_MX1].uda_sublot us WITH (nolock) 
               ON us.object_key = s.sublot_key 
       INNER JOIN [SrcMES_FAB_MX1].carrier c WITH (nolock) 
               ON c.carrier_key = us.x_trayjobkey_i 
       INNER JOIN (SELECT [trx_key],DATEADD(HOUR,-CAST(CAST(DATENAME(TZoffset, [trx_time] AT TIME ZONE 'Mountain Standard Time' ) as varchar(3)) as int),[trx_time]) as [trx_time]
	                      ,[reporting_location],[carrier_key],max(adlsbatchid) as adlsbatchid ,max(adlstimestamp) as adlstimestamp,max(lzbatchid)  as  lzbatchid
                          FROM [SrcMES_FAB_MX1].[ALGN_CARRIER_EVENT] WITH (nolock) 
                          group by [trx_key],[trx_time],[reporting_location],[carrier_key]) ac 
               ON c.carrier_key = ac.carrier_key 
       INNER JOIN [SrcMES_FAB_MX1].object_state os WITH (nolock) 
               ON os.object_key = c.carrier_key 
       INNER JOIN [SrcMES_FAB_MX1].fsm_config_item fsm WITH (nolock) 
               ON fsm.fsm_config_item_key = os.fsm_config_item_key 
                  AND fsm.fsm_relationship_name = 'JobStatus' 
				  AND  trx_time>=DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0))
                  --AND ac.trx_time > Dateadd(day, -180, Getutcdate()) 
		
GROUP  BY ub.x_orderno_s, 
          ac.reporting_location,
		 ac.trx_key,
		 ac.adlsbatchid ,
		 ac.adlstimestamp ,
		 ac.lzbatchid;