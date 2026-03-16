CREATE VIEW [SrcIDS].[SrcFactCaseStateHistory]
AS SELECT a.adlsbatchid                                 AS ADLSBatchID, 
       CASE WHEN a.adlstimestamp >b.adlstimestamp  then    a.adlstimestamp else b.adlstimestamp end    AS ADLSTimestamp, 
       a.lzbatchid                                   AS LZBatchID, 
       b.jde_order_id                                AS [SAPOrdernumber], 
       a.[event_type]                                AS [OrderStatus], 
        DATEADD(HOUR,-CAST(CAST(DATENAME(TZoffset, a.[modified_date] AT TIME ZONE 'Pacific Standard Time' ) as varchar(3)) as int),a.[modified_date])  as [StartTime_UTC],
              DATEADD(HOUR,-CAST(CAST(DATENAME(TZoffset, a.[modified_date] AT TIME ZONE 'Pacific Standard Time' ) as varchar(3)) as int),a.[modified_date])  as [CompleteTime_UTC],
              DATEADD(HOUR,-CAST(CAST(DATENAME(TZoffset, a.[modified_date] AT TIME ZONE 'Pacific Standard Time' ) as varchar(3)) as int),a.[modified_date])  as  [OrderStatusDateTime_UTC], 
       a.[order_status_history_id]                   AS [HistoryKey], 
       case when a._region = 'China' then 'IDS-China' else 'IDS' end [SourceSystem] 
FROM    [SrcIDS].[tblpuorderstatushistory]  AS a 
          left join ( select [vip_order_id],[order_status_history_id] from [SrcIDS].[tblpuorderstatushistory] where 
                                    _region='Global'
                                    and [modified_date] >=DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0))
                                    
                                    ) ch on a.[vip_order_id] = ch.[vip_order_id]
                                    and a.[order_status_history_id] = ch.[order_status_history_id] and a._region='China'
       INNER JOIN [SrcIDS].[tblcnpatientordermap] AS b 
               ON a.[vip_order_id] = b.[vip_order_id] and a._Region = b._Region
   where a.[modified_date] >=DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,Getutcdate()),0))
  and b.jde_order_id is not null
  and a.[event_type] is not null
  and ch.vip_order_id is null;