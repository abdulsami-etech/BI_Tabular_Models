CREATE PROC [CTRL].[LZPopulateMainTable] @SourceSchema [varchar](32),@SourceTable [varchar](128),@DestSchema [varchar](32),@DestTable [varchar](128),@JoinPredicates [varchar](512),@JoinPredicatesForUpdate [varchar](1024),@IsFullLoad [bit],@SourceColumnDroppedAction [varchar](32),@SessionID [varchar](36),@StoreOption [varchar](128),@DistributionOption [varchar](128) AS
begin
	/*
		@SourceColumnDroppedAction: possible values are:
			1) ThrowError: throwing error if column was removed on the source side
			2) DropInDestination: column will be dropped in destination table (!!! use with caution since LZ column might be used in DW)
			3) Ignore: column will be ignored in insert/update statements
	*/

	set nocount on
	set xact_abort on

	declare @SQL						varchar(max)
		,	@SQLUnicode					nvarchar(max)
		,	@SQLColumns					varchar(max)
		,	@SQLInsert					varchar(max)
		,	@SQLUpdate					varchar(max)
		,	@SQLToAdd					varchar(max)
		,	@SourceSchemaQuoted			varchar(34)
		,	@SourceTableQuoted			varchar(130)
		,	@DestSchemaQuoted			varchar(34)
		,	@DestTableQuoted			varchar(130)
		,	@SrcFullTableName			varchar(160)
		,	@DstFullTableName			varchar(160)
		,	@DstFullTableNameCTAS		varchar(200)
		,	@DstTableNameCTAS			varchar(160)
		,	@DstFullTableNamePrevious	varchar(200)
		,	@DstTableNamePrevious		varchar(160)
		,	@ErrorMsg					varchar(max)
		,	@RowsInserted				bigint = 0
		,	@RowsUpdated				bigint = 0
		,	@Label						varchar(200)
		,	@ColumnName					varchar(128)
		,	@SQLDroppedColumns			varchar(max)
		,	@SQLDroppedColumns2			varchar(max)
		,	@Datatype					varchar(128)
		,	@ColumnToAdd				varchar(160)
		,   @DistributedColumn          varchar(128)

	if @SessionID is null
		set @SessionID = convert(varchar(36), newid())

	if left(@DistributionOption, 4) = 'hash'
		set @DistributedColumn = ltrim(rtrim(replace(replace(replace(@DistributionOption, 'hash', ''), '(', ''), ')', '')))

	set @SourceSchemaQuoted = quotename(@SourceSchema)
	set @SourceTableQuoted = quotename(@SourceTable)
	set @DestSchemaQuoted = quotename(@DestSchema)
	set @DestTableQuoted = quotename(@DestTable)

	set @SrcFullTableName = @SourceSchemaQuoted + '.' + @SourceTableQuoted
	set @DstFullTableName = @DestSchemaQuoted + '.' + @DestTableQuoted

	set @DstTableNameCTAS = quotename(@DestTable + '_' + convert(varchar(40), @SessionID))
	set @DstFullTableNameCTAS = @DestSchemaQuoted + '.' + @DstTableNameCTAS

	set @DstTableNamePrevious = quotename(@DestTable + '_' + 'Previous')
	set @DstFullTableNamePrevious = @DestSchemaQuoted + '.' + @DstTableNamePrevious

	set @SQLDroppedColumns = ''
	set @SQLDroppedColumns2 = ''

	if object_id (@SrcFullTableName, 'U') is null
	begin
		set @ErrorMsg = 'Source table ' + @SrcFullTableName + ' does not exist';
		throw 53001, @ErrorMsg, 1; 
	end 

	if object_id (@DstFullTableName, 'U') is null --dest table does not exist
	begin
		if not exists (select * from sys.schemas where name = @DestSchema) -- create schema if doesn't exist
		begin
			set @SQL = 'create schema ' + @DestSchema + ' authorization dbo'
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
			exec (@SQL)
		end

		set @SQL = 'create table ' + @DstFullTableName + ' with (' + @StoreOption + ', distribution = ' + @DistributionOption + ') as select * from ' + @SrcFullTableName
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec (@SQL)

		set @SQLUnicode = N'select @RowsInserted = count(*) from ' + @DstFullTableName
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQLUnicode
		exec sp_executesql @SQLUnicode, N'@RowsInserted int output', @RowsInserted = @RowsInserted output
	end
	else
	begin --dest table exists
		--let's check what to do in case if column(s) was dropped in source
		if @SourceColumnDroppedAction = 'ThrowError' 
			or (@SourceColumnDroppedAction = 'DropInDestination' and @IsFullLoad = 0)
			or (@SourceColumnDroppedAction = 'Ignore' and @IsFullLoad = 1)
		begin
			while 1 = 1
			begin
				set @ColumnName = null
				select top (1)
						@ColumnName = dst.column_name
					,	@Datatype = concat(
											dst.data_type
										,	case 
												when dst.data_type = 'datetime2' then '(' + convert(varchar, dst.datetime_precision) + ')'
												when dst.data_type in ('int', 'bigint', 'smallint', 'tinyint') then ''
												else concat(
															'(' + case when dst.character_maximum_length = -1 then 'max' else convert(varchar, dst.character_maximum_length) end + ')'
														,	'(' + convert(varchar, dst.numeric_precision) + isnull(',' + convert(varchar, dst.numeric_scale), '') + ')'
													)
											end
									)
				from information_schema.columns dst
				where dst.table_schema = @DestSchema
					and dst.table_name = @DestTable
					and not exists (
						select *
						from information_schema.columns src
						where src.table_schema = @SourceSchema
							and src.table_name = @SourceTable
							and src.column_name = dst.column_name
					)
					and @SQLDroppedColumns2 not like '%|' + dst.column_name + '|%'

				if @ColumnName is null --we are done
					break
				else
				begin
					if @SourceColumnDroppedAction = 'ThrowError'
					begin
						set @ErrorMsg = 'The column "' + @ColumnName + '" was dropped on the source side.';
						throw 53002, @ErrorMsg, 1;
					end
					else if @SourceColumnDroppedAction = 'DropInDestination'
					begin --we need to drop column in destination
						set @SQL = 'alter table ' + @DstFullTableName + ' drop column ' + quotename(@ColumnName)
						exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
						exec (@SQL)
					end
					else --Ignore, need to save a list of removed columns
					begin
						if isnull(@JoinPredicates, '') != '' --have a PK
							set @SQLDroppedColumns += ',t2.' + quotename(@ColumnName)
						else
							set @SQLDroppedColumns += ',convert(' + @Datatype + ', null) as ' + quotename(@ColumnName)

						set @SQLDroppedColumns2 += '|' + @ColumnName + '|'
					end
				end
			end
		end

		if @IsFullLoad = 0
		begin
			--adding new columns if such and doing insert and update
            select  @SQLColumns = SQLColumns
                ,   @SQLInsert = SQLInsert
                ,   @SQLUpdate = SQLUpdate
                ,   @SQLToAdd = SQLToAdd
            from (
                select	string_agg(convert(varchar(max), quotename(i.column_name)), ', ') within group (order by i.ordinal_position) as SQLColumns
                    ,	string_agg(convert(varchar(max), 't1.' + quotename(i.column_name)), ', ') within group (order by i.ordinal_position) as SQLInsert
                    ,	string_agg(convert(varchar(max), case when i.column_name = @DistributedColumn then null else quotename(i.column_name) + ' = t1.' + quotename(i.column_name) end), ', ') within group (order by i.ordinal_position) as SQLUpdate
                    ,	string_agg(
                                convert(varchar(max), 
                                    case when dst.column_name is null --new column, need to add
                                        then	concat(
                                                        quotename(i.column_name)
                                                    ,	' '
                                                    ,	i.data_type
                                                    ,	case 
                                                            when i.data_type = 'datetime2' then '(' + convert(nvarchar, i.datetime_precision) + ')'
                                                            when i.data_type in ('int', 'bigint', 'smallint', 'tinyint') then ''
                                                            else concat(
                                                                        '(' + case when i.character_maximum_length = -1 then 'max' else convert(nvarchar, i.character_maximum_length) end + ')'
                                                                    ,	'(' + convert(nvarchar, i.numeric_precision) + isnull(',' + convert(nvarchar, i.numeric_scale), '') + ')'
                                                                )
                                                        end
                                                    ,	' null'
                                                )
                                        else null
                                    end
                                )
                            ,   ', '
                        ) within group (order by i.ordinal_position) as SQLToAdd
                from information_schema.columns i
                left join information_schema.columns dst on dst.table_schema = @DestSchema
                                                        and dst.table_name = @DestTable
                                                        and dst.column_name = i.column_name
                where i.table_schema = @SourceSchema
                    and i.table_name = @SourceTable
            ) t

			--adding new columns if such
			if @SQLToAdd is not null
			begin
				set @SQL = 'alter table ' + @DstFullTableName + ' add ' + @SQLToAdd
				exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
				exec (@SQL)
			end

			--updating existing rows
			--!!! we don't delete and insert since the table might be used by another read transaction at this moment, so we are trying to minimize data inconsistency risk
			--one more solution is to use CTAS for destination table, this needs to be tested
			--datatypes might be different, hence error may occur during update, in such case it should be handled manually
			set @Label = @DstFullTableName + '_' + left(convert(varchar(40), @SessionID), 8) + '_update'
			set @SQL = 'update ' + @DstFullTableName + ' set ' + @SQLUpdate + ' 
				from ' + @SrcFullTableName + ' t1 where ' + @JoinPredicatesForUpdate + ' and ' + @DstFullTableName + '.ADLSTimestamp <= t1.ADLSTimestamp
				option (label = ''' + @Label + ''')'
			
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
			exec (@SQL)
			exec CTRL.GetLastRowCount @Label = @Label, @rc = @RowsUpdated out

			--insert new rows
			set @Label = @DstFullTableName + '_' + left(convert(varchar(40), @SessionID), 8) + '_insert'
			set @SQL = 'insert into ' + @DstFullTableName + '(' + @SQLColumns + ') select ' + @SQLInsert + ' 
				from ' + @SrcFullTableName + ' t1 
				where not exists (select * from ' +  @DstFullTableName + ' t2 where ' + @JoinPredicates + ')
				option (label = ''' + @Label + ''')'
	
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
			exec (@SQL)
			exec CTRL.GetLastRowCount @Label = @Label, @rc = @RowsInserted out
		end
		else
		begin --full reload, --let's create a new table and then rename
			if object_id (@DstFullTableNameCTAS) is not null
			begin
				set @SQL = 'drop table ' + @DstFullTableNameCTAS
				exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
				exec (@SQL)
			end

			set @SQL = 'create table ' + @DstFullTableNameCTAS + ' with (' + @StoreOption + ', distribution = ' + @DistributionOption + ') as ' + char(13) + char(10)
			if @SourceColumnDroppedAction = 'Ignore' and @SQLDroppedColumns != '' --need to keep dropped columns
			begin
				set @SQL += 'select t1.*' + @SQLDroppedColumns + ' from ' + @SrcFullTableName + ' t1'
				if isnull(@JoinPredicates, '') != '' --have a PK
					set @SQL += ' left join ' + @DstFullTableName + ' t2 on ' + @JoinPredicates
			end
			else
				set @SQL += 'select * from ' + @SrcFullTableName
				
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
			exec (@SQL)

			if object_id (@DstFullTableNamePrevious) is not null
			begin
				set @SQL = 'drop table ' + @DstFullTableNamePrevious
				exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
				exec (@SQL)
			end

			set @SQL = 'rename object ' + @DstFullTableName + ' to ' + @DstTableNamePrevious + char(13) + char(10)
					+ 'rename object ' + @DstFullTableNameCTAS + ' to ' + @DestTableQuoted
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
			exec (@SQL)

			set @SQL = 'drop table ' + @DstFullTableNamePrevious
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
			exec (@SQL)

			set @SQLUnicode = N'select @RowsInserted = count(*) from ' + @DstFullTableName
			exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQLUnicode
			exec sp_executesql @SQLUnicode, N'@RowsInserted int output', @RowsInserted = @RowsInserted output
		end
	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end



