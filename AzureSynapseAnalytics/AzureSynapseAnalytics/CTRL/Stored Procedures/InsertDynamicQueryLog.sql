CREATE PROC [CTRL].[InsertDynamicQueryLog] @SessionID [uniqueidentifier],@SQLQuery [nvarchar](max) AS
begin
	set nocount on

	declare @ts datetime2(3) = getdate()

	insert into CTRL.DynamicQueryLog (SessionID, SQLQuery, DateInserted)
	values (@SessionID, @SQLQuery, @ts)

end
