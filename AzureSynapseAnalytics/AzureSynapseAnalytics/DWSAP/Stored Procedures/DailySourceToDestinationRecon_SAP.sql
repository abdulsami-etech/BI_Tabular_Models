CREATE PROC [DWSAP].[DailySourceToDestinationRecon_SAP] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS

BEGIN
	Declare @RowsInserted	int = 0,
			@RowsUpdated	int = 0,
			@IsFullLoad		bit = 0

	Declare @Operation nvarchar(100),
			@Columname nvarchar(10),
			@SQLTablename nvarchar(500),
			@SAPTablename nvarchar(100),
			@ConfigID int,
			@DateColumn nvarchar(20),
			@Query1 nvarchar(MAX),
			@Query2 nvarchar(MAX),
			@Query3 nvarchar(MAX),
			@Row_id int,
			@CurrDate datetime,
			@ExtractionType nvarchar(30),
			@ObjectType nvarchar(30)

	SELECT Row_NUMBER() OVER ( ORDER BY ConfigID ) as Row_num, *
		INTO #Temp_DWConfig FROM [TABSAP].[FDLRecon_Config]

		Set @Row_id = 1

		While @Row_id <= (Select Max(Row_num) from #Temp_DWConfig)
		BEGIN
			SELECT @Operation = [AggregateOperation] FROM #Temp_DWConfig where [Row_num] = @Row_id
			SELECT @Columname = [Columname] FROM #Temp_DWConfig where [Row_num] = @Row_id
			SELECT @SQLTablename = [SQLTablename] FROM #Temp_DWConfig where [Row_num] = @Row_id
			SELECT @SAPTablename = Concat('''',[SAPTablename],'''') FROM #Temp_DWConfig where [Row_num] = @Row_id
			SELECT @DateColumn = [Filter_Condition_Column_1] FROM #Temp_DWConfig where [Row_num] = @Row_id
			SELECT @ConfigID = [ConfigID] FROM #Temp_DWConfig where [Row_num] = @Row_id
			SELECT @ObjectType = [ObjectType] FROM #Temp_DWConfig where [Row_num] = @Row_id
			SELECT @ExtractionType = [Full/Delta] FROM #Temp_DWConfig where [Row_num] = @Row_id

			IF @ExtractionType = 'Delta'
			BEGIN

			Set @Query1 = N'SELECT ' + @DateColumn + ',' + @Operation + '('+@Columname+')' + ' AS [SQLCount], (SELECT COUNT(*) FROM ' + @SQLTablename +
									 ' where try_Cast(' + @DateColumn + ' as date) <= (Select try_Cast(getdate()-1 as date))) as [TOT_SQLCount] INTO #Temp_SQLCount FROM ' + @SQLTablename + ' WHERE ' + @DateColumn + ' IN (SELECT DISTINCT [ERDAT]
									  FROM [SrcSAP].[Ztable_no_of_rec] WHERE [TABNAME] = ' + @SAPTablename + ' AND try_Cast([ERDAT] as date) = (Select try_Cast(getdate()-1 as date)) )
                                      GROUP BY ' + @DateColumn
			EXEC sp_executesql @Query1


			Set @Query2 = N'SELECT c.[ConfigID],
								   c.[SQLTablename],
								   c.[SAPTablename],
								   b. ' + @DateColumn + ' as [DrivingDate],
								   a.[RECORDS] as [SAPCount],
								   a.[TOT_RECORDS] as [TOT_SAPCount],
								   b.[TOT_SQLCount],
								   b.[SQLCount] as [DWCount],
								 ( a.[RECORDS] - b.[SQLCount]) as [PeriodCountDiff],
								 ( a.[TOT_RECORDS] - b.[TOT_SQLCount]) as [TOT_CountDiff]
						  		 INTO #Temp_CountDiff FROM SrcSAP.Ztable_no_of_rec a JOIN #Temp_SQLCount b ON a.[ERDAT] = b. ' + @DateColumn +
								' JOIN [TABSAP].[FDLRecon_Config] c ON a.[TABNAME] = c.[SAPTablename]
								  WHERE a.[TABNAME] = ' + @SAPTablename  
			EXEC sp_executesql @Query2


			Set @Query3 = N'Insert into #Temp_CountDiff
							(
								[ConfigID],
								[SQLTablename],
								[SAPTablename],
								[DrivingDate],
								[SAPCount],
								[DWCount],
								[PeriodCountDiff]
							)
							(
								Select 0,''NULL'',''NULL'',' + @DateColumn + ' ,0, [SQLCount], [SQLCount] FROM #Temp_SQLCount
								where ' + @DateColumn + ' NOT IN (SELECT DISTINCT [DrivingDate] FROM #Temp_CountDiff)
							)'
			EXEC sp_executesql @Query3
					
			Update #Temp_CountDiff
			Set [ConfigID] = @ConfigID,
				[SQLTablename] = @SQLTablename,
				[SAPTablename] = @SAPTablename
			Where [ConfigID] = 0 AND [SQLTablename] = 'NULL' AND [SAPTablename] = 'NULL'

			END

			ELSE
				BEGIN
					Set @Query1 = N'SELECT Count(*) as [TOT_SQLCount],' + @SAPTablename + ' as [TableName] INTO #Temp_SQLCount FROM ' + @SQLTablename
					EXEC sp_executesql @Query1

					Set @Query2 = N'SELECT c.[ConfigID],
									   c.[SQLTablename],
									   c.[SAPTablename],
									   a.ERDAT as [DrivingDate],
									   a.[TOT_RECORDS] as [SAPCount],
									   NULL as [TOT_SAPCount],
									   NULL as [TOT_SQLCount],
									   b.[TOT_SQLCount] as [DWCount],
									   ( a.[TOT_RECORDS] - b.[TOT_SQLCount]) as [PeriodCountDiff],
									   NULL as [TOT_CountDiff]
						  			 INTO #Temp_CountDiff FROM SrcSAP.Ztable_no_of_rec a JOIN #Temp_SQLCount b ON a.[TABName] = b.TableName
									JOIN [TABSAP].[FDLRecon_Config] c ON a.[TABNAME] = c.[SAPTablename]
									  WHERE a.[TABNAME] = ' + @SAPTablename + 'and a.[ERDAT] = (Select Max(ERDAT) FROM SrcSAP.Ztable_no_of_rec WHERE [TABName] = ' + @SAPTablename + ')'
					EXEC sp_executesql @Query2
				END

			SELECT @CurrDate = getdate()

			INSERT INTO [TABSAP].[FDLRecon_Difference]
			(	
				[ConfigID],
				[SQLTablename],
				[SAPTablename],
				[DWCount],
				[SAPCount],
				[Period],
				[Difference],
				[TOT_DWCount],
				[TOT_SAPCount],
				[TOT_Difference],
				[ExtractionType],
				[ObjectType]
			)
			(
			Select
				[ConfigID],
				[SQLTablename],
				[SAPTablename],
				[DWCount],
				[SAPCount],
				[DrivingDate],
				[PeriodCountDiff],
				Case When @ObjectType = 'Table'
						Then [TOT_SQLCount]
					ELSE NULL
				END,
				Case When @ObjectType = 'Table'
						Then [TOT_SAPCount]
					ELSE NULL
				END,
				Case When @ObjectType = 'Table'
						Then [TOT_CountDiff]
					ELSE NULL
				END,
				@ExtractionType,
				@ObjectType
			FROM #Temp_CountDiff
			)

			Update [TABSAP].[FDLRecon_Difference]
				Set [BatchID] = @BatchID
				   ,[ConfigDateTime] = @CurrDate
				where [BatchID] IS NULL AND [ConfigDateTime] IS NULL

			Set @Row_id = @Row_id + 1 	
			
			print(Concat('Processing Completed for',@SAPTablename));

			DROP TABLE #Temp_SQLCount
			DROP TABLE #Temp_CountDiff
		END

		print('All tables are processed');

		Update [TABSAP].[FDLRecon_Difference]
		Set [SAPTablename] = SUBSTRING([SAPTablename],2,LEN([SAPTablename])-2)
		where [SAPTablename] like '%''%';


		--Update [TABSAP].[FDLRecon_Difference]
		--Set	[Comments] = Case When [ObjectType] = 'Table' Then NULL
		--					ELSE 'View will not contain total record count'
		--				 END;
		
		print('Processing Completed');

	DROP TABLE #Temp_DWConfig
		print('Temp table dropped');
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated

END;
