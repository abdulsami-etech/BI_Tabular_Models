create function CTRL.GetSourceSystemProperty(
		@SourceSystem varchar(32)
	,	@PropertyName varchar(32)
) returns varchar(1000)
begin
	return (
		select PropertyValue
		from CTRL.SourceSystemProperty
		where SourceSystem = @SourceSystem
			and PropertyName = @PropertyName
	)
end