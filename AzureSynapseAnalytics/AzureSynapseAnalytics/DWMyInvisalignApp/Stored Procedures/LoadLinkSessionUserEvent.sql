CREATE PROC [DWMyInvisalignApp].[LoadLinkSessionUserEvent] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [int] AS
begin
	set xact_abort on

	declare 
		@RowsInserted int = 0,
		@RowsUpdated  int = 0,
		@dt datetime=getdate(),
		@sql nvarchar(max),
        @i int =1,
        @end int,
        @SourceTable nvarchar(50),
        @SourceQuery nvarchar(250)

	Select @IsForceFullLoad  = COALESCE(@IsForceFullLoad, 0)

	if object_id('tempdb..#TempEvent') is not null
	drop table #TempEvent
		
	create table #TempEvent
		(
            [KeyTrace]         INT            NOT NULL,
            [KeyUser]          NVARCHAR(50)   NOT NULL,
			SKEvent				int					NOT NULL,
			EventDate			datetimeoffset(2)		NULL,
			EventCount			int					NOT NULL
		)
		with (distribution = round_robin, heap) 


    Select @end= MAX(SKEventRule) from DWMyInvisalignApp.DictEventRule
    
    WHILE @i<=@end
    BEGIN

        IF (Select count(*) FROM DWMyInvisalignApp.DictEventRule der where der.SKEventRule=@i)>0 
        BEGIN
            Select @SourceTable=der.SourceTable,@SourceQuery=der.SourceQuery
            FROM DWMyInvisalignApp.DictEventRule der
            where der.SKEventRule=@i

            SELECT @sql = CONCAT_WS(' ',
                'insert into #TempEvent ([KeyTrace],[KeyUser],SKEvent,EventDate, EventCount)',
                'Select',
                    't.event_params_ga_session_id , ',
                    't.user_pseudo_id,'
                    ,CONVERT(nvarchar(50),@i),'AS SKEvent,' ,
                    'Convert(date,t.event_date) as EventDate,',
                    'SUM(t._count) as EventCount',
                'from ',@SourceTable,'t',
                'where  CASE ',@SourceQuery,' END IS NOT NULL',
                'AND ( t.ADLSTimestamp>=',CONCAT('''',CONVERT(nvarchar(50),@LastSuccessfullDWTimestamp),''''),
				'OR ',CONVERT(nvarchar(1),@IsForceFullLoad ),'=1)',
                'AND t.event_params_ga_session_id IS NOT NULL', 
                'AND t.user_pseudo_id IS NOT NULL',
                'AND TRY_Convert(date,t.event_date) IS NOT NULL',
                'group by t.event_params_ga_session_id,t.user_pseudo_id,Convert(date,t.event_date)'
                )

            EXEC (@sql)
        END            
        print @i
        Select @i=@i+1

    END

	insert into DWMyInvisalignApp.[LinkSessionUserEvent]
	(
		[SKSession],
		[SKUser],
		[SKEvent],
		[EventDate],
		[EventCount],
		[DWBatchID],
		[InsertDateTime]
	)
	select 
		hs.[SKSession],
		hu.[SKUser],
		T.[SKEvent],
		T.[EventDate],
		T.[EventCount],
		@BatchID as [DWBatchID],
		@dt as [InsertDateTime]
	from #TempEvent  T
    JOIN DWMyInvisalignApp.HubSession hs on hs.KeyTrace=t.KeyTrace and hs.KeyUser=t.KeyUser 
    JOIN DWMyInvisalignApp.HubUser hu on hu.KeyUser=t.KeyUser 
	LEFT JOIN [DWMyInvisalignApp].[LinkSessionUserEvent] SE on SE.[SKSession]=hs.[SKSession] and  SE.[SKEvent]=T.[SKEvent] and SE.[EventDate]=T.[EventDate]
	where SE.[SKSession] IS NULL and  t.EventDate is not null
	option (label = 'DWMyInvisalignApp.LinkSessionUserEvent');

	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LinkSessionUserEvent', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure