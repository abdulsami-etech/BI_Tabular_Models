CREATE VIEW [DWGlobal].[IDSCurrentStatus]
AS SELECT 
      a.[vip_order_id] as  VIPOrderNumber
      ,a.[vip_order_type] as VIPOrderType
	  ,c.[jde_order_id] as SAPorderNumber
      ,a.[event_type] as IDSEvent
      ,a.[modified_date] as IDSEventDate
      ,a.[cc_mod_date] as CCModDate
      ,a.[cc_accept_date] as CCAcceptDate
      ,a.[promised_ship_date] as PromiseShipDate
	  
     
  FROM [SrcIDS].[tblpuorderstatushistory] as a 
  inner join [SrcIDS].[tblpuorderstatus] as b
   on  a.[order_status_history_id]=b.[order_status_history_id]
  inner join [SrcIDS].[tblcnpatientordermap] as c
  on c.[vip_order_id]=b.[vip_order_id];