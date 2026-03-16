CREATE PROC [CTRL].[LZPopulateStageTable] @Schema [varchar](32),@Table [varchar](128),@Columns [varchar](max),@Datatypes [varchar](max),@IsNullables [varchar](max),@SessionID [uniqueidentifier],@ExtrenalViewName [varchar](128),@LZBatchID [int],@ADLSBatchID [int],@ADLSTimestampStr [varchar](14),@PKColumns [varchar](200),@PredicateColumn [varchar](128),@SourceSystem [varchar](32) AS
begin
	set nocount on
	set xact_abort on

	declare @SQL				varchar(max)
		,	@SQL2				varchar(max)
		,	@SchemaQuoted		varchar(34)
		,	@TableQuoted		varchar(130)
		,	@FullTableName		varchar(165)
		,	@ADLSTimestamp		datetime2(0)
		,	@PKColumnsQuoted	varchar(220)
		,	@StoreOption		varchar(128) = 'heap'
		,	@DistributionOption varchar(128) = 'round_robin'
		,	@Delimiter			char(1) = '|'

	if @SessionID is null
		set @SessionID = newid()

	select @PKColumnsQuoted = string_agg(col, ',')
	from (
		select quotename(value) as col 
		from string_split(@PKColumns, ',')
	) t

	set @SchemaQuoted = quotename(@Schema)
	set @TableQuoted = quotename(@Table)
	set @FullTableName = @SchemaQuoted + '.' + @TableQuoted
	set @ADLSTimestamp = convert(datetime2(0), left(@ADLSTimestampStr, 8) + ' ' + substring(@ADLSTimestampStr, 9, 2) + ':' + substring(@ADLSTimestampStr, 11, 2) + ':' + right(@ADLSTimestampStr, 2))

	if object_id (@FullTableName, 'U') is not null
	begin
		set @SQL = 'drop table ' + @FullTableName
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec(@SQL)
	end

	if isnull(@Columns, '') != '' --we have the schema, let's create and populate Stage table with the given schema
	begin

		;with cteColumnsVal as (
			select 0 as val 
			union all 
			select val + 1 
			from CTRL.Numbers
    		where val <= datalength(@Columns)
				and substring(@Columns, val, 1) = @Delimiter
		), cteColumns as (
			select	row_number() over (order by s.val) as rn
				,	substring(@Columns, s.val, isnull(nullif(charindex(@Delimiter, @Columns, s.val), 0) - s.val, 8000)) as [Column]
			from cteColumnsVal s
		), cteDatatypesVal as (
			select 0 as val 
			union all 
			select val + 1 
			from CTRL.Numbers
    		where val <= datalength(@Datatypes)
				and substring(@Datatypes, val, 1) = @Delimiter
		), cteDatatypes as (
			select	row_number() over (order by s.val) as rn
				,	substring(@Datatypes, s.val, isnull(nullif(charindex(@Delimiter, @Datatypes, s.val), 0) - s.val, 8000)) as Datatype
			from cteDatatypesVal s
		), cteIsNullablesVal as (
			select 0 as val 
			union all 
			select val + 1 
			from CTRL.Numbers
    		where val <= datalength(@IsNullables)
				and substring(@IsNullables, val, 1) = @Delimiter
		), cteIsNullables as (
			select	row_number() over (order by s.val) as rn
				,	substring(@IsNullables, s.val, isnull(nullif(charindex(@Delimiter, @IsNullables, s.val), 0) - s.val, 8000)) as isNullable
			from cteIsNullablesVal s
		)
		select	@SQL = string_agg(convert(varchar(max), quotename(c.[Column]) + ' ' + d.Datatype + case when n.IsNullable = 1 then ' null' else ' not null' end), ', ') within group (order by c.rn)
			,	@SQL2 = string_agg(convert(varchar(max), quotename(c.[Column])), ', ') within group (order by c.rn)
		from cteColumns c
		inner join cteDatatypes d on d.rn = c.rn
		inner join cteIsNullables n on n.rn = c.rn

		set @SQL = 'create table ' + @FullTableName + ' (LZBatchID int not null, ADLSBatchID int not null, ADLSTimestamp datetime2(0) not null, ' + @SQL + ')' + ' with (' + @StoreOption + ', distribution = ' + @DistributionOption + ')'
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec(@SQL)

		if (@SourceSystem like 'MES%' or @SourceSystem = 'PowerBI') and len(@PKColumnsQuoted) > 0 --let's remove possible duplicates, since nolock hint is used for MES query
			set @SQL = 'insert into ' + @FullTableName + '(LZBatchID, ADLSBatchID, ADLSTimestamp, ' + @SQL2 + ')' + char(13) + char(10)
				+ 'select LZBatchID, ADLSBatchID, ADLSTimestamp, ' + @SQL2 + ' from (' + char(13) + char(10)
				+ 'select '
				+ convert(varchar, @LZBatchID) + ' as LZBatchID' + char(13) + char(10)
				+ ',' + convert(varchar, @ADLSBatchID) + ' as ADLSBatchID' + char(13) + char(10)
				+ ',convert(datetime2(0), ''' + convert(varchar, @ADLSTimestamp, 120) + ''') as ADLSTimestamp,' + char(13) + char(10)
				+ @SQL2 + char(13) + char(10)
				+ ',row_number() over (partition by ' + @PKColumnsQuoted + ' order by ' + case when len(@PredicateColumn) > 0 then @PredicateColumn + ' desc' else '(select 0)' end + ') as _rn_' + char(13) + char(10)
				+ 'from ' + @ExtrenalViewName
				+ ') t where _rn_ = 1'
		else
			set @SQL = 'insert into ' + @FullTableName + '(LZBatchID, ADLSBatchID, ADLSTimestamp, ' + @SQL2 + ')' + char(13) + char(10)
				+ 'select '
				+ convert(varchar, @LZBatchID) + ' as LZBatchID' + char(13) + char(10)
				+ ',' + convert(varchar, @ADLSBatchID) + ' as ADLSBatchID' + char(13) + char(10)
				+ ',convert(datetime2(0), ''' + convert(varchar, @ADLSTimestamp, 120) + ''') as ADLSTimestamp,' + char(13) + char(10)
				+ @SQL2 + char(13) + char(10)
				+ 'from ' + @ExtrenalViewName;
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec(@SQL)
					
	end
	else
	begin --no schema, using select * for CTAS
		set @SQL = 'create table ' + @FullTableName + ' with (' + @StoreOption + ', distribution = ' + @DistributionOption + ') 
			as select '
			+ convert(varchar, @LZBatchID) + ' as LZBatchID' + char(13) + char(10)
			+ ',' + convert(varchar, @ADLSBatchID) + ' as ADLSBatchID' + char(13) + char(10)
			+ ',convert(datetime2(0), ''' + convert(varchar, @ADLSTimestamp, 120) + ''') as ADLSTimestamp' + char(13) + char(10)
			+ ',* from ' + @ExtrenalViewName;
		exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
		exec(@SQL)
	end

end



