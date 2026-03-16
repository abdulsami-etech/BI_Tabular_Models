CREATE PROC [CTRL].[DWRefreshSCDTable] @BatchID [int],@MainSchemaName [varchar](32),@MainTableName [varchar](128),@SessionID [varchar](36) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted				int = 0
		,	@RowsUpdated				int = 0
		,	@CurrentDate				date = getdate()
		,	@StaticStartDate			varchar(10) = '1900-01-01' --do not change it
		,	@StaticEndDate				varchar(10) = '2099-01-01' --do not change it
		,	@ErrorMsg					varchar(max)
		,	@TableNameSCD				varchar(160)
		,	@FullTableName				varchar(160)
		,	@FullTableNameSCD			varchar(170)
		,	@TempTableName				varchar(170)
		,	@SQL						varchar(max)
		,	@SQLUnicode					nvarchar(max)
		,	@SKField					varchar(128)
		,	@KeyField					varchar(128)
		,	@ColumnList					varchar(max)
		,	@ColumnListWithAlias		varchar(max)
		,	@ColumnListForUpdate		varchar(max)
		,	@NewLine					varchar(2) = char(13) + char(10)

	if @SessionID is null
		set @SessionID = convert(varchar(36), newid())

	set @FullTableName = quotename(@MainSchemaName) + '.' + quotename(@MainTableName)
	set @TableNameSCD = @MainTableName + 'SCD'
	set @FullTableNameSCD = quotename(@MainSchemaName) + '.' + quotename(@TableNameSCD)
	set @TempTableName = '#tmp' + @MainTableName + 'SCD'

	if object_id (@FullTableNameSCD, 'U') is null
	begin
		set @ErrorMsg = 'SCD table ' + @FullTableNameSCD + ' does not exist';
		throw 53001, @ErrorMsg, 1; 
	end

	select top (1) @SKField = column_name
	from information_schema.columns
	where table_schema = @MainSchemaName
		and table_name = @MainTableName
		and column_name like 'SK%'
	order by ordinal_position

	if @SKField is null
	begin
		set @ErrorMsg = 'SK field is not found in the table ' + @FullTableName;
		throw 53001, @ErrorMsg, 1; 
	end

	select top (1) @KeyField = column_name
	from information_schema.columns
	where table_schema = @MainSchemaName
		and table_name = @MainTableName
		and column_name like 'Key%'
	order by ordinal_position

	if @KeyField is null
	begin
		set @ErrorMsg = 'Key field is not found in the table ' + @FullTableName;
		throw 53001, @ErrorMsg, 1; 
	end

	set @SQL = 'if object_id(''tempdb..' + @TempTableName + ''') is not null' + @NewLine
		+ '	drop table ' + @TempTableName + @NewLine

	select	@ColumnList = ColumnList
		,	@ColumnListWithAlias = ColumnListWithAlias
		,	@ColumnListForUpdate = ColumnListForUpdate
	from (
		select	string_agg(quotename(main.column_name), ',' + @NewLine) as ColumnList
			,	string_agg('t.' + quotename(main.column_name), ',' + @NewLine) as ColumnListWithAlias
			,	string_agg(quotename(main.column_name) + ' = h.' + quotename(main.column_name), ',' + @NewLine) as ColumnListForUpdate
		from information_schema.columns main
		inner join information_schema.columns scd on scd.table_schema = main.table_schema
											and scd.table_name = @TableNameSCD
											and scd.column_name = main.column_name
		where main.table_schema = @MainSchemaName
			and main.table_name = @MainTableName
			and main.column_name not in ('ADLSBatchID', 'ADLSTimestamp', 'LZBatchID', 'DWBatchID', 'DWHash', @SKField, @KeyField) --internal fields
	) t

	set @SQL += @NewLine + 'declare @StaticStartDate date = ''' + @StaticStartDate + '''' + @NewLine
			+ ', @StaticEndDate date = ''' + @StaticEndDate + '''' + @NewLine
			+ ', @CurrentDate date = ''' + convert(varchar(10), @CurrentDate, 120) + '''' + @NewLine

	set @SQL += @NewLine + 'create table ' + @TempTableName + ' with (distribution = round_robin, clustered index(' + @SKField + ')) as' + @NewLine
		+ 'select t.ADLSBatchID, t.ADLSTimestamp, t.LZBatchID, t.DWHash, t.' + @SKField + ', t.' + @KeyField + ',' + @NewLine
		+ 'h.StartDateSCD,' + @NewLine
		+ 'case when h.StartDateSCD is null then 1 --new entity' + @NewLine
		+ '	when h.StartDateSCD = @CurrentDate then 2 --we need to update only data' + @NewLine
		+ '	else 3 --update end date for previous row and insert new row' + @NewLine
		+ 'end as ChangeType,' + @NewLine
		+ @ColumnListWithAlias + @NewLine
		+ 'from ' + @FullTableName + ' t' + @NewLine
		+ 'left join ' + @FullTableNameSCD + ' h on h.' + @SKField + ' = t.' + @SKField + ' and h.EndDateSCD = @StaticEndDate' + @NewLine
		+ 'where h.DWHash != t.DWHash or h.StartDateSCD is null' + @NewLine

	set @SQL += @NewLine
		+ 'if exists (select * from ' + @TempTableName + ' where StartDateSCD > @CurrentDate)' + @NewLine
		+ 'begin' + @NewLine
		+ '	throw 53001, ''Future records exist in the history table ' + @FullTableNameSCD + ''', 1;' + @NewLine
		+ 'end' + @NewLine

	exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
	exec (@SQL)

	set @SQL = 'set nocount on set xact_abort on' + @NewLine
		+ 'declare @BatchID int = ' + convert(varchar, @BatchId) + @NewLine
		+ ', @CurrentDate date = ''' + convert(varchar(10), @CurrentDate, 120) + '''' + @NewLine
		+ ', @StaticStartDate date = ''' + @StaticStartDate + '''' + @NewLine
		+ ', @StaticEndDate date = ''' + @StaticEndDate + '''' + @NewLine
		+ @NewLine + 'begin tran' + @NewLine
		+ '--if we already have a record where start date = current date then we just update attributes' + @NewLine
		+ 'update ' + @FullTableNameSCD + @NewLine
		+ '	set	ADLSBatchID = h.ADLSBatchID, ADLSTimestamp = h.ADLSTimestamp, LZBatchID = h.LZBatchID, DWBatchID = @BatchID, DWHash = h.DWHash,' + @NewLine
		+ @ColumnListForUpdate + @NewLine
		+ 'from ' + @TempTableName + ' h' + @NewLine
		+ 'where h.' + @SKField + ' = ' + @FullTableNameSCD + '.' + @SKField + @NewLine
		+ '	and h.StartDateSCD = ' + @FullTableNameSCD + '.StartDateSCD' + @NewLine
		+ '	and h.ChangeType = 2' + @NewLine

	set @SQL += @NewLine + '--update end date and insert new row(s)' + @NewLine
		+ 'update ' + @FullTableNameSCD + @NewLine
		+ '	set	EndDateSCD = @CurrentDate, DWBatchID = @BatchID' + @NewLine
		+ 'from ' + @TempTableName + ' h' + @NewLine
		+ 'where h.' + @SKField + ' = ' + @FullTableNameSCD + '.' + @SKField + @NewLine
		+ '	and h.StartDateSCD = ' + @FullTableNameSCD + '.StartDateSCD' + @NewLine
		+ '	and h.ChangeType = 3' + @NewLine + @NewLine
		+ 'insert into ' + @FullTableNameSCD + ' (' + @NewLine
		+ 'ADLSBatchID, ADLSTimestamp, LZBatchID, DWBatchID, DWHash, StartDateSCD, EndDateSCD, ' + @SKField + ', ' + @KeyField + ',' + @NewLine
		+ @ColumnList + @NewLine
		+ ')' + @NewLine
		+ 'select ADLSBatchID, ADLSTimestamp, LZBatchID, @BatchID, DWHash, case when ChangeType = 1 then @StaticStartDate else @CurrentDate end, @StaticEndDate, ' + @SKField + ', ' + @KeyField + ',' + @NewLine
		+ @ColumnList + @NewLine
		+ 'from ' + @TempTableName + @NewLine
		+ 'where ChangeType in (1, 3)' + @NewLine
		+ 'commit tran' + @NewLine

	exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
	exec (@SQL)

	set @SQLUnicode = N'select @RowsInserted = count(case when ChangeType in (1, 3) then 1 end)' + @NewLine
		+ ', @RowsUpdated = count(case when ChangeType in (2, 3) then 1 end)' + @NewLine
		+ 'from ' + @TempTableName
	exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQLUnicode
	exec sp_executesql @SQLUnicode, N'@RowsInserted int output, @RowsUpdated int output', @RowsInserted = @RowsInserted output, @RowsUpdated = @RowsUpdated output

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
