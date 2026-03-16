CREATE PROC [CTRL].[LZPrepareExternalView] @JSONColumnList [varchar](max),@FullFileName [varchar](256),@ObjectName [varchar](128),@SessionID [uniqueidentifier] AS
begin

	declare @SQL varchar(max)

	if @SessionID is null
		set @SessionID = newid()

	set @JSONColumnList = substring(@JSONColumnList, 2, len(@JSONColumnList) - 2)
	set @JSONColumnList = replace(@JSONColumnList, '{', '')
	set @JSONColumnList = replace(@JSONColumnList, '"name":', '')
	set @JSONColumnList = replace(@JSONColumnList, ',"type":', ' ')
	set @JSONColumnList = replace(@JSONColumnList, '"String"}', 'nvarchar(max) null')
	set @JSONColumnList = replace(@JSONColumnList, '"Int16"}', 'smallint null')
	set @JSONColumnList = replace(@JSONColumnList, '"Int32"}', 'int null')
	set @JSONColumnList = replace(@JSONColumnList, '"Int64"}', 'bigint null')
	set @JSONColumnList = replace(@JSONColumnList, '"Boolean"}', 'bit null')
	set @JSONColumnList = replace(@JSONColumnList, '"Datetime"}', 'datetime2(7) null')
	set @JSONColumnList = replace(@JSONColumnList, '"Decimal"}', 'numeric(38, 12) null')
	set @JSONColumnList = replace(@JSONColumnList, '"Double"}', 'float(53) null')
	set @JSONColumnList = replace(@JSONColumnList, '"Byte[]"}', 'varbinary null')

	set @SQL = 'if exists (select * from sys.external_tables where [object_id] = object_id (''' + @ObjectName +
	''')) drop external table ' + @ObjectName + char(13) + char(10) +
	' create external table ' + @ObjectName + '(' + @JSONColumnList + ')' + char(13) + char(10) +
	' with ( location = ''' + @FullFileName + ''', data_source = ADLSv2, file_format = FlatFileFormatParquet)'

	exec CTRL.InsertDynamicQueryLog @SessionID = @SessionID, @SQLQuery = @SQL
	exec(@SQL)

end
