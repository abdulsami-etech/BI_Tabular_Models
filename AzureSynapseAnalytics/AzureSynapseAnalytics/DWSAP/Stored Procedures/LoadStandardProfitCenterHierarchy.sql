CREATE PROC [DWSAP].[LoadStandardProfitCenterHierarchy] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 
DECLARE @ROWSINSERTED INT = 0 
,@ROWSUPDATED INT = 0 
DECLARE @lastdatetime datetime
BEGIN
	
	 IF OBJECT_ID('DWSAP.StandardProfitCenterHierarchy_Temp', 'U') IS NOT NULL 
  DROP TABLE DWSAP.StandardProfitCenterHierarchy_Temp;
 
 	IF OBJECT_ID('#ProfitTemp', 'U') IS NOT NULL 
  DROP TABLE #ProfitTemp;
	
	
	
SELECT DISTINCT 
[Level 1] as [Level 1],
[Level 2] as [Level 2],
setnode1.SEQNR as [SequenceNumber2],
[Level 3] as [Level 3],
COALESCE(setnode2.SEQNR, setleaf1.SEQNR) as [SequenceNumber3],
[Level 4] as [Level 4],
COALESCE (setnode3.SEQNR, setleaf2.SEQNR) as [SequenceNumber4], 
[Level 5] as [Level 5],
COALESCE (setnode4.SEQNR, setleaf4.SEQNR) as [SequenceNumber5], 
[Level 6] as [Level 6],
COALESCE(setnode5.SEQNR, setleaf5.SEQNR) as [SequenceNumber6],
[Level 7] as [Level 7],
setleaf.SEQNR as [SequenceNumber7]  INTO #ProfitTemp 

