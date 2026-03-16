CREATE PROC [CTRL].[LZRefreshSFDCHistoryTable] @LZBatchID [int],@SFDCHistoryTableName [varchar](128),@ColumnList [varchar](1000),@SessionID [varchar](36) AS
begin

	set nocount on
	set xact_abort on

	declare	@SFDCFullTableNameHistory					varchar(130) 
		,	@SFDCTableNameHistoryFlattened				varchar(130) 
		,	@SFDCFullTableNameHistoryFlattened			varchar(140) 
		,	@SFDCTableNameHistoryFlattenedPrevious		varchar(150)
		,	@SFDCFullTableNameHistoryFlattenedPrevious	varchar(150) 
		,	@TempTableName								varchar(180)
		,	@ErrorMsg									varchar(max)
		,	@SchemaName									varchar(64)
		,	@ParentIdFieldName							varchar(128)
		,	@SQL										varchar(max)
		,	@SQL2										varchar(max)
		,	@SQLUnicode									nvarchar(max)
		,	@RowsInserted								int = 0
		,	@RowsUpdated								int = 0

	if @SessionID is null
		set @SessionID = convert(varchar(36), newid())

	set @SchemaName = 'SrcSFDC'
	set @SFDCFullTableNameHistory = quotename(@SchemaName) + '.' + quotename(@SFDCHistoryTableName)
	
	if object_id (@SFDCFullTableNameHistory, 'U') is null
	begin
		set @ErrorMsg = 'Source table ' + @SFDCFullTableNameHistory + ' does not exist';
		throw 53001, @ErrorMsg, 1; 
	end

	set @ColumnList = (select string_agg(ltrim(rtrim(value)), ',') from string_split(@ColumnList, ','))
	set @SFDCTableNameHistoryFlattened = @SFDCHistoryTableName + 'Flattened'
	set @SFDCFullTableNameHistoryFlattened = quotename(@SchemaName) + '.' + quotename(@SFDCTableNameHistoryFlattened)
	set @SFDCTableNameHistoryFlattenedPrevious = @SFDCTableNameHistoryFlattened + 'Previous'
	set @SFDCFullTableNameHistoryFlattenedPrevious = quotename(@SchemaName) + '.' + quotename(@SFDCTableNameHistoryFlattenedPrevious)
	set @TempTableName = quotename(@SchemaName) + '.' + quotename(@SFDCTableNameHistoryFlattened + '_' + convert(varchar(36), newid()))

	set @ParentIdFieldName = null
	if right(@SFDCHistoryTableName, 9) = '__History' --ParentId field
		select @ParentIdFieldName = column_name
		from information_schema.columns
		where table_schema = @SchemaName
			and table_name = @SFDCHistoryTableName
			and column_name = 'ParentId'
	else --TableName + Id
		select @ParentIdFieldName = column_name
		from information_schema.columns
		where table_schema = @SchemaName
			and table_name = @SFDCHistoryTableName
			and column_name = left(@SFDCHistoryTableName, len(@SFDCHistoryTableName) - len('History')) + 'Id'

	if @ParentIdFieldName is null
	begin
		set @ErrorMsg = 'ParentId field is not found in the history table ' + @SFDCFullTableNameHistory;
		throw 53001, @ErrorMsg, 1; 
	end

	set @SQL = 
