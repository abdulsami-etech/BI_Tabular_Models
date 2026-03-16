CREATE VIEW [TABTOPS].[FactAFABOrderReworks] AS With OrdersFinshed
as
(SELECT w.order_key,w.order_number,ls.lot_key,uo.at_Plant_S as KeyPlant,
       uo.at_Country_S as KeyCountry,CAST(w.finished_time as date) as KeyDate,
       --(c.quantity + ls.quantity_serialized) as quantity
	    ls.quantity_yield_initial as quantity,'Plant1' as Plant

from SrcMES_AFAB_MX1.WORK_ORDER w with(nolock) 
     inner join SrcMES_AFAB_MX1.UDA_Order uo with(nolock) on w.order_key = uo.object_key
     inner join SrcMES_AFAB_MX1.Lot ls with(nolock) on w.order_key = ls.order_key
   --inner join SrcMES_AFAB_MX1.LOT_FLOW_TRACKING as c   with (nolock)  ON ls.lot_key = c.lot_key 
   inner join SrcMES_AFAB_MX1.TRACKED_OBJECT_STATUS as d ON ls.lot_key = d.tobj_key 
where d.route_name = 'Fab'
and w.finished_time between dateadd(month,-13,getdate()) and getdate()
and uo.[at_TreatmentOption_S] not LIKE '%RETAINER%'

union all

SELECT w.order_key,w.order_number,ls.lot_key,uo.at_Plant_S as KeyPlant,
       uo.at_Country_S as KeyCountry,CAST(w.finished_time as date) as KeyDate,
       --(c.quantity + ls.quantity_serialized) as quantity
	    ls.quantity_yield_initial as quantity,'Plant2' as Plant

from SrcMES_AFAB_MX2.WORK_ORDER w with(nolock) 
     inner join SrcMES_AFAB_MX2.UDA_Order uo with(nolock) on w.order_key = uo.object_key
     inner join SrcMES_AFAB_MX2.Lot ls with(nolock) on w.order_key = ls.order_key
   --inner join SrcMES_AFAB_MX2.LOT_FLOW_TRACKING as c   with (nolock)  ON ls.lot_key = c.lot_key 
   inner join SrcMES_AFAB_MX2.TRACKED_OBJECT_STATUS as d ON ls.lot_key = d.tobj_key 
where d.route_name = 'Fab'
and w.finished_time between dateadd(month,-13,getdate()) and getdate()
and uo.[at_TreatmentOption_S] not LIKE '%RETAINER%'

union all

SELECT w.order_key,w.order_number,ls.lot_key,uo.at_Plant_S as KeyPlant,
       uo.at_Country_S as KeyCountry,CAST(w.finished_time as date) as KeyDate,
	    ls.quantity_yield_initial as quantity,'Plant3' as Plant

from SrcMES_AFAB_CN.WORK_ORDER w with(nolock) 
     inner join SrcMES_AFAB_CN.UDA_Order uo with(nolock) on w.order_key = uo.object_key
     inner join SrcMES_AFAB_CN.Lot ls with(nolock) on w.order_key = ls.order_key
   inner join SrcMES_AFAB_CN.TRACKED_OBJECT_STATUS as d ON ls.lot_key = d.tobj_key 
where d.route_name = 'Fab'
and w.finished_time between dateadd(month,-13,getdate()) and getdate()
and uo.[at_TreatmentOption_S] not LIKE '%RETAINER%'

)
,Reworks as
(  Select distinct o.order_key,o.KeyCountry,o.KeyPlant,o.Plant,o.KeyDate,u.unit_key,h.complete_reason,
 CASE WHEN h.complete_reason like 'AR%' then 1 else null end as 'AlignerReworks',
  CASE WHEN h.complete_reason like 'MR%' then 1 else null end as 'SLReworks'
 from 
OrdersFinshed as o 
inner join SrcMES_AFAB_MX1.Lot as l on l.order_key=o.order_key
inner join SrcMES_AFAB_MX1.UNIT u on u.pre_serialized_lot_key=l.lot_key 
inner join SrcMES_AFAB_MX1.TRACKED_OBJECT_HISTORY h on h.tobj_key = u.unit_key
where h.complete_reason like 'AR%' or h.complete_reason like 'MR%'
and o.Plant='Plant1'

union all

Select distinct o.order_key,o.KeyCountry,o.KeyPlant,o.Plant,o.KeyDate,u.unit_key,h.complete_reason,
 CASE WHEN h.complete_reason like 'AR%' then 1 else null end as 'AlignerReworks',
  CASE WHEN h.complete_reason like 'MR%' then 1 else null end as 'SLReworks'
 from 
OrdersFinshed as o 
inner join SrcMES_AFAB_MX2.Lot as l on l.order_key=o.order_key
inner join SrcMES_AFAB_MX2.UNIT u on u.pre_serialized_lot_key=l.lot_key 
inner join SrcMES_AFAB_MX2.TRACKED_OBJECT_HISTORY h on h.tobj_key = u.unit_key
where h.complete_reason like 'AR%' or h.complete_reason like 'MR%'
and o.Plant='Plant2'

union all

Select distinct o.order_key,o.KeyCountry,o.KeyPlant,o.Plant,o.KeyDate,u.unit_key,h.complete_reason,
 CASE WHEN h.complete_reason like 'AR%' then 1 else null end as 'AlignerReworks',
  CASE WHEN h.complete_reason like 'MR%' then 1 else null end as 'SLReworks'
 from 
OrdersFinshed as o 
inner join SrcMES_AFAB_CN.Lot as l on l.order_key=o.order_key
inner join SrcMES_AFAB_CN.UNIT u on u.pre_serialized_lot_key=l.lot_key 
inner join SrcMES_AFAB_CN.TRACKED_OBJECT_HISTORY h on h.tobj_key = u.unit_key
where h.complete_reason like 'AR%' or h.complete_reason like 'MR%'
and o.Plant='Plant3'

)
,
OrderSummary
as
(Select KeyDate,KeyCountry,KeyPlant,Plant,
COUNT(distinct order_key) as CompletedOrderQty,
sum(quantity)  as        CompletedAlignerQty
 from OrdersFinshed  as a
 group by KeyDate,KeyCountry,KeyPlant,Plant
 )

 ,ReworkSummary
 as
 (Select KeyDate,KeyCountry,KeyPlant,Plant,
COUNT(distinct order_key) as ReworkOrderQty,
COUNT(distinct unit_key) as ReworkAlignersQty,
SUM(ISNULL(AlignerReworks,0)) as AlignerIssueReworkQty,
Sum(ISNULL(SLReworks,0)) as SLAIssueReworkQty
 from  Reworks 
 group by KeyDate,KeyCountry,KeyPlant,Plant)


