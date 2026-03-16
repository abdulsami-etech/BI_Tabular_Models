CREATE VIEW [SrcMESCorp].[SrcFactCaseStateHistory]
AS SELECT a.adlsbatchid                                 AS ADLSBatchID, 
       a.adlstimestamp                               AS ADLSTimestamp, 
       a.lzbatchid                                   AS LZBatchID, 
       c.order_number                                AS [SAPOrdernumber], 
       a.op_name                                     AS [OrderStatus], 

	  a.[start_time_u]                               AS [StartTime_UTC], 
	  a.[complete_time_u]                            AS [CompleteTime_UTC],
       Isnull(a.[complete_time_u], a.[start_time_u]) AS [OrderStatusDateTime_UTC], 
       a.[tobj_history_key]                          AS [HistoryKey], 
       'MES Corp'                                    AS [SourceSystem] 
FROM   [SrcMESCorp].[tracked_object_history] AS a 
       INNER JOIN [SrcMESCorp].[lot] AS b 
               ON a.[tobj_key] = b.lot_key 
       INNER JOIN [SrcMESCorp].[work_order] AS c 
               ON b.order_key = c.order_key
        where Isnull(a.[complete_time_u], a.[start_time_u]) >=DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0));