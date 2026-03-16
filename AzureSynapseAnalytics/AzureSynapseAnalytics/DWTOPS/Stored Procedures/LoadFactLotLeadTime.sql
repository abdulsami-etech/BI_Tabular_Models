CREATE PROC [DWTOPS].[LoadFactLotLeadTime] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	if not exists (select * from DWTOPS.FactLotLeadTime)
		set @IsFullLoad = 1

	IF OBJECT_ID('tempdb..#WorkingTrackedObjHistory') IS NOT NULL
	DROP TABLE #WorkingTrackedObjHistory

	IF OBJECT_ID('tempdb..#WorkingEpub') IS NOT NULL
	DROP TABLE  #WorkingEpub

	IF OBJECT_ID('tempdb..#pool_tag') IS NOT NULL
	DROP TABLE  #pool_tag

	
	IF OBJECT_ID('tempdb..#IDSTras') IS NOT NULL
	DROP TABLE  #IDSTras
	
		
	IF OBJECT_ID('tempdb..#HOLD_TIME') IS NOT NULL
	DROP TABLE #HOLD_TIME

			
	IF OBJECT_ID('tempdb..#Final') IS NOT NULL
	DROP TABLE #Final

	
	if object_id ('DWTOPS.Temp_LeadTimeOrdersToLoad', 'U') is not null
		drop table DWTOPS.Temp_LeadTimeOrdersToLoad
    
	create table DWTOPS.Temp_LeadTimeOrdersToLoad (OrderNumber nchar(18) not null) with (distribution = round_robin, heap)
	ALTER TABLE DWTOPS.Temp_LeadTimeOrdersToLoad ADD CONSTRAINT PK_Temp_LeadTimeOrdersToLoad PRIMARY KEY NONCLUSTERED (OrderNumber) NOT ENFORCED

	
	if @IsFullLoad = 0
	begin
		insert into DWTOPS.Temp_LeadTimeOrdersToLoad (OrderNumber)

		select 	d.[order_number]
		FROM [SrcMESCorp].[tracked_object_history]  as a
		inner join [SrcMESCorp].[LOT]  as c
		on c.[lot_key]=a.[tobj_key]
		inner join [SrcMESCorp].[Work_Order] as d
		on d.order_key=c.order_key
		where a.ADLSTimestamp >= @LastSuccessfullDWTimestamp
			
		union

		SELECT b.[jde_order_id]
		FROM [SrcIDS].[tblpuorderstatushistory] AS a
		inner join (SELECT jde_order_id,vip_order_id,_Region, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) AS b ON a.vip_order_id=b.viP_order_id and a._Region = b._Region and b.latest =1
		AND a.event_type in ('RxFormTranslated','RxFormInTranslation','ClinCheckTranslated','ClinCheckInTranslation') -- Tagging time already considers Translation time?!
		AND a.cc_mod_count =0
		where b.[jde_order_id] is not null and
		a.[modified_date] >= DATEADD(HOUR,-8,@LastSuccessfullDWTimestamp)
	end

	--Get the Distinct Lot History from last Run
	CREATE TABLE #WorkingTrackedObjHistory
	WITH (
		DISTRIBUTION = HASH([tobj_key]),
		CLUSTERED COLUMNSTORE INDEX
	)  
	AS
	SELECT 
		a.[ADLSBatchID]
		,a.[ADLSTimestamp]
		,a.[LZBatchID]
		,a.[tobj_history_key]
		,a.[tobj_key]
		,a.[route_name]
		,a.[op_name]
		,a.[complete_reason]
		,a.[complete_count]
		,a.[complete_time_u]
		,a.[start_time_u]
		,d.[order_number]
		FROM [SrcMESCorp].[tracked_object_history]  as a
		inner join [SrcMESCorp].[LOT]  as c
		on c.[lot_key]=a.[tobj_key]
		inner join [SrcMESCorp].[Work_Order] as d
		on d.order_key=c.order_key
		where a.complete_time_u >= '20160101' and 
		(        @IsFullLoad = 1
	                   or	
			d.[order_number] in (Select OrderNumber from DWTOPS.Temp_LeadTimeOrdersToLoad) )


	--Get Tagging StartTime and EpubEnd times------
	CREATE TABLE #WorkingEpub
		WITH (
			DISTRIBUTION = HASH([tobj_key]),
			CLUSTERED COLUMNSTORE INDEX
		)  
		AS
	SELECT  
			ePub_TOH.tobj_key as tobj_key,
			MIN(Tag.complete_time_u) AS [TAG COMPLETE TIME_U],
			MIN(ePUB_TOH.complete_time_u) AS [EPUB COMPLETE TIME_U],
			DATEDIFF(hh,MAX(Tag.complete_time_u),MIN(ePub_TOH.complete_time_u)) AS [HOURS],
			0 as IsAlta
		FROM
		#WorkingTrackedObjHistory ePub_TOH
		INNER JOIN  
		(	SELECT 
				tobj_key, 
				MIN(complete_time_u) AS complete_time_u
			FROM 
				#WorkingTrackedObjHistory
			WHERE op_name IN ('Tagging') GROUP BY  tobj_key ) Tag 
			ON (Tag.tobj_key = ePub_TOH.tobj_key)

		WHERE
		    epub_toh.route_name <> 'TX MTP Case Setup'  -----Non Alta Cases
			AND 
			ePub_TOH.op_name  IN  ('ePub')

			AND ePub_TOH.complete_reason  IN  ('Auto 1', 'Auto 2', 'Auto2', 'OK')

			AND ePub_TOH.complete_time_u = (  SELECT
											MIN(modb.complete_time_u )  FROM
											#WorkingTrackedObjHistory modb
											WHERE	modb.tobj_key = ePub_TOH.tobj_key and modb.op_name IN ('ePub')
											 AND  modb.complete_reason  IN  ('Auto 1', 'Auto 2', 'Auto2','OK') )
		Group by ePub_TOH.tobj_key


		
/*********************************************************************
START - ALTA GO LOGIC 
**********************************************************************/

CREATE TABLE #pool_tag
	WITH (
		DISTRIBUTION = HASH([tobj_key]),
		CLUSTERED COLUMNSTORE INDEX
	)  
	AS

	SELECT  
		TOH.tobj_key,
		MIN(Tag.complete_time_u) AS complete_time_u,
		TOH.order_number
	FROM
		#WorkingTrackedObjHistory as TOH
		INNER JOIN  
		(SELECT 
				tobj_key, 
				MIN(complete_time_u) AS complete_time_u
			FROM #WorkingTrackedObjHistory 
			WHERE op_name IN ('Tagging')
			 GROUP BY  tobj_key ) Tag 
		ON Tag.tobj_key = TOH.tobj_key

	WHERE
		TOH.op_name  IN  ('Pre-MTP TFU')
		AND TOH.complete_reason  IN  ('OK')
		AND (TOH.start_time_u = (	SELECT MIN(modb.start_time_u )
									FROM #WorkingTrackedObjHistory  modb
									WHERE modb.tobj_key = TOH.tobj_key and modb.op_name IN ('Pre-MTP TFU') AND  modb.complete_reason  IN  ('OK')))
	GROUP BY 
			TOH.tobj_key
		,TOH.order_number			


