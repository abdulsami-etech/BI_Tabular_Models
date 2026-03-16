create procedure CTRL.APIUpdateToken @SourceSystem varchar(32), @Query varchar(1000)
as
begin
	set nocount on
	set xact_abort on

	declare	@Token					varchar(1000)
		,	@TokenExpirationDate	datetime
		,	@SQL					nvarchar(max)

	set @SQL = N'select @Token = Token, @TokenExpirationDate = ExpirationDate from ( ' + @Query + N' ) t'
	
	exec sp_executesql @SQL, N'@Token varchar(1000) out, @TokenExpirationDate datetime out', @Token = @Token out, @TokenExpirationDate = @TokenExpirationDate out

	update CTRL.SourceSystemProperty 
		set PropertyValue = @Token
	where SourceSystem = @SourceSystem
		and PropertyName = 'APIToken'

	if @@rowcount = 0
		insert into CTRL.SourceSystemProperty (SourceSystem, PropertyName, PropertyValue)
		values (@SourceSystem, 'APIToken', @Token)

	update CTRL.SourceSystemProperty 
		set PropertyValue = format(@TokenExpirationDate, 'yyyy-MM-dd HH:mm:ss')
	where SourceSystem = @SourceSystem
		and PropertyName = 'APITokenExpirationDate'

	if @@rowcount = 0
		insert into CTRL.SourceSystemProperty (SourceSystem, PropertyName, PropertyValue)
		values (@SourceSystem, 'APITokenExpirationDate', format(@TokenExpirationDate, 'yyyy-MM-dd HH:mm:ss'))

end