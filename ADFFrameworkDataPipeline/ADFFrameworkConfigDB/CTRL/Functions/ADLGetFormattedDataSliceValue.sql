
create function CTRL.ADLGetFormattedDataSliceValue
(
		@DataSliceValue varchar(64)
	,	@DataSliceValueDataType varchar(32)
    ,	@DateTimeFormat varchar (32) = null
    ,	@DateTimeFormat1 varchar (16) = null
    ,	@DateTimeFormat2 varchar (16) = null
	,	@SecondsToAdd int = null
)
returns varchar(64)
as
begin
	return (
		case @DataSliceValueDataType
			when 'Datetime' 
				then concat(@DateTimeFormat1, format(dateadd(second, isnull(@SecondsToAdd, 0), convert(datetime2(7), @DataSliceValue)), @DateTimeFormat), @DateTimeFormat2)
			when 'Numeric'
				then @DataSliceValue
			when 'String'
				then '''' + @DataSliceValue + ''''
			else @DataSliceValue
		end
	)
end