Select o.KeyCountry,o.KeyDate,o.KeyPlant,o.Plant,
o.CompletedOrderQty,
(o.CompletedOrderQty-ISNULL(r.ReworkOrderQty,0))as NoReworkOrderQty,
ISNULL(r.ReworkOrderQty,0) as ReworkOrderQty,
CAST(o.CompletedAlignerQty as int) as CompletedAlignerQty,
ISNULL(r.ReworkAlignersQty,0) as ReworkAlignersQty,
ISNULL(r.AlignerIssueReworkQty,0) as AlignerIssueReworkQty,
ISNULL(r.SLAIssueReworkQty,0) as SLAIssueReworkQty,
(CASE WHEN o.CompletedOrderQty > 0 THEN (1 - 1.0 * ISNULL(r.ReworkOrderQty,0) / o.CompletedOrderQty) ELSE 0 END) AS OrdersYield,
(CASE WHEN o.CompletedAlignerQty  > 0 THEN (1.0 * ISNULL(r.SLAIssueReworkQty,0) / o.CompletedAlignerQty) ELSE 0 END) AS SLAScrap, 
(CASE WHEN o.CompletedAlignerQty  > 0 THEN (1.0 * ISNULL(r.AlignerIssueReworkQty,0) / o.CompletedAlignerQty) ELSE 0 END) AS AlignerScrap, 
(CASE WHEN o.CompletedAlignerQty > 0 THEN (1.0 * ISNULL(r.ReworkAlignersQty,0) / o.CompletedAlignerQty) ELSE 0 END) AS TotalScrap

 from OrderSummary as o
left join ReworkSummary as r
on o.KeyCountry=r.KeyCountry
and o.KeyDate=r.KeyDate
and o.KeyPlant=r.KeyPlant;