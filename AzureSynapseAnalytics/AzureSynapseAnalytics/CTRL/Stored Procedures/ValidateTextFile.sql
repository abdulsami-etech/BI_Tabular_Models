CREATE PROC [CTRL].[ValidateTextFile] @tempTableName varchar(200),@SourceColumnName varchar(200),@LookupTableName varchar(200),@LookupColumnName varchar(200) AS
begin

declare @RowsUpdated	int = 0
declare	@SQL2 varchar(max) 
declare @thisLabel varchar(500) 

SET @thisLabel = 'CTRL.ValidateTextFile_'+@tempTableName+'_'+@SourceColumnName

IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(@tempTableName) AND name = 'ValidationErrorMessage')
BEGIN
declare	@SQL1 varchar(max) 
SET @SQL1 = 'ALTER TABLE '+ @tempTableName + ' ADD ValidationErrorMessage varchar(1000) null'
exec(@SQL1)
END

SET @SQL2 = 'UPDATE '+ @tempTableName + ' SET ValidationErrorMessage = CONCAT(ValidationErrorMessage,''Invalid Value for '+ @SourceColumnName+';'') WHERE '+@SourceColumnName+' NOT IN (SELECT '+@LookupColumnName+ ' FROM '+@LookupTableName+') option (label = '''+@thisLabel+''')';

exec(@SQL2)

exec CTRL.GetLastRowCount @Label = @thisLabel, @rc = @RowsUpdated out

select @RowsUpdated as RowsUpdated

END