FROM (

SELECT DISTINCT setheadert1.DESCRIPT as [Level 1],

setheader2.[DESCRIPT] as [Level 2], 

COALESCE (setnode2.SUBSETNAME,setleaf1.VALFROM) as [Level 3], 

/*BI-1264*/
COALESCE (setnode3.SUBSETNAME,setleaf2.VALFROM,setleaf3.VALFROM) as [Level 4], 


COALESCE (setnode4.SUBSETNAME,setleaf4.VALFROM) as [Level 5],

COALESCE (setnode5.SUBSETNAME,setleaf5.VALFROM) as [Level 6],


setleaf.VALFROM as [Level 7]

--setnode2.[SUBSETNAME] as [Level 4 Code] 


FROM SrcSAP.SETNODE setnode1  
-- Level 1 
LEFT JOIN SrcSAP.SETHEADERT  setheadert1 On setheadert1.SETNAME = setnode1.SETNAME  AND setheadert1.LANGU  = 'E'

-- Level 2 
LEFT JOIN SrcSAP.SETHEADERT setheader2  on setnode1.SUBSETNAME = setheader2.SETNAME  AND setheader2.LANGU = 'E'

-- Level 3 

LEFT JOIN SrcSAP.SETNODE setnode2 on setnode1.SUBSETNAME = setnode2.SETNAME 
LEFT JOIN SrcSAP.SETLEAF setleaf1 on  setnode1.SUBSETNAME = setleaf1.SETNAME 
-- Level 4
LEFT JOIN SrCSAP.SETNODE  setnode3 on setnode2.SUBSETNAME = setnode3.SETNAME 
LEFT JOIN SrcSAP.SETLEAF setleaf2 on setnode3.SUBSETNAME = setleaf2.SETNAME 
LEFT JOIN SrcSAP.SETLEAF setleaf3 on setnode2.SUBSETNAME = setleaf3.SETNAME 
-- Level 5 
LEFT JOIN SrcSAP.SETNODE setnode4 on setnode3.SUBSETNAME = setnode4.SETNAME 
LEFT JOIN SrCSAP.SETLEAF setleaf4 on setnode3.SUBSETNAME = setleaf4.SETNAME 
-- Level 6 
LEFT JOIN  SrcSAP.SETNODE setnode5 on setnode4.SUBSETNAME = setnode5.SETNAME 
LEFT JOIN SrcSAP.SETLEAF  setleaf5 on setnode4.SUBSETNAME = setleaf5.SETNAME 
-- Level 7
--LEFT JOIN 
--SrcSAP.SETNODE setnode6 on setnode5.SUBSETNAME = setnode6.SETNAME 	
-- Level 7
LEFT JOIN 
SrcSAP.SETLEAF setleaf on setnode5.SUBSETNAME = setleaf.SETNAME 

WHERE
setnode1.SETNAME = 'AT001' AND 
setnode1.SETCLASS = '0106'
-- For Level 4 Leafs
UNION  

SELECT  
DISTINCT  
setheadert1 .DESCRIPT  as [Level 1] ,
setheadert2 .DESCRIPT as [Level 2],
COALESCE (setnode3.SETNAME ,setleaf.VALFROM)as [Level 3],
COALESCE (setleaf2.VALFROM,'1') as [Level 4],
setleaf2.VALFROM as [Level 5],
setleaf2.VALFROM as [Level 6],
setleaf2.VALFROM as [Level 7]

FROM  SrcSAP.SETNODE setnode1  
--Level 1 Text 
LEFT JOIN SrcSAP.SETHEADERT setheadert1  ON setheadert1.SETNAME = setnode1.SETNAME  AND setheadert1.LANGU = 'E'

--level2
LEFT JOIN SrcSAP.SETNODE setnode2 on setnode1.SUBSETNAME = setnode2.SETNAME 
LEFT JOIN SrcSAP.SETHEADERT setheadert2 on setheadert2.SETNAME = setnode2.SETNAME  AND setheadert2.LANGU = 'E'

--level3 
LEFT  JOIN  SrcSAP.SETNODE setnode3 on setnode2.SUBSETNAME  = setnode3.SETNAME 
LEFT JOIN SrcSAP.SETLEAF setleaf on setleaf.SETNAME = setnode2.SUBSETNAME 
--level4
LEFT JOIN SrcSAP.SETLEAF setleaf2 on setleaf2.SETNAME= setnode3.SETNAME 


WHERE setnode1.SETNAME = 'AT001' AND setleaf2.VALFROM IS NOT NULL 


UNION 
--For Level 5 Leafs
SELECT  
DISTINCT  
setheadert1 .DESCRIPT  as [Level 1] ,
setheadert2 .DESCRIPT as [Level 2],
setnode3.SETNAME as [Level 3],
setnode4.SETNAME as [Level 4],
setleaf2.VALFROM as [Level 5],
setleaf2.VALFROM as [Level 6],
setleaf2.VALFROM as [Level 7]

FROM  SrcSAP.SETNODE setnode1  
--Level 1 Text
LEFT JOIN SrcSAP.SETHEADERT setheadert1  ON  setheadert1.SETNAME = setnode1.SETNAME  AND setheadert1.LANGU = 'E'
--level2
LEFT JOIN SrcSAP.SETNODE setnode2 on setnode1.SUBSETNAME = setnode2.SETNAME 
LEFT JOIN SrcSAP.SETHEADERT setheadert2 on setheadert2.SETNAME = setnode2.SETNAME  AND setheadert2.LANGU = 'E'
--level3 
LEFT  JOIN  SrcSAP.SETNODE setnode3 on setnode2.SUBSETNAME  = setnode3.SETNAME 

--level4
LEFT JOIN SrcSAP.SETNODE  setnode4 on setnode3.SUBSETNAME= setnode4.SETNAME 
--level5
LEFT JOIN SrcSAP.SETLEAF setleaf2 on setleaf2.SETNAME = setnode4.SETNAME 

WHERE setnode1.SETNAME = 'AT001'  
AND setleaf2.VALFROM IS NOT NULL

UNION 
--For level 6
SELECT  
DISTINCT  
setheadert1 .DESCRIPT  as [Level 1] ,
setheadert2 .DESCRIPT as [Level 2],
setnode3.SETNAME as [Level 3],
setnode4.SETNAME as [Level 4],
setnode5.SETNAME as [Level 5], 
setleaf2.VALFROM as [Level 6],
setleaf2.VALFROM as [Level 7]

FROM  SrcSAP.SETNODE setnode1  
--Level 1 Text
LEFT JOIN SrcSAP.SETHEADERT setheadert1 on setheadert1.SETNAME = setnode1.SETNAME  AND setheadert1.LANGU = 'E'
--level2
LEFT JOIN SrcSAP.SETNODE setnode2 on setnode1.SUBSETNAME = setnode2.SETNAME 
LEFT JOIN SrcSAP.SETHEADERT setheadert2 on setheadert2.SETNAME = setnode2.SETNAME  AND setheadert2.LANGU = 'E'
--level3 
LEFT  JOIN  SrcSAP.SETNODE setnode3 on setnode2.SUBSETNAME  = setnode3.SETNAME 

--level4
LEFT JOIN SrcSAP.SETNODE  setnode4 on setnode3.SUBSETNAME= setnode4.SETNAME 
--level5
LEFT JOIN SrcSAP.SETNODE setnode5 on setnode5.SETNAME = setnode4.SUBSETNAME 


--level6
LEFT JOIN SrcSAP.SETLEAF setleaf2 on setleaf2.SETNAME = setnode5.SETNAME 


WHERE setnode1.SETNAME = 'AT001'  
AND setleaf2.VALFROM IS NOT NULL

UNION 

SELECT 
setheadert.DESCRIPT as [Level 1],
setheadert1.DESCRIPT as [Level 2],
setheadert2.DESCRIPT as [Level 3],
setheadert3.DESCRIPT as [Level 4],
[Level 5] as [Level 5],
[Level 5] as [Level 6],
[Level 5] as [Level 7]
FROM (
SELECT  
s.SETNAME  as [Level 1], 
setnode2.SETNAME  as [Level 2],
setnode3.SETNAME  as [Level 3], 
setleaf4.SETNAME  as [Level 4],
setleaf4.VALFROM  as [Level 5]
FROM 
SrcSAP.SETNODE s  
LEFT  JOIN  SrcSAP.SETNODE setnode2 on s.SUBSETNAME  = setnode2.SETNAME 
LEFT  JOIN  SrcSAP.SETNODE setnode3 on setnode2.SUBSETNAME  = setnode3.SETNAME 
LEFT  JOIN  SrcSAP.SETLEAF  setleaf4 on setnode3.SUBSETNAME  = setleaf4.SETNAME 

WHERE s.SETNAME  = 'AT001'   AND setleaf4.SETNAME is not null) def

LEFT  JOIN SrcSAP.SETHEADERT setheadert on setheadert.SETNAME = def.[Level 1] AND setheadert.LANGU = 'E'
LEFT  JOIN SrcSAP.SETHEADERT setheadert1 on setheadert1.SETNAME = def.[Level 2] AND setheadert1.LANGU = 'E'
LEFT  JOIN SrcSAP.SETHEADERT setheadert2 on setheadert2.SETNAME = def.[Level 3] AND setheadert2.LANGU = 'E'
LEFT  JOIN SrcSAP.SETHEADERT setheadert3 on setheadert3.SETNAME = def.[Level 4] AND setheadert3.LANGU = 'E'
) abc


    
--SEQNR 2
LEFT JOIN SrcSAP.SETHEADERT setheader2 ON setheader2.DESCRIPT = abc.[Level 2] AND setheader2.LANGU = 'E'
LEFT JOIN SrcSAP.SETNODE setnode1 ON setnode1.SUBSETNAME = setheader2.SETNAME AND setheader2.SETCLASS = '0106'

