CREATE PROC [DWAppLog].[LoadSatSessionCCProCloud] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on


	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0


	if object_id('tempdb..#TempSatSession') is not null
	drop table #TempSatSession


	create table #TempSatSession with (distribution = round_robin, heap) as 
	Select 
		hs.SKSession,
		cc.ADLSBatchID						as ADLSBatchID,
		cc.ADLSTimestamp					as ADLSTimestamp,
		cc.LZBatchID						as LZBatchID,
		convert(char(40), '')				as DWHash,
		cc.caseId as event_caseId,
		cc.clinCheckType as event_clinCheckType, 
		cc.date as event_date,
		cc.deviceId as event_deviceId,
		cc.browser_devicePixelRatio as event_browser_devicePixelRatio,
		cc.browser_isTouchDevice as event_browser_isTouchDevice,
		cc.browser_language as event_browser_language,
		cc.level,
		cc.ts as event_ts,
		cc.browser_userAgent as event_browser_userAgent,
		cc.[version] as event_version,
		cc.browser_viewPortHeight as event_browser_viewPortHeight,
		cc.browser_viewPortWidth as event_browser_viewPortWidth,
		CONVERT(nvarchar(255) , NULL) as event_user,
        cc.trace,
		TRY_CONVERT(int,cc.caseId) as ccid,
		pom.jde_order_id as SAPOrderNumber,
		cc.browser_name as event_browser_name,
		cc.flow as flow,
		CASE WHEN _2MinCC.trace IS NOT NULL THEN 1 ELSE 0 END as Is2MinCC,
		CONVERT(BIGINT,NULL) as SKOrder
	FROM SrcSplunk.CCCloud_AppInit cc
	JOIN DWAppLog.HubSession hs on hs.KeyTrace = cc.trace and hs.KeyTs = cc.TS
    LEFT JOIN (
		SELECT TOP 1 WITH TIES
			t.export_id,
			t.vip_order_id,
			t._Region
		from SrcIDS.tblpuclincheckstatus t
		ORDER BY ROW_NUMBER() over (
				PARTITION BY t.export_id 
				ORDER BY CASE WHEN _Region = 'Global' THEN 1 ELSE 0 END )
		) ccs 
        on ccs.export_id=TRY_CONVERT(int,cc.caseId) 
    LEFT JOIN SrcIDS.tblcnpatientordermap pom 
        on pom.vip_order_id=ccs.vip_order_id and pom.jde_order_id>0 and pom._region=ccs._region
	LEFT JOIN (
			select
				mr.trace as trace
			from SrcSPlunk.CCCloud_MiscRecalc mr
			where mr.[action]='Misc.recalculation.Calculate2MinFlow'
			and JSON_VALUE(mr._data,'$.flag')='true'
			and mr.ADLSTimestamp>=@LastSuccessfullDWTimestamp
			group by trace
		) as _2MinCC on _2MinCC.trace=hs.KeyTrace
	WHERE cc.action='Application.Init'
	and cc.ADLSTimestamp>=@LastSuccessfullDWTimestamp


	/*There is no Case.getInfo since 02/25/2020 , lets use PageUrl to define ClinID*/
    begin 
        if object_id('tempdb..#TempSessionUser') is not null
        drop table #TempSessionUser

        create table #TempSessionUser  with (distribution = round_robin, heap) as  
        select 
			s.SKSession,
			split3.value
        from SrcSplunk.CCCloud_AppInit cc
			join #TempSatSession s on cc.trace= s.trace and s.event_ts = cc.ts
			cross apply STRING_SPLIT(cc.pageUrl, '?') as split
			cross apply STRING_SPLIT(split.value, '&') as split2
			cross apply STRING_SPLIT(split2.value, '=') as split3
        where  cc.action='Application.Init'
			and LEFT(split2.value,4)='user' 
			and split3.value<>'user'

        update #TempSatSession 
		set event_user= tsu.value
        from #TempSessionUser tsu
        where #TempSatSession.SKSession= tsu.SKSession 

    end 

	/* Lets get Order from patient if it haven't been found by exportID.*/
	BEGIN 
		if object_id('tempdb..#SessionOrder') is not null
		drop table #SessionOrder

		CREATE TABLE #SessionOrder WITH (DISTRIBUTION = ROUND_ROBIN,HEAP) AS
		SELECT TOP 1 WITH TIES
			   s.SKSession,
				o.SAP_Order_ID__c as SapOrderNumber
		from #TempSatSession s
		JOIN SrcSplunk.CCCloud_CaseInfo c
			on c.trace=s.trace
		JOIN SrcSFDC_Sensitive.Patient__c p
			on p.Patient_ID__c=c.patient_sha256
		JOIN [SrcSFDC].[Apttus_Config2__Order__c] o
			on p.Id=convert(char(64), hashbytes('sha2_256', convert(varchar,o.Patient_ID__c)), 2)
			and o.Rx_Submission_Date1__c<=s.event_ts
		where s.SAPOrderNumber is null
		ORDER BY ROW_NUMBER() over (PARTITION BY s.SKSession ORDER BY o.Rx_Submission_Date1__c DESC )

		UPDATE #TempSatSession
			SET SAPOrderNumber=#SessionOrder.SapOrderNumber
		from #SessionOrder
		where #TempSatSession.SKSession=#SessionOrder.SKSession
		AND #TempSatSession.SAPOrderNumber IS NULL
	END


	/*SKOrder*/

	UPDATE #TempSatSession
		SET SKOrder=HubOrder.SKOrder
	FROM DW.HubOrder
	WHERE HubOrder.KeyOrder=#TempSatSession.SapOrderNumber


	update #TempSatSession set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						ISNULL(convert(nvarchar,event_caseId),'')
					+'|'+ISNULL(convert(nvarchar,event_clinCheckType),'')
					+'|'+ISNULL(convert(nvarchar,event_date),'')
					+'|'+ISNULL(convert(nvarchar,event_deviceId),'')
					+'|'+ISNULL(convert(nvarchar,event_browser_devicePixelRatio),'')
					+'|'+ISNULL(convert(nvarchar,event_browser_isTouchDevice),'')
					+'|'+ISNULL(convert(nvarchar,event_browser_language),'')
					+'|'+ISNULL(convert(nvarchar,level),'')
					+'|'+ISNULL(convert(nvarchar,event_ts),'')
					+'|'+ISNULL(convert(nvarchar,event_browser_userAgent),'')
					+'|'+ISNULL(convert(nvarchar,event_version),'')
					+'|'+ISNULL(convert(nvarchar,event_browser_viewPortHeight),'')
					+'|'+ISNULL(convert(nvarchar,event_browser_viewPortWidth),'')
					+'|'+ISNULL(convert(nvarchar,event_user),'')
					+'|'+ISNULL(convert(nvarchar,ccid),'')
					+'|'+ISNULL(convert(nvarchar,SAPOrderNumber),'')
					+'|'+ISNULL(convert(nvarchar,event_browser_name),'')
					+'|'+ISNULL(convert(nvarchar,flow),'')
					+'|'+ISNULL(convert(nvarchar,Is2MinCC),'')
					+'|'+ISNULL(convert(nvarchar,SKOrder),'')
				)
			,2)



	--   Create Unknow Element in case there is none
	if not exists (select * from DWAppLog.SatSessionCCProCloud where SKSession = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWAppLog.SatSessionCCProCloud (
				SKSession,
				ADLSBatchID,
				ADLSTimestamp,
				LZBatchID,
				DWBatchID,
				DWHash,
				event_caseId,
				event_clinCheckType,
				event_date,
				event_deviceId,
				event_browser_devicePixelRatio,
				event_browser_isTouchDevice,
				event_browser_language,
				level,
				event_ts,
				event_browser_userAgent,
				event_version,
				event_browser_viewPortHeight,
				event_browser_viewPortWidth,
				event_user,
				Is2MinCC
		)
		Select
				-1 as SKSession,
				-1 as ADLSBatchID,
				'2000-01-01' as ADLSTimestamp,
				0 as LZBatchID,
				0 as DWBatchID,
				@Hash as DWHash,
				NULL as event_caseId,
				NULL as event_clinCheckType,
				NULL as event_date,
				NULL as event_deviceId,
				NULL as event_browser_devicePixelRatio,
				NULL as event_browser_isTouchDevice,
				NULL as event_browser_language,
				NULL as level,
				NULL as event_ts,
				NULL as event_browser_userAgent,
				NULL as event_version,
				NULL as event_browser_viewPortHeight,
				NULL as event_browser_viewPortWidth,
				NULL as event_user,
				0 as Is2MinCC
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update DWAppLog.SatSessionCCProCloud
		set
		     ADLSBatchID = src.ADLSBatchID,
			ADLSTimestamp = src.ADLSTimestamp,
			LZBatchID = src.LZBatchID,
			DWBatchID = @BatchID,
			DWHash = src.DWHash,
			event_caseId = src.event_caseId,
			event_clinCheckType = src.event_clinCheckType,
			event_date = src.event_date,
			event_deviceId = src.event_deviceId,
			event_browser_devicePixelRatio = src.event_browser_devicePixelRatio,
			event_browser_isTouchDevice = src.event_browser_isTouchDevice,
			event_browser_language = src.event_browser_language,
			level = src.level,
			event_ts = src.event_ts,
			event_browser_userAgent = src.event_browser_userAgent,
			event_version = src.event_version,
			event_browser_viewPortHeight = src.event_browser_viewPortHeight,
			event_browser_viewPortWidth = src.event_browser_viewPortWidth,
			event_user = src.event_user,
			ccid = src.ccid,
			SAPOrderNumber = src.SAPOrderNumber,
			event_browser_name = src.event_browser_name,
			flow = src.flow,
			Is2MinCC = src.Is2MinCC,
			SKOrder = src.SKOrder
	from #TempSatSession src
	where DWAppLog.SatSessionCCProCloud.SKSession = src.SKSession
		and DWAppLog.SatSessionCCProCloud.DWHash != src.DWHash
	option (label = 'DWAppLog.LoadSatSessionCCProCloud');
	
	exec CTRL.GetLastRowCount @Label = 'DWAppLog.LoadSatSessionCCProCloud', @rc = @RowsUpdated out


	--INSERT new rows
	INSERT DWAppLog.SatSessionCCProCloud (
		SKSession,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		DWBatchID,
		DWHash,
		event_caseId,
		event_clinCheckType,
		event_date,
		event_deviceId,
		event_browser_devicePixelRatio,
		event_browser_isTouchDevice,
		event_browser_language,
		level,
		event_ts,
		event_browser_userAgent,
		event_version,
		event_browser_viewPortHeight,
		event_browser_viewPortWidth,
		event_user,
		ccid,
		SAPOrderNumber,
		event_browser_name,
		flow,
		Is2MinCC,
		SKOrder
		)
	SELECT
		SKSession,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		@BatchID as DWBatchID,
		DWHash,
		event_caseId,
		event_clinCheckType,
		event_date,
		event_deviceId,
		event_browser_devicePixelRatio,
		event_browser_isTouchDevice,
		event_browser_language,
		level,
		event_ts,
		event_browser_userAgent,
		event_version,
		event_browser_viewPortHeight,
		event_browser_viewPortWidth,
		event_user,
		ccid,
		SAPOrderNumber,
		event_browser_name,
		flow,
		Is2MinCC,
		SKOrder
	from #TempSatSession src
	where not exists(
		select dst.SKSession
		from DWAppLog.SatSessionCCProCloud dst 
		where dst.SKSession = src.SKSession
	)
	option (label = 'DWAppLog.LoadSatSessionCCProCloud');

	exec CTRL.GetLastRowCount @Label = 'DWAppLog.LoadSatSessionCCProCloud', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure