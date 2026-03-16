CREATE PROC [DWAppLog].[LoadSatSessionCount] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [int] AS
begin
	set xact_abort on

	declare 
		@RowsInserted int = 0,
		@RowsUpdated  int = 0,
		@dt datetime=getdate(),
		@sql nvarchar(max),
		@case nvarchar(max)

	Select @IsForceFullLoad  = COALESCE(@IsForceFullLoad, 0)
	Select @LastSuccessfullDWTimestamp= CASE WHEN @IsForceFullLoad=1 THEN '2000-01-01' ELSE @LastSuccessfullDWTimestamp END

	/*Session to load*/
	BEGIN
		/* I'm going to update all sessions that had any events after @LastSuccessfullDWTimestamp */

		if object_id('tempdb..#SessionToUpdate') is not null
		drop table #SessionToUpdate
		
		create table #SessionToUpdate
			(
				[KeyTrace]						NVARCHAR (100)	NOT NULL,
				[MaxTs]							DATETIMEOFFSET	NOT NULL
			)
			with (distribution = round_robin, heap) 

		INSERT #SessionToUpdate (KeyTrace,maxts)
		Select t.trace, MAX(t.maxts) as maxts
		from 
		(
			Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_3DMod where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
			UNION ALL Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_FeatureBig where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
			UNION ALL Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_FeatureSmall where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
			UNION ALL Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_MoveAttachment where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
			UNION ALL Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_Other where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
			UNION ALL Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_Setting where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
			UNION ALL Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_ToothMove where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
			UNION ALL Select trace,MAX(ts) as maxts from SrcSplunk.CCCloud_AppInit where ADLSTimestamp>@LastSuccessfullDWTimestamp group by trace
		) as t
		group by t.trace
	END


	/*Session counts*/
	BEGIN
		if object_id('tempdb..#SatSessionCount') is not null
		drop table #SatSessionCount
		
		create table #SatSessionCount
			(
				[SKSession]                     INT             NOT NULL,
				[KeyTrace]						NVARCHAR (100)	NOT NULL,
				[KeyTs]							DATETIMEOFFSET	NOT NULL,
				[DWHash]                        CHAR (40)       NOT NULL,
				[_3DControls]					INT				NOT NULL,
				[CCMod]							INT				NOT NULL,
				[CCA]							INT				NOT NULL,
				[IFVModification]				INT				NOT NULL,
				[IFVReview]						INT				NOT NULL,
				[DurationSecond]				INT				NOT NULL
			)
			with (distribution = round_robin, heap) 


		INSERT #SatSessionCount (
			[SKSession],
			[KeyTrace]	,
			[KeyTs]		,
			[DWHash]    ,
			[_3DControls],
			[CCMod]		,
			[CCA]		,
			[IFVModification],
			[IFVReview]		,
			[DurationSecond])
		select 
			hs.[SKSession],
			hs.[KeyTrace]	,
			hs.[KeyTs]		,
			'' as [DWHash]    ,
			0 as [_3DControls],
			0 as [CCMod]		,
			0 as [CCA]		,
			0 as [IFVModification],
			0 as [IFVReview]		,
			CASE WHEN DATEDIFF(second,KeyTS,stu.MaxTS)>0 THEN DATEDIFF(second,KeyTS,stu.MaxTS)
				ELSE 0 END as [DurationSecond]
		from DWAppLog.HubSession hs 
		JOIN #SessionToUpdate stu on stu.KeyTrace=hs.KeyTrace
		where hs.SourceSystemCode='CCProCloud'
	END

	/* 3D controls */
	BEGIN
		--Declare	@sql nvarchar(max),		@case nvarchar(max)
		if object_id('tempdb..#TempEvent') is not null
		drop table #TempEvent
		
		create table #TempEvent
			(
				[KeyTrace]			nvarchar(100)		NOT NULL,
				[KeyTs]				datetimeoffset		NOT NULL,
				[KeyAction]			nvarchar(255)		NOT NULL,
				SKEvent				int					NOT NULL,
				EventDate			datetimeoffset(2)		NULL,
				EventCount			int					NOT NULL,
				[SourceSystemCode]		varchar(10)			NOT NULL
			)
			with (distribution = round_robin, heap) 

		/*		CCCloud_3DMod	*/
		BEGIN

			Select @case = STRING_AGG (e.SourceQuery,' ') 
			FROM DWAppLog.DictEventRule e 
			JOIN [DWAppLog].[DictEvent] de on de.SKEvent=e.SKEvent and de.H_Level1='3D Modifications'
			WHERE e.SourceTable='SrcSplunk.CCCloud_3DMod' 
			AND e.SourceSystemCode='CCProCLoud'


			SELECT @sql = CONCAT_WS(' ',
			'insert into #TempEvent ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
			'Select
				t.trace , 
				t.ts, 
				t.action, 
				CASE ', @case,'
				END AS SKEvent, 
				t.ts as EventDate, 
				t._count as EventCount, 
				''CCProCLoud'' as [SourceSystemCode] 
			from SrcSplunk.CCCloud_3DMod t 
			JOIN #SessionToUpdate stu on stu.KeyTrace=t.Trace
			where  CASE ',@case,' END IS NOT NULL'
			)
			exec ( @sql)

		END	

			/*	CCCloud_FeatureSmall	*/
		BEGIN

			Select @case = STRING_AGG (e.SourceQuery,' ') 
			FROM DWAppLog.DictEventRule e 
			JOIN [DWAppLog].[DictEvent] de on de.SKEvent=e.SKEvent and de.H_Level1='3D Modifications'
			WHERE e.SourceTable='SrcSplunk.CCCloud_FeatureSmall' 
			AND e.SourceSystemCode='CCProCLoud'


			SELECT @sql = CONCAT_WS(' ',
			'insert into #TempEvent ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
			'Select
				t.trace , 
				t.ts, 
				t.action, 
				CASE ', @case,'
				END AS SKEvent, 
				t.ts as EventDate, 
				t._count as EventCount, 
				''CCProCLoud'' as [SourceSystemCode] 
			from SrcSplunk.CCCloud_FeatureSmall t 
			JOIN #SessionToUpdate stu on stu.KeyTrace=t.Trace
			where  CASE ',@case,' END IS NOT NULL'
			)
			exec ( @sql)

		END

			/*	CCCloud_MoveAttachment	*/
		BEGIN

			Select @case = STRING_AGG (e.SourceQuery,' ') 
			FROM DWAppLog.DictEventRule e 
			JOIN [DWAppLog].[DictEvent] de on de.SKEvent=e.SKEvent and de.H_Level1='3D Modifications'
			WHERE e.SourceTable='SrcSplunk.CCCloud_MoveAttachment' 
			AND e.SourceSystemCode='CCProCLoud'


			SELECT @sql = CONCAT_WS(' ',
			'insert into #TempEvent ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
			'Select
				t.trace , 
				t.ts, 
				t.action, 
				CASE ', @case,'
				END AS SKEvent, 
				t.ts as EventDate, 
				t._count as EventCount, 
				''CCProCLoud'' as [SourceSystemCode] 
			from SrcSplunk.CCCloud_MoveAttachment t 
			JOIN #SessionToUpdate stu on stu.KeyTrace=t.Trace
			where  CASE ',@case,' END IS NOT NULL'
			)
			exec ( @sql)

		END

		/*	CCCloud_ToothMove	*/
		BEGIN

			Select @case = STRING_AGG (e.SourceQuery,' ') 
			FROM DWAppLog.DictEventRule e 
			JOIN [DWAppLog].[DictEvent] de on de.SKEvent=e.SKEvent and de.H_Level1='3D Modifications'
			WHERE e.SourceTable='SrcSplunk.CCCloud_ToothMove' 
			AND e.SourceSystemCode='CCProCLoud'


			SELECT @sql = CONCAT_WS(' ',
			'insert into #TempEvent ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
			'Select
				t.trace , 
				t.ts, 
				t.action, 
				CASE ', @case,'
				END AS SKEvent, 
				t.ts as EventDate, 
				t._count as EventCount, 
				''CCProCLoud'' as [SourceSystemCode] 
			from SrcSplunk.CCCloud_ToothMove t 
			JOIN #SessionToUpdate stu on stu.KeyTrace=t.Trace
			where  CASE ',@case,' END IS NOT NULL'
			)
			exec ( @sql)

		END


		UPDATE #SatSessionCount
		SET _3DControls=te.EventCount
		from #SatSessionCount ssc
		JOIN (
			Select KeyTrace,SUM(EventCount) as EventCount
			from #TempEvent
			group BY KeyTrace
			) te on te.KeyTrace=ssc.KeyTrace

		if object_id('tempdb..#TempEvent') is not null
		drop table #TempEvent
	
	END

	/*CCA*/
	BEGIN
		if object_id('tempdb..#TempEventCCA') is not null
		drop table #TempEventCCA

		create table #TempEventCCA
			(
				[KeyTrace]			nvarchar(100)		NOT NULL,
				[KeyTs]				datetimeoffset		NOT NULL,
				[KeyAction]			nvarchar(255)		NOT NULL,
				SKEvent				int					NOT NULL,
				EventDate			datetimeoffset(2)		NULL,
				EventCount			int					NOT NULL,
				[SourceSystemCode]		varchar(10)			NOT NULL
			)
			with (distribution = round_robin, heap) 

		/*	CCA from CCCloud_Other	*/
		BEGIN

			Select @case = STRING_AGG (e.SourceQuery,' ') 
			FROM DWAppLog.DictEventRule e 
			JOIN [DWAppLog].[DictEvent] de on de.SKEvent=e.SKEvent and de.FullName='CaseApprove.ApproveConfirmationDialog.Proceed'
			WHERE e.SourceTable='SrcSplunk.CCCloud_Other' 
			AND e.SourceSystemCode='CCProCLoud'


			SELECT @sql = CONCAT_WS(' ',
			'insert into #TempEventCCA ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
			'Select
				t.trace , 
				t.ts, 
				t.action, 
				CASE ', @case,'
				END AS SKEvent, 
				t.ts as EventDate, 
				t._count as EventCount, 
				''CCProCLoud'' as [SourceSystemCode] 
			from SrcSplunk.CCCloud_Other t 
			JOIN #SessionToUpdate stu on stu.KeyTrace=t.Trace
			where  CASE ',@case,' END IS NOT NULL' 
			)
			exec ( @sql)

		END

		UPDATE #SatSessionCount
		SET CCA= COALESCE(te.EventCount,0)
		from #SatSessionCount ssc
		JOIN (
			Select KeyTrace,SUM(EventCount) as EventCount
			from #TempEventCCA
			group BY KeyTrace
			) te on te.KeyTrace=ssc.KeyTrace

		if object_id('tempdb..#TempEventCCA') is not null
		drop table #TempEventCCA

	END
	
	/*CCMod*/
	BEGIN
		if object_id('tempdb..#TempEventCCMod') is not null
		drop table #TempEventCCMod

		create table #TempEventCCMod
			(
				[KeyTrace]			nvarchar(100)		NOT NULL,
				[KeyTs]				datetimeoffset		NOT NULL,
				[KeyAction]			nvarchar(255)		NOT NULL,
				SKEvent				int					NOT NULL,
				EventDate			datetimeoffset(2)		NULL,
				EventCount			int					NOT NULL,
				[SourceSystemCode]		varchar(10)			NOT NULL
			)
			with (distribution = round_robin, heap) 

		/*	CCA from CCCloud_Other	*/
		BEGIN

			Select @case = STRING_AGG (e.SourceQuery,' ') 
			FROM DWAppLog.DictEventRule e 
			JOIN [DWAppLog].[DictEvent] de on de.SKEvent=e.SKEvent and de.FullName='CaseModify.SubmitModifications'
			WHERE e.SourceTable='SrcSplunk.CCCloud_Other' 
			AND e.SourceSystemCode='CCProCLoud'


			SELECT @sql = CONCAT_WS(' ',
			'insert into #TempEventCCMod ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
			'Select
				t.trace , 
				t.ts, 
				t.action, 
				CASE ', @case,'
				END AS SKEvent, 
				t.ts as EventDate, 
				t._count as EventCount, 
				''CCProCLoud'' as [SourceSystemCode] 
			from SrcSplunk.CCCloud_Other t 
			JOIN #SessionToUpdate stu on stu.KeyTrace=t.Trace
			where  CASE ',@case,' END IS NOT NULL' 
			)
			exec ( @sql)

		END

		UPDATE #SatSessionCount
		SET CCMod= COALESCE(te.EventCount,0)
		from #SatSessionCount ssc
		JOIN (
			Select KeyTrace,SUM(EventCount) as EventCount
			from #TempEventCCMod
			group BY KeyTrace
			) te on te.KeyTrace=ssc.KeyTrace

		if object_id('tempdb..#TempEventCCMod') is not null
		drop table #TempEventCCMod

	END

	/*IFV*/
	BEGIN
		if object_id('tempdb..#TempEventIFV') is not null
		drop table #TempEventIFV

		create table #TempEventIFV
			(
				[KeyTrace]			nvarchar(100)		NOT NULL,
				[KeyTs]				datetimeoffset		NOT NULL,
				[KeyAction]			nvarchar(255)		NOT NULL,
				SKEvent				int					NOT NULL,
				EventDate			datetimeoffset(2)		NULL,
				EventCount			int					NOT NULL,
				[SourceSystemCode]		varchar(10)			NOT NULL
			)
			with (distribution = round_robin, heap) 

		/*	IFV from CCCloud_FeatureSmall	*/
		BEGIN

			Select @case = STRING_AGG (e.SourceQuery,' ') 
			FROM DWAppLog.DictEventRule e 
			JOIN [DWAppLog].[DictEvent] de on de.SKEvent=e.SKEvent and de.FullName='Features.Smile.Show'
			WHERE e.SourceTable='SrcSplunk.CCCloud_FeatureSmall' 
			AND e.SourceSystemCode='CCProCLoud'


			SELECT @sql = CONCAT_WS(' ',
			'insert into #TempEventIFV ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
			'Select
				t.trace , 
				t.ts, 
				t.action, 
				CASE ', @case,'
				END AS SKEvent, 
				t.ts as EventDate, 
				t._count as EventCount, 
				''CCProCLoud'' as [SourceSystemCode] 
			from SrcSplunk.CCCloud_FeatureSmall t 
			JOIN #SessionToUpdate stu on stu.KeyTrace=t.Trace
			where  CASE ',@case,' END IS NOT NULL' 
			)
			exec ( @sql)

		END

		UPDATE #SatSessionCount
		SET IFVModification = CASE WHEN CCMOD>0 then te.EventCount else 0 END,
			IFVReview = CASE WHEN COALESCE(CCMOD,0)=0 then te.EventCount else 0 END
		from #SatSessionCount ssc
		JOIN (
			Select KeyTrace,SUM(EventCount) as EventCount
			from #TempEventIFV
			group BY KeyTrace
			) te on te.KeyTrace=ssc.KeyTrace

		if object_id('tempdb..#TempEventIFV') is not null
		drop table #TempEventIFV

	END

	/*Hash*/
	BEGIN
		update #SatSessionCount set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						ISNULL(convert(nvarchar,_3DControls),'')
					+'|'+ISNULL(convert(nvarchar,CCMod),'')
					+'|'+ISNULL(convert(nvarchar,CCA),'')
					+'|'+ISNULL(convert(nvarchar,IFVModification),'')
					+'|'+ISNULL(convert(nvarchar,IFVReview),'')
					+'|'+ISNULL(convert(nvarchar,DurationSecond),'')
					)
			,2)
	END

	/*Update*/
	BEGIN
		-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update DWAppLog.SatSessionCount
		set
			DWBatchID = @BatchID,
			DWHash = src.DWHash,
			[_3DControls]		= src.[_3DControls],
			[CCMod]				= src.[CCMod],
			[CCA]				= src.[CCA],
			[IFVModification]	= src.[IFVModification],
			[IFVReview]			= src.[IFVReview],
			[DurationSecond]	= src.[DurationSecond]
	from #SatSessionCount src
	where DWAppLog.SatSessionCount.SKSession = src.SKSession
		and DWAppLog.SatSessionCount.DWHash != src.DWHash
	option (label = 'DWAppLog.LoadSatSessionCount');
	
	exec CTRL.GetLastRowCount @Label = 'DWAppLog.LoadSatSessionCount', @rc = @RowsUpdated out

	END

	/*INSERT new rows*/
	BEGIN
	INSERT DWAppLog.SatSessionCount (
		SKSession,
		DWBatchID,
		DWHash,
		[_3DControls],
		[CCMod]		,
		[CCA]		,
		[IFVModification],
		[IFVReview]		,
		[DurationSecond]
		)
	SELECT
		SKSession,
		@BatchID as DWBatchID,
		DWHash,
		[_3DControls],
		[CCMod]		,
		[CCA]		,
		[IFVModification],
		[IFVReview]		,
		[DurationSecond]		
	from #SatSessionCount src
	where not exists(
		select dst.SKSession
		from DWAppLog.SatSessionCount dst 
		where dst.SKSession = src.SKSession
	)
	option (label = 'DWAppLog.LoadSatSessionCount');

	exec CTRL.GetLastRowCount @Label = 'DWAppLog.LoadSatSessionCount', @rc = @RowsInserted out

	END

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure
