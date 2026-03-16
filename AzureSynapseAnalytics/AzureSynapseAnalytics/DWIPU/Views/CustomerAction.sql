CREATE VIEW [DWIPU].[CustomerAction] AS Select ipu.SESSIONID as SessionID,'Case Assessment Submitted' as ActionName,SUM(ipu._COUNT) as _count,Convert(date,ipu.TS) as TS,_USER as ClinID, MAX(COALESCE(OS,'iOS')) as OS,MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_Other ipu
	WHERE ipu.ACTION='Case Assessment Submitted'
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'Refer Case Successfully Submitted',SUM(ipu._COUNT),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_Other ipu
	WHERE ipu.ACTION='Refer Case Successfully Submitted'
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'SmileView Simulation',SUM(ipu._COUNT),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_other ipu
	WHERE ipu.ACTION IN ('Backend Interaction Completed','Backend Interaction Complete') AND CATEGORY IN ('SmileView Loading') 
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'WebCC Viewed',SUM(ipu._COUNT),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_other ipu
	WHERE ipu.ACTION ='WebCC Viewed'
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'Initial Photo Captured',COUNT(DISTINCT ipu.PHOTOSET_ID),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_upload ipu
	where PHOTOSET_TYPE like 'Primary Order%' OR PHOTOSET_TYPE like 'Case Assessment%'
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'AA Photo Captured',COUNT(DISTINCT ipu.PHOTOSET_ID),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_upload ipu
	where COALESCE(PHOTOSET_TYPE,'Primary Order') like 'Secondary Order%'
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'Progress Photo Captured',COUNT(DISTINCT ipu.PHOTOSET_ID),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_upload ipu
	where COALESCE(PHOTOSET_TYPE,'Primary Order') like 'Progress Photos%'
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'Final Photo Captured',COUNT(DISTINCT ipu.PHOTOSET_ID),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_upload ipu
	where COALESCE(PHOTOSET_TYPE,'Primary Order') like 'Final Photos%'
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'Photo Export',SUM(ipu._COUNT),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_Photo ipu
	WHERE ipu.ACTION IN ('Photo Export','Photoset Export')
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER
	UNION ALL 
	Select ipu.SESSIONID,'Other Actions',SUM(ipu._COUNT),Convert(date,ipu.TS) as TS,_USER,MAX(COALESCE(OS,'iOS')),MAX(APP_VERSION) as APP_VERSION
	FROM SrcSplunk.IPU_screen ipu
	GROUP BY  ipu.SESSIONID,Convert(date,ipu.TS) ,_USER;