--SELECT TOP 10 * FROM SrcSAP.SETNODE WHERE SETCLASS = '0106'

--SEQNR3
LEFT JOIN SrcSAP.SETNODE setnode2 ON setnode2.SUBSETNAME = abc.[Level 3] AND setnode2.SETCLASS = '0106' AND setnode2.SUBSETNAME NOT LIKE '%T%'
LEFT JOIN SrcSAP.SETLEAF setleaf1 ON setleaf1.VALFROM = abc.[Level 3] AND setleaf1.SETCLASS = '0106' AND setleaf1.SETNAME NOT LIKE '%T%'

--SEQNR4
LEFT JOIN SrcSAP.SETNODE setnode3 ON setnode3.SUBSETNAME = abc.[Level 4] AND setnode3.SETCLASS = '0106' AND setnode3.SUBSETNAME NOT LIKE '%T%'
LEFT JOIN SrcSAP.SETLEAF setleaf2 ON setleaf2.VALFROM = abc.[Level 4] AND setleaf2.SETCLASS = '0106' AND setleaf2.SETNAME NOT LIKE '%T%'


--SEQNR5
LEFT JOIN SrcSAP.SETNODE setnode4 ON setnode4.SUBSETNAME = abc.[Level 5] AND setnode4.SETCLASS = '0106' AND setnode4.SUBSETNAME NOT LIKE '%T%'
LEFT JOIN SrcSAP.SETLEAF setleaf4 ON setleaf4.VALFROM = abc.[Level 5] AND setleaf4.SETCLASS = '0106' AND setleaf4.SETNAME NOT LIKE '%T%'

