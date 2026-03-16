CREATE PROC [DWSAP].[FDL_duplicatecheck] @YearMonth [Nvarchar](100),@TableName [Nvarchar](100) AS

Declare @TableName1 [Nvarchar](100)=(SELECT CASE WHEN @TableName='Revenue' THEN 'FactCOPATranspose'
WHEN @TableName ='Shipment' THEN 'FactShipments_Materialized'
WHEN @TableName='Sales Document' THEN 'DimSalesDocument' ELSE @TableName END )
DECLARE @YearMonth1 [Nvarchar](100) =(SELECT CASE WHEN LEN(@YearMonth)='6' THEN CONCAT(SUBSTRING(@YearMonth,1,4),'0',SUBSTRING(@YearMonth,6,2))
WHEN LEN(@YearMonth)='7' THEN CONCAT(SUBSTRING(@YearMonth,1,4),SUBSTRING(@YearMonth,6,2)) END)


IF(@TableName1 Not IN('RevrecShipVol','ScannerRevenueUnit','VolumeConfig','User2Groupmapping','DimSalesDocument','FactShipments_Materialized','FactShipments_Materialized_Performance') )
BEGIN
SELECT ROW_NUMBER() OVER( ORDER BY Source_Schema,Source_Table) AS [ROW],
Source_Schema,Source_Table,Column_Name,DateKeyColumn,[Value],[Value1],[Value2] INTO #T 
FROM  DWSAP.FDL_duplicatecheck_Lookup
WHERE Source_Table=''+@TableName1+''
DECLARE @Source_Schema Nvarchar(100)
DECLARE @Source_Table Nvarchar(100)
DECLARE @Column_Name Nvarchar(4000)
DECLARE @DateKeyColumn Nvarchar(100)
DECLARE @Value Nvarchar(4000)
DECLARE @Value1 Nvarchar(4000)
DECLARE @Value2 Nvarchar(4000)

DECLARE @C INT='1'
DECLARE @MAX INT=(SELECT COUNT(*) FROM #T)
WHILE (@C<=@MAX)
BEGIN
SELECT @Source_Schema=Source_Schema,@Source_Table=Source_Table,@Column_Name=Column_Name,@DateKeyColumn=DateKeyColumn
,@Value=[Value],@Value1=[Value1],@Value2=[Value2] FROM #T WHERE [ROW]=@C
EXEC(N'Insert Into DWSAP.Delete_Log(Source_Schema,Source_Table,Total_Count,[DeleteDatekey],[YearMonth],[ExecuteDate])
SELECT '''+@Source_Schema+''' ,'''+@Source_Table+''',Count(*),'''+@DateKeyColumn+''' ,FORMAT(TRY_CONVERT(DATE,'+@DateKeyColumn+'),''yyyyMM'') 
,Convert(Date,Getdate()) From '+@Source_Schema+'.'+@Source_Table+' WITH(NOLOCK) 
WHERE FORMAT(TRY_CONVERT(DATE,'+@DateKeyColumn+'),''yyyyMM'')='''+@YearMonth1+'''
GROUP BY FORMAT(TRY_CONVERT(DATE,'+@DateKeyColumn+'),''yyyyMM'')')

EXEC(N'INSERT INTO [DWSAP].[DeleteCount] 
SELECT '''+@Source_Schema+''' AS [Source_Schema],'''+@Source_Table+''' AS [Source_Table], '+@Value+' AS [Value]
, '+@Value1+' AS [Value1], '+@Value2+' AS [Value2],COUNT(*)[Count]  
FROM '+@Source_Schema+'.'+@Source_Table+' WITH(NOLOCK) WHERE FORMAT(TRY_CONVERT(DATE,'+@DateKeyColumn+'),''yyyyMM'')='''+@YearMonth1+'''
Group by '+@Value+', '+@Value1+','+@Value2+'  Having COUNT(*)>1')

EXEC (N';WITH CTE AS (
SELECT ROW_NUMBER() OVER(Partition By '+@Column_Name+' Order By '+@Column_Name+ ') AS [ROW],'+@Column_Name+'
From '+@Source_Schema+'.'+@Source_Table+' WITH(NOLOCK) WHERE FORMAT(TRY_CONVERT(DATE,'+@DateKeyColumn+'),''yyyyMM'')='''+@YearMonth1+''')
DELETE FROM CTE WHERE [ROW]>1')


SET @C=@C+1
END
DROP TABLE #T 
END

ELSE
BEGIN
SELECT ROW_NUMBER() OVER( ORDER BY Source_Schema,Source_Table) AS [ROW],
Source_Schema,Source_Table,Column_Name,DateKeyColumn,[Value],[Value1],[Value2]  INTO #T 
FROM  DWSAP.FDL_duplicatecheck_Lookup 
WHERE Source_Table=''+@TableName1+'' 
DECLARE @Source_Schema3 Nvarchar(100)
DECLARE @Source_Table3 Nvarchar(100)
DECLARE @Column_Name3 Nvarchar(4000)
DECLARE @DateKeyColumn3 Nvarchar(100)
DECLARE @Value3 Nvarchar(4000)
DECLARE @Value4 Nvarchar(4000)
DECLARE @Value5 Nvarchar(4000)

DECLARE @C3 INT='1'
DECLARE @MAX3 INT=(SELECT COUNT(*) FROM #T)
WHILE (@C3<=@MAX3)
BEGIN
SELECT @Source_Schema3=Source_Schema,@Source_Table3=Source_Table,@Column_Name3=Column_Name,@DateKeyColumn3=DateKeyColumn
,@Value3=[Value],@Value4=[Value1],@Value5=[Value2] FROM #T WHERE [ROW]=@C3

EXEC(N'Insert Into DWSAP.Delete_Log(Source_Schema,Source_Table,Total_Count,[ExecuteDate])
SELECT '''+@Source_Schema3+''' ,'''+@Source_Table3+''',Count(*),
Convert(Date,Getdate()) From '+@Source_Schema3+'.'+@Source_Table3+' WITH(NOLOCK)')


EXEC(N'INSERT INTO [DWSAP].[DeleteCount](Source_Schema,Source_Table,[Value],[Value1],[Count]) 
SELECT '''+@Source_Schema3+''' AS [Source_Schema],'''+@Source_Table3+''' AS [Source_Table], '+@Value3+' AS  [Value]
, '+@Value4+' AS  [Value1],COUNT(*)[Count]  
FROM '+@Source_Schema3+'.'+@Source_Table3+' WITH(NOLOCK)
Group by '+@Value3+','+@Value4+' Having COUNT(*)>1')

EXEC (N';WITH CTE AS (
SELECT ROW_NUMBER() OVER(Partition By '+@Column_Name3+' Order By '+@Column_Name3+ ') AS [ROW],'+@Column_Name3+'
From '+@Source_Schema3+'.'+@Source_Table3+' WITH(NOLOCK))
DELETE FROM CTE WHERE [ROW]>1')


SET @C3=@C3+1
END
DROP TABLE #T 
END



EXEC(N'SELECT B.Source_Table,B.Source_Schema,COUNT(B.[Count])[Count] INTO #T FROM 
[DWSAP].[DeleteCount] B
GROUP BY B.Source_Table,B.Source_Schema
UPDATE DWSAP.Delete_Log SET Duplicate_Count=B.[Count] FROM 
#T B WHERE DWSAP.Delete_Log.Source_Schema=B.Source_Schema
AND DWSAP.Delete_Log.Source_Table=B.Source_Table AND [ExecuteDate]=CONVERT(DATE,GETDATE())

DROP TABLE #T')

