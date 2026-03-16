create procedure CTRL.ADLQueryJSON @JSONQuery nvarchar(max), @json varchar(max)
as
begin
	set nocount on
	exec sp_executesql @JSONQuery, N'@json varchar(max)', @json
end