--SEQNR6
LEFT JOIN SrcSAP.SETNODE setnode5 ON setnode5.SUBSETNAME = abc.[Level 6] AND setnode5.SETCLASS = '0106' AND setnode5.SUBSETNAME NOT LIKE '%T%'
LEFT JOIN SrcSAP.SETLEAF setleaf5 ON setleaf5.VALFROM = abc.[Level 6] AND setleaf5.SETCLASS = '0106' AND setleaf5.SETNAME NOT LIKE '%T%'

--SEQNR7
LEFT JOIN SrcSAP.SETLEAF setleaf ON setleaf.VALFROM = abc.[Level 7] AND setleaf.SETCLASS = '0106' AND setleaf.SETNAME NOT LIKE '%T%'

WHERE setnode1.SEQNR IS NOT NULL AND COALESCE(setnode2.SEQNR, setleaf1.SEQNR) IS NOT NULL;

 	UPDATE #ProfitTemp
    SET [Level 7] = NULL
    WHERE [Level 7] = [Level 6] 

    UPDATE #ProfitTemp
    SET [Level 6] = NULL
    WHERE [Level 6] = [Level 5] 
    
    UPDATE #ProfitTemp
    SET [Level 5] = NULL
    WHERE [Level 5] = [Level 4]
    
    UPDATE #ProfitTemp
    SET [Level 4] = NULL
    WHERE [Level 4] = [Level 3]
    
    UPDATE #ProfitTemp
    SET [Level 3] = NULL
    WHERE [Level 3] = [Level 2]
    
    UPDATE #ProfitTemp
    SET [Level 2] = NULL
    WHERE [Level 2] = [Level 1];
  

