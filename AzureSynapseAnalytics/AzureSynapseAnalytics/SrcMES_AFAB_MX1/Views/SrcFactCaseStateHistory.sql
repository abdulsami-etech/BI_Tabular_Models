CREATE VIEW [SrcMES_AFAB_MX1].[SrcFactCaseStateHistory]
AS SELECT a.adlsbatchid                                 AS ADLSBatchID, 
       a.adlstimestamp                               AS ADLSTimestamp, 
       a.lzbatchid                                   AS LZBatchID, 
       c.order_number                                AS [SAPOrdernumber], 
       a.op_name                                     AS [OrderStatus], 
	   a.[start_time_u]                              AS [StartTime_UTC], 
	   a.[complete_time_u]                           AS [CompleteTime_UTC], 
       Isnull(a.[complete_time_u], a.[start_time_u]) AS [OrderStatusDateTime_UTC], 
       a.[tobj_history_key]                          AS [HistoryKey], 
       'MES_AFAB_MX1'                                AS [SourceSystem] 

FROM   [SrcMES_AFAB_MX1].[tracked_object_history] AS a 
       INNER JOIN [SrcMES_AFAB_MX1].[lot] AS b 
               ON a.[tobj_key] = b.lot_key 
       INNER JOIN [SrcMES_AFAB_MX1].[work_order] AS c 
               ON b.order_key = c.order_key
  --where Isnull(a.[complete_time_u], a.[start_time_u]) > Dateadd(day, -180, Getutcdate());
  where Isnull(a.[complete_time_u], a.[start_time_u]) >=DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0));