CREATE PROC [CTRL].[ADLCreateTempTable] @ObjectName [varchar](128),@jsonTableStructure [varchar](max),@ColumnList [varchar](max) AS
begin

	declare	@tempTableName varchar(200)
		,	@SQL varchar(max)
		,	@Columns varchar(max)

	set @tempTableName = 'TEMP.' + @ObjectName + '_' + format(getdate(), 'yyyyMMddHHssmm') + '_' + left(convert(varchar(36), newid()), 8)

	if @ColumnList is null
		select @Columns = string_agg(quotename(json_value(value, '$.name')) + ' ' + isnull(m.SQLDataType, 'nvarchar(4000)') + ' null', ',')
		from openjson(@jsonTableStructure) j
		left join CTRL.DataTypeMapping m on m.ADFDataType = json_value(value, '$.type')
	else --this one is used to create temp table for REST API Token
		select @Columns = string_agg(ltrim(rtrim(value)) + ' varchar(1000)', ',') 
		from string_split(@ColumnList, ',')

	set @SQL = 'create table ' + @tempTableName + '(' + @Columns + ') WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);'
	exec (@SQL)

	select @tempTableName as TempTableName
end
