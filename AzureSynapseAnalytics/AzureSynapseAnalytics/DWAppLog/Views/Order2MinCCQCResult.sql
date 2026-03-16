CREATE VIEW DWAppLog.Order2MinCCQCResult as 
WITH QCResult as (
	Select 
		req.tobj_key,
		MIN(COALESCE(req.start_time_u,res.start_time_u)) as QCStartTimeUTC,
		MAX(CASE WHEN res.complete_reason='Fail' THEN 1 END) as HasQCFail,
		MAX(CASE WHEN res.complete_reason='Fail' THEN res.complete_time_u END) as QCFailDateUTC,
		MAX(CASE WHEN res.complete_reason='OK' THEN 1 END) as HasQCPass,
		MAX(CASE WHEN res.complete_reason='OK' THEN res.complete_time_u END) as QCPassDateUTC
	from SrcMesCorp.TRACKED_OBJECT_HISTORY req
	LEFT JOIN SrcMesCorp.TRACKED_OBJECT_HISTORY res 
	on req.tobj_key=res.tobj_key 
	and res.complete_reason IN ('OK','Fail') 
	and res.op_name='ClinCheck'
	where req.complete_reason='QC-Req' and req.op_name='ClinCheck' and req.complete_user_name='mes_corp_sub'
	group by 	req.tobj_key
)
SELECT 
	wo.order_number AS SAPOrderNumber,
	qcr.QCStartTimeUTC,
	qcr.HasQCFail,	
	qcr.QCFailDateUTC,	
	qcr.HasQCPass	,
	qcr.QCPassDateUTC
FROM QCResult qcr
join SrcMesCorp.Lot lo on lo.lot_key = qcr.tobj_key and lo.creation_time>='2021-01-01'
join SrcMesCorp.Work_Order wo on wo.order_key = lo.order_key and wo.creation_time>='2021-01-01'