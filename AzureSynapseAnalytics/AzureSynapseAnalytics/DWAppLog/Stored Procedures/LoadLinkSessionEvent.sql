CREATE PROC [DWAppLog].[LoadLinkSessionEvent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare 
		@RowsInserted int = 0,
		@RowsUpdated  int = 0,
		@dt datetime=getdate(),
		@sql nvarchar(max),
		@case nvarchar(max)


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
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),'''')
		)

		exec ( @sql)

	END
	/*		Feature Big	 part 1*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_FeatureBig' 
		AND e.SourceSystemCode='CCProCLoud'
		AND e.SKEvent<=80


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
		from SrcSplunk.CCCloud_FeatureBig t 
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),'''')
		)

		exec ( @sql)

	END

	/*		Feature Big	 part 2*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_FeatureBig' 
		AND e.SourceSystemCode='CCProCLoud'
		AND e.SKEvent>80


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
		from SrcSplunk.CCCloud_FeatureBig t 
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),'''')
		)

		exec ( @sql)

	END

	/*		FeatureSmall part 1	*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_FeatureSmall' 
		AND e.SourceSystemCode='CCProCLoud'
		AND e.SKEvent<=140

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
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),'''')
		)

		exec ( @sql)

	END

	/*		FeatureSmall part 2	*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_FeatureSmall' 
		AND e.SourceSystemCode='CCProCLoud'
		AND e.SKEvent>140


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
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),'''')
		)

		exec ( @sql)

	END
	/*	Other	*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_Other' 
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
		from SrcSplunk.CCCloud_Other t 
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),'''')
		)

		exec ( @sql)

	END
	/*	MoveAttachment	*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_MoveAttachment' 
		AND e.SourceSystemCode='CCProCLoud'

		SELECT @sql = CONCAT_WS(' ',
		'insert into #TempEvent ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
        'Select 
            tt.trace as trace,
            MIN(tt.ts) as ts,
            tt.action as action,
            tt.SKEvent as SKEvent,
            MIN(tt.EventDate) as EventDate,
            SUM(EventCount) as EventCount,
            SourceSystemCode as SourceSystemCode
        FROM (
        ',
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
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),''''),
        ') as tt',
        'GROUP BY 
            tt.trace,
            tt.action,
            tt.SKEvent,
            SourceSystemCode'
		)

		exec ( @sql)

	END
	/*	ToothMove	*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_ToothMove' 
		AND e.SourceSystemCode='CCProCLoud'

		SELECT @sql = CONCAT_WS(' ',
		'insert into #TempEvent ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
        'Select 
            tt.trace as trace,
            MIN(tt.ts) as ts,
            tt.action as action,
            tt.SKEvent as SKEvent,
            MIN(tt.EventDate) as EventDate,
            SUM(EventCount) as EventCount,
            SourceSystemCode as SourceSystemCode
        FROM (
        ',
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
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),''''),
        ') as tt',
        'GROUP BY 
            tt.trace,
            tt.action,
            tt.SKEvent,
            SourceSystemCode'
		)

		exec ( @sql)

	END

	/*	Misc.Recalc	*/
	BEGIN

		Select @case = STRING_AGG (e.SourceQuery,' ') 
		FROM DWAppLog.DictEventRule e 
		WHERE e.SourceTable='SrcSplunk.CCCloud_MiscRecalc' 
		AND e.SourceSystemCode='CCProCLoud'

		SELECT @sql = CONCAT_WS(' ',
		'insert into #TempEvent ([KeyTrace],[KeyTs],[KeyAction],SKEvent,EventDate, EventCount, [SourceSystemCode])',
        'Select 
            tt.trace as trace,
            MIN(tt.ts) as ts,
            tt.action as action,
            tt.SKEvent as SKEvent,
            MIN(tt.EventDate) as EventDate,
            SUM(EventCount) as EventCount,
            SourceSystemCode as SourceSystemCode
        FROM (
        ',
		'Select
			t.trace , 
			t.ts, 
			t.action, 
			CASE ', @case,'
			END AS SKEvent, 
			t.ts as EventDate, 
			t._count as EventCount, 
			''CCProCLoud'' as [SourceSystemCode] 
		from SrcSplunk.CCCloud_MiscRecalc t 
		where  CASE ',@case,' END IS NOT NULL',
		'AND t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),''''),
        ') as tt',
        'GROUP BY 
            tt.trace,
            tt.action,
            tt.SKEvent,
            SourceSystemCode'
		)

		exec ( @sql)

	END

	if object_id('tempdb..#TempSessionEvent') is not null
	drop table #TempSessionEvent

	create table #TempSessionEvent
		(
			[SKSession]				int					not null,
			[SKEvent]				int					not null,
			[EventDate]				datetimeoffset		not null,
			[EventCount]			int					not null,
			[SourceSystemCode]		varchar(10)			NOT NULL
		)
		with (distribution = round_robin, heap) 

	insert #TempSessionEvent ([SKSession],[SKEvent],[EventDate],[EventCount],[SourceSystemCode])
	Select
		s.SKSession,
		e.SKEvent,
		e.EventDate,
		e.EventCount,
		e.SourceSystemCode
	FROM #TempEvent e
	JOIN [DWAppLog].[HubSession] s on e.KeyTrace= s.KeyTrace and e.SourceSystemCode= s.SourceSystemCode
	where e.EventDate IS NOT NULL


	insert into DWAppLog.[LinkSessionEvent]
	(
		[SKSession],
		[SKEvent],
		[EventDate],
		[EventCount],
		[DWBatchID],
		[InsertDateTime],
		[SourceSystemCode]
	)
	select 
		T.[SKSession],
		T.[SKEvent],
		T.[EventDate],
		T.[EventCount],
		@BatchID as [DWBatchID],
		@dt as [InsertDateTime],
		T.[SourceSystemCode]
	from #TempSessionEvent T
	LEFT JOIN [DWAppLog].[LinkSessionEvent] SE on SE.[SKSession]=T.[SKSession] and  SE.[SKEvent]=T.[SKEvent] and SE.[EventDate]=T.[EventDate]
	where SE.[SKSession] IS NULL
	option (label = 'DWAppLog.LoadHubSession');

	exec CTRL.GetLastRowCount @Label = 'DWAppLog.LoadHubSession', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure
GO
