CREATE PROC [CTRL].[LZGetObjectSchema] @Schema [varchar](32),@Table [varchar](128),@Columns [varchar](max) OUT,@Datatypes [varchar](max) OUT,@IsNullables [varchar](max) OUT AS
begin
	set nocount on

	declare	@i				int
		,	@total			int
		,	@Column			varchar(128)
		,	@DataType		varchar(128)
		,	@IsNullable		varchar(1)

	select @total = count(*)
	from information_schema.columns
	where table_schema = @Schema
		and table_name = @Table

	set @i = 1
	set @Columns = ''
	set @Datatypes = ''
	set @IsNullables = ''

	while (@i <= @total)
	begin
		select	@Column = column_name
			,	@DataType = concat(
									data_type
								,	case 
										when data_type = 'datetime2' then '(' + convert(varchar, datetime_precision) + ')'
										when data_type in ('int', 'bigint', 'smallint', 'tinyint') then ''
										else concat(
													'(' + case when character_maximum_length = -1 then 'max' else convert(varchar, character_maximum_length) end + ')'
												,	'(' + convert(varchar, numeric_precision) + isnull(',' + convert(varchar, numeric_scale), '') + ')'
											)
									end
							)
			,	@IsNullable = case when is_nullable = 'YES' then '1' else '0' end
		from information_schema.columns
		where table_schema = @Schema
			and table_name = @Table
			and ordinal_position = @i

		if @i > 1
		begin
			set @Columns += '|'
			set @Datatypes += '|'
			set @IsNullables += '|'
		end

		set @Columns += @Column
		set @Datatypes += @DataType
		set @IsNullables += @IsNullable

		set @i += 1
	end
end
