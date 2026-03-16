CREATE PROC [DWSAP].[DropSrcTable] @ObjectName [nvarchar](100) AS
BEGIN
Declare @Query1 nvarchar(MAX),
		@Query2 nvarchar(MAX),
		@Query3 nvarchar(MAX)

 IF(@ObjectName IN (Select [TableName] FROM [dbo].[FileProcessingTables]))
	BEGIN
		IF Exists(Select * from INFORMATION_SCHEMA.TABLES where [TABLE_SCHEMA] = 'SrcSapFile' and [TABLE_NAME] = @ObjectName)
			BEGIN
				IF Exists(Select * from INFORMATION_SCHEMA.TABLES where [TABLE_SCHEMA] = 'DWSAP' and 
														[TABLE_NAME] = Concat(@ObjectName,'-Backup'))
					BEGIN
						Set @Query1 = N'DROP TABLE [DWSAP].[' + @ObjectName + '-Backup]'
						Print @Query1
						EXEC sp_executesql @Query1
						
						Set @Query2 = N'Select * INTO [DWSAP].[' + @ObjectName + '-Backup] FROM SrcSapFile.' + @ObjectName
						Print @Query2
						EXEC sp_executesql @Query2
					END

				ELSE
				BEGIN
					Set @Query2 = N'Select * INTO [DWSAP].[' + @ObjectName + '-Backup] FROM SrcSapFile.' + @ObjectName
					Print @Query2
					EXEC sp_executesql @Query2
				END
			Set @Query3 = N'DROP TABLE SrcSapFile.' + @ObjectName
			Print @Query3
			EXEC sp_executesql @Query3
			END
	END

 ELSE
	Print('NULL')

END
