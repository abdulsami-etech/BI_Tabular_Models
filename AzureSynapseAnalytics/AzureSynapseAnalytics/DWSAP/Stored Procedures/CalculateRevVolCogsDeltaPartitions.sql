CREATE PROC [DWSAP].[CalculateRevVolCogsDeltaPartitions] @dbname [nvarchar](500),@isfullprocess [int] AS 
Begin
DECLARE @SelectQuery1 nvarchar (800)
DECLARE @SelectQuery2 nvarchar (800)
DECLARE @SelectMaxQuery nvarchar (800)
DECLARE @TableName varchar (100)
DECLARE @Marker varchar (100)
DECLARE @DrivingDate varchar (100)
DECLARE @AASTableName varchar (100)
SELECT  * INTO #TemporaryAASMarker FROM DWSAP.AASTableMarkers WHERE [DbName] = ''+@dbname+''
--DELETE FROM  DWSAP.AASConfig WHERE DbName = 'RevVolCogs_Performance'  AND TableName = 'Sales Document' AND BigTableFlag = '1'
WHILE EXISTS(SELECT * FROM #TemporaryAASMarker)
	BEGIN
		SELECT TOP (1) @TableName=TableName,@Marker=Marker,@DrivingDate=DrivingDate ,
		@AASTableName = AASTableName FROM #TemporaryAASMarker
		
		DELETE FROM  DWSAP.AASConfig WHERE DbName = ''+@dbname+'' AND TableName = ''+@AASTableName+'' AND BigTableFlag = '1'
		SELECT @Marker = Marker FROM DWSAP.AASTableMarkers WHERE [TableName] = ''+@TableName+'';
		
		IF(@isfullprocess = 0 and @dbname <>'Operations')
		BEGIN
			SET @SelectQuery1 = N'INSERT INTO  DWSAP.AASConfig
			SELECT  DISTINCT  '''+@dbname+''' [DbName], ''1'' [BigTableFlag],'''+@AASTableName+ ''' [TableName], CONCAT (YEAR(try_Cast(['+@DrivingDate+'] as date)),''-'',MONTH(try_Cast(['+@DrivingDate+'] as date))) as [PartitionName]
			FROM '+@TableName+' WHERE ADLSTimeStamp > '''+ @Marker +''' AND YEAR(try_Cast(['+@DrivingDate+'] as date)) >= ''2016'' 
				AND CONCAT(YEAR(try_Cast(['+@DrivingDate+'] as date)),''-'',MONTH(try_Cast(['+@DrivingDate+'] as date))) NOT IN 
					(
						''2016-1'',
						''2016-2'',
						''2016-3'',
						''2016-4'',
						''2016-5''
					)'
			print (@SelectQuery1)
			exec sp_executesql @SelectQuery1
		END


		ELSE IF(@isfullprocess = 0 and @dbname ='Operations')
		BEGIN
			SET @SelectQuery1 = N'INSERT INTO  DWSAP.AASConfig
			SELECT  DISTINCT  '''+@dbname+''' [DbName], ''1'' [BigTableFlag],'''+@AASTableName+ ''' [TableName], [YearMonth] as [PartitionName]
			FROM '+@TableName+' WHERE ADLSTimeStamp > '''+ @Marker +''' AND YEAR(try_Cast(['+@DrivingDate+'] as date)) >= ''2016'' 
				AND [YearMonth] NOT IN 
					(
						''201601'',
						''201602'',
						''201603'',
						''201604'',
						''201605''
					)'
			print (@SelectQuery1)
			exec sp_executesql @SelectQuery1
		END


		ELSE IF(@isfullprocess = 1 and @dbname <>'Operations')
		BEGIN
			SET @SelectQuery2 = N'INSERT INTO  DWSAP.AASConfig
			SELECT  DISTINCT  '''+@dbname+''' [DbName], ''1'' [BigTableFlag],'''+@AASTableName+ ''' [TableName], CONCAT (YEAR(Cast(['+@DrivingDate+'] as date)),''-'',MONTH(Cast(['+@DrivingDate+'] as date))) as [PartitionName]
			FROM '+@TableName
			print (@SelectQuery2)
			exec sp_executesql @SelectQuery2
		END

		ELSE IF(@isfullprocess = 1 and @dbname ='Operations')
		BEGIN
			SET @SelectQuery2 = N'INSERT INTO  DWSAP.AASConfig
			SELECT  DISTINCT  '''+@dbname+''' [DbName], ''1'' [BigTableFlag],'''+@AASTableName+ ''' [TableName], [YearMonth] as [PartitionName]
			FROM '+@TableName
			print (@SelectQuery2)
			exec sp_executesql @SelectQuery2
		END
		
		SET @SelectMaxQuery = 'SELECT @Mark = MAX ([ADLSTimeStamp]) FROM '+@TableName ;
		EXECUTE sp_executesql @SelectMaxQuery, N'@Mark varchar(100) OUTPUT',  @Mark=@Marker OUTPUT

		UPDATE DWSAP.AASTableMarkers SET Marker = @Marker WHERE TableName = @TableName
		DELETE FROM #TemporaryAASMarker  WHERE TableName = @TableName   AND DrivingDate = @DrivingDate
		
		

	END
DROP TABLE #TemporaryAASMarker
--INSERT INTO  DWSAP.AASConfig([DbName],[BigTableFlag],[TableName],[PartitionName])
--SELECT 'RevVolCogs_Performance' AS [DbName],'1' [BigTableFlag],'Sales Document' [TableName],CONCAT(YEAR(GETDATE()),'-',MONTH(GETDATE()))[PartitionName]
END