----- START GET IDS MTP GENERATED TIME (##CHECK IDS Time ZONE)
	insert into #WorkingEpub (tobj_key,[TAG COMPLETE TIME_U],[EPUB COMPLETE TIME_U],[Hours],IsAlta) -- Add all ALTA cases to general pool.
	select 
		tag.tobj_key,
		tag.complete_time_u as [Tag complete time],
		CASE WHEN (IDS.[complete_time] IS NULL)THEN epubGo.epub_complete_time ELSE IDS.[complete_time] END [op_complete_time],
		CASE WHEN (IDS.[complete_time] IS NULL) THEN DATEDIFF(HOUR,tag.complete_time_u, epubGo.epub_complete_time) ELSE DATEDIFF(HOUR,tag.complete_time_u,IDS.[complete_time]) END [HOURS],
		1
		--,at.patientid 
	from 
		#pool_tag as tag
		LEFT join 
		(
			SELECT 
				m.jde_order_id,
				MIN(DATEADD(HOUR,-CAST(CAST(DATENAME(TZoffset, h.[modified_date] AT TIME ZONE 'Pacific Standard Time' ) as varchar(3)) as int),h.[modified_date]) ) as [complete_time]
			from 
				[SrcIDS].tblputreatmentstatushistory as h
				inner join 
				(SELECT jde_order_id,vip_order_id,_Region, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) as m on m.vip_order_id = h.primary_vip_order_id and h._Region = m._Region and m.latest =1
			where 
				 h.tx_status_id = 2502 --CLINCHECK_MTP_AWAITING_REVIEW
				 Group by m.jde_order_id
		) IDS on IDS.[jde_order_id] = tag.[order_number]
		LEFT JOIN
		(
			SELECT  
				TOH.tobj_key, 
				MIN(complete_time_u) AS epub_complete_time
			FROM 
				#WorkingTrackedObjHistory as  TOH
				inner join 
				(select tobj_key from #pool_tag) t on t.tobj_key = TOH.tobj_key
			WHERE
				TOH.op_name  IN  ('ePub')
				AND complete_reason  IN  ('Auto 1', 'Auto 2', 'Auto2', 'OK')
				AND (TOH.complete_time_u = (	SELECT
												MIN(modb.complete_time_u )
											FROM
												#WorkingTrackedObjHistory as  modb WITH (NOLOCK)
											WHERE
												modb.tobj_key = TOH.tobj_key and modb.op_name IN ('ePub') AND  modb.complete_reason  IN  ('Auto 1', 'Auto 2', 'Auto2','OK')))
			GROUP BY TOH.tobj_key

		) epubGo on epubGo.tobj_key = tag.tobj_key
	WHERE NOT (IDS.[complete_time] IS  NULL AND epubGo.epub_complete_time IS  NULL)	
							
	

-----END GET IDS MTP GENERATED TIME




/*********************************************************************
END - ALTA GO LOGIC 
**********************************************************************/



---------get IDS Translations time--------


CREATE TABLE #IDSTras
	WITH (
		DISTRIBUTION = HASH([jde_order_id]),
		CLUSTERED COLUMNSTORE INDEX
	)  
	AS

		SELECT T.[jde_order_id], SUM([translationtime]) AS [transaltiontime]
		FROM (	SELECT *,DATEDIFF(HOUR,a.[modified_date],a.[nextEvent_Time]) AS [translationtime]
				from (	SELECT
							 r.[jde_order_id]
							,r.[event_type]
							,r.[event_id]
							,r.[modified_date]
							,lead(r.[event_type]) OVER (PARTITION BY r.[jde_order_id],LEFT(r.event_type,6) ORDER BY r.[modified_date]) nextEvent_Type
                            ,lead(r.[modified_date]) OVER (PARTITION BY r.[jde_order_id],LEFT(r.event_type,6) ORDER BY r.[modified_date]) nextEvent_Time
						FROM(
								SELECT 
									 a.[event_type]
									,a.[event_id]
									,a.[modified_date]
									,b.[jde_order_id]
									,a.cc_mod_count
									,MIN(a.modified_date) OVER (PARTITION BY [event_id]) AS lastEvent			-- Get only the first event when 'event_id' is duplicated
								FROM 
									[SrcIDS].[tblpuorderstatushistory] AS a
									inner join 
									(SELECT jde_order_id,vip_order_id,_Region, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) AS b ON a.vip_order_id=b.viP_order_id and a._Region = b._Region and b.latest =1
										AND a.event_type in ('RxFormTranslated','RxFormInTranslation','ClinCheckTranslated','ClinCheckInTranslation') -- Tagging time already considers Translation time?!
										AND cc_mod_count =0 --1st clicheck
										AND EXISTS (	SELECT 1
														FROM #WorkingTrackedObjHistory AS ord
														WHERE ord.[order_number]=b.[jde_order_id]
													)
							) r WHERE lastEvent = [modified_date]
					) a
				WHERE a.nextEvent_Time IS NOT NULL															-- Delete the last not associated row (not end time)
					AND 
					a.[event_type] IN ('RxFormInTranslation','ClinCheckInTranslation')) T					-- Get only the rows with the start and end time
		GROUP BY T.[jde_order_id]

------------------------------------------
CREATE TABLE  #HOLD_TIME
	WITH (
		DISTRIBUTION = HASH(tobj_key)
	)  
	AS
		
		SELECT 
			HOLD_TOH.tobj_key,
			SUM(ISNULL(DATEDIFF(hh,HOLD_TOH.start_time_u,HOLD_TOH.complete_time_u),0)) as HoldHours
		FROM
			#WorkingTrackedObjHistory HOLD_TOH
			INNER JOIN 
			#WorkingEpub TOH WITH (NOLOCK) ON (HOLD_TOH.tobj_key = TOH.tobj_key AND HOLD_TOH.complete_time_u  < TOH.[EPUB COMPLETE TIME_U]  )
		WHERE
			HOLD_TOH.op_name  IN  ('Clinical Hold', 'Materials Pending')--, 'CR Incoming Hold', 'CCMod Hold')--changed by gsalas 9/27/2016 excluded from Hold Operations
		GROUP BY	
			HOLD_TOH.tobj_key
		 




		   
	CREATE TABLE #Final
	WITH (
		DISTRIBUTION = HASH([DgnLotKey]), heap

	)  
	AS
			SELECT at.ADLSBatchID,
				at.ADLSTimestamp,
				at.LZBatchID,
			    TOH.[EPUB COMPLETE TIME_U] AS [DgnCompleteDateTime],
				AT.[tobj_key] as [DgnLotKey],
				ISNULL(CONVERT(VARCHAR(8), TOH.[EPUB COMPLETE TIME_U], 112), -1) AS [SKCompleteDate],
				--TOH.[TAG COMPLETE TIME_U] AS Tag_complete_time,
				--TOH.[EPUB COMPLETE TIME_U] AS op_complete_time_U,
				ISNULL(IDT.transaltiontime,0) AS [TranslationHours],
				ISNULL(HOLD.HoldHours,0) AS [HoldTimeHours],
				(TOH.[HOURS] + ISNULL(IDT.transaltiontime,0))  - ISNULL(HOLD.HoldHours,0) AS [LeadTimeHour],
				0 as [CCModCount]--Firstpass

			FROM
				(Select tobj_key
					,order_number
					,min([ADLSBatchID]) as ADLSBatchID
					,min([ADLSTimestamp]) as ADLSTimestamp
					,min([LZBatchID]) as LZBatchID
					from #WorkingTrackedObjHistory
					group by tobj_key , order_number 
				) as AT
				INNER JOIN
				#WorkingEpub TOH WITH (NOLOCK) ON (AT.tobj_key=TOH.tobj_key)
				LEFT JOIN
				#HOLD_TIME HOLD WITH (NOLOCK) ON (HOLD.tobj_key=TOH.tobj_key)
				LEFT JOIN 
				#IDSTras  as IDT ON IDT.[jde_order_id]=AT.Order_number

	begin tran

   DELETE FROM [DWTOPS].[FactLotLeadTime]
	WHERE EXISTS (
		SELECT * FROM #Final s
		WHERE s.[DgnLotKey] = [DWTOPS].[FactLotLeadTime].[DgnLotKey]
	)

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactPatientOrder_Delete', @rc = @RowsUpdated out
	

      INSERT INTO [DWTOPS].[FactLotLeadTime]
           ([ADLSBatchID]
			,[ADLSTimestamp]
			,[LZBatchID]
			,[DWBatchID]
           ,[DgnCompleteDateTime]
           ,[DgnLotKey]
		   ,[SKCompleteDate]
           ,[TranslationHours]
           ,[HoldTimeHours]
           ,[LeadTimeHour]
           ,[CCModCount])
		Select 
			[ADLSBatchID]
			,[ADLSTimestamp]
			,[LZBatchID]
			,@BatchId
           ,[DgnCompleteDateTime]
           ,[DgnLotKey]
		   ,[SKCompleteDate]
           ,[TranslationHours]
           ,[HoldTimeHours]
           ,[LeadTimeHour]
           ,[CCModCount]		
		from #Final
		where [LeadTimeHour]>=0
		option (label = 'DWTOPS.LoadFactLotLeadTime_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotLeadTime_Insert', @rc = @RowsInserted out

	commit tran

	select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated

END