'create table ' + @TempTableName + ' with (distribution = hash(ParentId), clustered index(ParentId)) as
with history as (
	select	' + @ParentIdFieldName + ' as ParentId
		,	Field
		,	CreatedDate
		,	NewValue
		,	OldValue
		,	ADLSBatchID
		,	ADLSTimestamp
	from ' + @SFDCFullTableNameHistory + '
	where Field in (' + (select string_agg('''' + value + '''', ',') from string_split(@ColumnList, ',')) + ')
), historyWithInitialValue as (
	select top (1) with ties
			ParentId
		,	Field
		,	''1900-01-01'' as CreatedDate
		,	OldValue as NewValue
		,	ADLSBatchID
		,	ADLSTimestamp
	from history
	order by row_number() over (partition by ParentId, Field order by CreatedDate)	

	union all

	select	ParentId
		,	Field
		,	CreatedDate
		,	NewValue
		,	ADLSBatchID
		,	ADLSTimestamp
	from history
), historyByDates as (
	select top (1) with ties
			ParentId
		,	Field
		,	convert(date, CreatedDate) as CreatedDate
		,	NewValue
		,	ADLSBatchID
		,	ADLSTimestamp
	from historyWithInitialValue
	order by row_number() over (partition by ParentId, Field, convert(date, CreatedDate) order by CreatedDate desc) 
), withPreviousValue as (
	select	ParentId
		,	Field
		,	CreatedDate
		,	NewValue
		,	isnull(lag(NewValue, 1, ''DEFAULT_VALUE'') over (partition by ParentId, Field order by CreatedDate), ''NULL_VALUE'') as PreviousValue
		,	ADLSBatchID
		,	ADLSTimestamp
	from historyByDates
), withoutRedundancy as (
	select	ParentId
		,	Field
		,	CreatedDate
		,	NewValue
		,	ADLSBatchID
		,	ADLSTimestamp
	from withPreviousValue
	where isnull(NewValue, ''NULL_VALUE'') != PreviousValue --we are not intrested when the previous value is the same
		or PreviousValue = ''DEFAULT_VALUE'' --initial
), withEndDate as (
	select	ParentId
		,	Field
		,	CreatedDate as StartDate
		,	lead(CreatedDate, 1, ''2099-01-01'') over (partition by ParentId, Field order by CreatedDate) as EndDate
		,	NewValue as Value
		,	ADLSBatchID
		,	ADLSTimestamp
	from withoutRedundancy
),
'

	;with cols as (
		select	value
			,	quotename(value) as ValueQuoted
			,	row_number() over (order by (select null)) as rn
		from string_split(@ColumnList, ',')
	)
	, cols2 as (
		select	c1.value as ColumnName
			,	c1.ValueQuoted as ColumnNameQuoted
			,	c1.rn
			,	(
					select	string_agg(
									convert(varchar(max),
										'case when a.ParentId is not null then a.' + c2.ValueQuoted + ' else ''NO_HISTORY'' end as ' + c2.ValueQuoted
									)
								,	char(13) + char(10) + '		,	' 
							)
					from cols c2 
					where c2.rn < c1.rn
				) as ColumnList
		from cols c1
	) 
	select @SQL2 = string_agg(
				convert(varchar(max),
					'cte' + convert(varchar, rn) + ' as (' + char(13) + char(10)
					+ case when rn = 1 
							then '	select ADLSBatchID, ADLSTimestamp, ParentId, StartDate, EndDate, Value as ' + ColumnNameQuoted + ' from withEndDate where Field = ''' + ColumnName + ''''
							else '	select	isnull(a.ADLSBatchID, b.ADLSBatchID) as ADLSBatchID, isnull(a.ADLSTimestamp, b.ADLSTimestamp) as ADLSTimestamp, isnull(a.ParentId, b.ParentId) as ParentId' + char(13) + char(10)
							+ '		,	case when a.StartDate > b.StartDate then isnull(a.StartDate, b.StartDate) else isnull(b.StartDate, a.StartDate) end as StartDate' + char(13) + char(10)
							+ '		,	case when a.EndDate < b.EndDate then isnull(a.EndDate, b.EndDate) else isnull(b.EndDate, a.EndDate) end as EndDate ' + char(13) + char(10)
							+ '		,	' + ColumnList + char(13) + char(10)
							+ '		,	case when b.ParentId is not null then b.Value else ''NO_HISTORY'' end as ' + ColumnNameQuoted + char(13) + char(10)
							+ '	from cte' + convert(varchar, rn - 1) + ' a' + char(13) + char(10)
							+ '	full join (select * from withEndDate where Field = ''' + ColumnName + ''') b on b.ParentId = a.ParentId' + char(13) + char(10)
							+ '			and (' + char(13) + char(10)
							+ '					(' + char(13) + char(10)
							+ '						b.StartDate >= a.StartDate' + char(13) + char(10)
							+ '						and b.StartDate < a.EndDate' + char(13) + char(10)
							+ '					) or (' + char(13) + char(10)
							+ '						b.EndDate > a.StartDate' + char(13) + char(10)
							+ '						and b.EndDate <= a.EndDate' + char(13) + char(10)
							+ '					) or (' + char(13) + char(10)
							+ '						b.StartDate < a.StartDate' + char(13) + char(10)
							+ '						and b.EndDate >= a.EndDate' + char(13) + char(10)
							+ '					)' + char(13) + char(10)
							+ '			)'
						end + char(13) + char(10) + ')'
				)
				,	',' + char(13) + char(10)
			) + char(13) + char(10)
			+ 'select ' 
			+ convert(varchar, @LZBatchID) + ' as LZBatchID, '
			+ '* from cte' + (select convert(varchar, max(rn)) from cols2)
	from cols2

	set @SQL += @SQL2

	exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
	exec (@SQL)

	if object_id (@SFDCFullTableNameHistoryFlattened, 'U') is not null
	begin
		if object_id (@SFDCFullTableNameHistoryFlattenedPrevious, 'U') is not null
		begin
			set @SQL = 'drop table ' + @SFDCFullTableNameHistoryFlattenedPrevious
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
			exec (@SQL)
		end

		set @SQL = 'rename object ' + @SFDCFullTableNameHistoryFlattened + ' to ' + @SFDCTableNameHistoryFlattenedPrevious + char(13) + char(10)
				+ 'rename object ' + @TempTableName + ' to ' + @SFDCTableNameHistoryFlattened
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec (@SQL)

		set @SQL = 'drop table ' + @SFDCFullTableNameHistoryFlattenedPrevious
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec (@SQL)
	end
	else
	begin
		set @SQL = 'rename object ' + @TempTableName + ' to ' + @SFDCTableNameHistoryFlattened
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec (@SQL)
	end

	set @SQLUnicode = N'select @RowsInserted = count(*) from ' + @SFDCFullTableNameHistoryFlattened
	exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQLUnicode
	exec sp_executesql @SQLUnicode, N'@RowsInserted int output', @RowsInserted = @RowsInserted output

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
		
end
