CREATE VIEW [TABTOPS].[TraslationEvents]
AS SELECT b.[jde_order_id] as OrderNumber,
a.[event_type] as EventType,
a.[event_id],
a.cc_mod_count,MIN(a.modified_date) OVER (PARTITION BY [event_id]) AS EventDateTime	-- Get only the first event when 'event_id' is duplicated
FROM 
[SrcIDS].[tblpuorderstatushistory] AS a
inner join 
(SELECT jde_order_id,vip_order_id,_Region, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) AS b ON a.vip_order_id=b.viP_order_id and a._Region = b._Region and b.latest =1
AND a.event_type in ('RxFormTranslated','RxFormInTranslation','ClinCheckTranslated','ClinCheckInTranslation') -- Tagging time already considers Translation time?!
AND cc_mod_count =0;