WITH CTE2 AS(SELECT NODE.SETNAME, NODE.SUBSETNAME, MAX(leaf.SEQNR)MAXLEAFSEQNR FROM
(Select DISTINCT SETNAME, SUBSETNAME, SEQNR FROM SrcSAP.SETNODE) node
LEFT JOIN
(SELECT DISTINCT SETNAME, SEQNR, VALFROM FROM SrcSAP.SETLEAF) leaf
ON leaf.SETNAME = node.SETNAME
GROUP BY NODE.SETNAME, node.SUBSETNAME)
SELECT DISTINCT  
[Level 1 ], [Level 2], [SequenceNumber2],
COALESCE(setheader1.DESCRIPT,cepct1.Text ) as [Level 3],[SequenceNumber3],
COALESCE(setheader2.DESCRIPT,cepct2.Text  ) as [Level 4], [SequenceNumber4],
COALESCE(setheader3.DESCRIPT,cepct3.Text ) as [Level 5], [SequenceNumber5],
COALESCE(setheader4.DESCRIPT,cepct4.Text ) as [Level 6], [SequenceNumber6],
COALESCE(setheader5.DESCRIPT,cepct5.Text ) as [Level 7],[SequenceNumber7],
COALESCE(cepct5.PRCTR, cepct4.PRCTR, cepct3.PRCTR, cepct2.PRCTR, cepct1.PRCTR) as [Level 8] INTO [DWSAP].[StandardProfitCenterHierarchy_Temp]
FROM (
SELECT DISTINCT [Level 1],[Level 2],[SequenceNumber2],[Level 3],[SequenceNumber3]+ISNULL(B.MAXLEAFSEQNR,0)[SequenceNumber3]
,[Level 4],[SequenceNumber4]+ISNULL(C.MAXLEAFSEQNR,0)[SequenceNumber4],[Level 5],
[SequenceNumber5]+ISNULL(D.MAXLEAFSEQNR,0)[SequenceNumber5],[Level 6],
[SequenceNumber6]+ISNULL(E.MAXLEAFSEQNR,0)[SequenceNumber6],[Level 7],
[SequenceNumber7]+ISNULL(F.MAXLEAFSEQNR,0)[SequenceNumber7]
FROM #ProfitTemp A
LEFT JOIN CTE2 B ON B.SUBSETNAME=A.[Level 3]
LEFT JOIN CTE2 C ON C.SUBSETNAME=A.[Level 4]
LEFT JOIN CTE2 D ON D.SUBSETNAME=A.[Level 5]
LEFT JOIN CTE2 E ON E.SUBSETNAME=A.[Level 6]
LEFT JOIN CTE2 F ON F.SUBSETNAME=A.[Level 7]
) xyz
--Getting the Text for Level 3 
LEFT JOIN SrcSAP.SETHEADERT setheader1 on setheader1.SETNAME = xyz.[Level 3] AND setheader1.LANGU = 'E'
LEFT JOIN DWSAP.[Profit_Center_Text] cepct1 on cepct1.PRCTR  = xyz.[Level 3] 
--Getting the Text for Level 4 
LEFT JOIN SrcSAP.SETHEADERT setheader2 on setheader2.SETNAME = xyz.[Level 4] AND setheader2.LANGU = 'E'
LEFT JOIN  DWSAP.[Profit_Center_Text] cepct2 on cepct2.PRCTR  = xyz.[Level 4] 

--Getting the Text for Level 5 
LEFT JOIN SrcSAP.SETHEADERT setheader3 on setheader3.SETNAME = xyz.[Level 5] AND setheader3.LANGU = 'E'
LEFT JOIN DWSAP.[Profit_Center_Text] cepct3 on cepct3.PRCTR  = xyz.[Level 5] 

--Getting the Text for Level 6
LEFT JOIN SrcSAP.SETHEADERT setheader4 on setheader4.SETNAME = xyz.[Level 6] AND setheader4.LANGU = 'E'
LEFT JOIN DWSAP.[Profit_Center_Text] cepct4 on cepct4.PRCTR  = xyz.[Level 6] 


--Getting the Text for Level 7
LEFT JOIN SrcSAP.SETHEADERT setheader5 on setheader5.SETNAME = xyz.[Level 7] AND setheader5.LANGU = 'E'
LEFT JOIN DWSAP.[Profit_Center_Text] cepct5 on cepct5.PRCTR  = xyz.[Level 7];

	
		IF OBJECT_ID('DWSAP.StandardProfitCenterHierarchy_Table', 'U') IS NOT NULL 
  DROP TABLE DWSAP.StandardProfitCenterHierarchy_Table

	SELECT * INTO [DWSAP].[StandardProfitCenterHierarchy_Table] 
	FROM [DWSAP].[StandardProfitCenterHierarchy_Temp]
	DROP TABLE [DWSAP].[StandardProfitCenterHierarchy_Temp]
	DROP TABLE #ProfitTemp
	Select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated

END
