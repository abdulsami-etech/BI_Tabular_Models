CREATE PROC [DWSAP].[LoadStandardProductHierarchy] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 
DECLARE @ROWSINSERTED INT = 0 
,@ROWSUPDATED INT = 0 
DECLARE @lastdatetime datetime

BEGIN
	
  IF OBJECT_ID('DWSAP.StandardProductHierarchie_Temp', 'U') IS NOT NULL 
  DROP TABLE DWSAP.StandardProductHierarchie_Temp;
	-- DWSAP.StandardProductHierarchie source

With prodhlevel6 as (
select prodh,stufe from SrcSAP.T179 WHERE STUFE=6 
union 
select  prodh,stufe from SrcSAP.T179 WHERE stufe=5 and prodh not in (select left(prodh,10) prodh FROM SrcSAP.T179 where stufe=6)
union
select  prodh,stufe from SrcSAP.T179 WHERE stufe=4 and prodh not in (select left(prodh,8) prodh FROM SrcSAP.T179 where stufe=5)
union
select  prodh,stufe from SrcSAP.T179 WHERE stufe=3 and prodh not in (select left(prodh,6) prodh FROM SrcSAP.T179 where stufe=4)
),
prodhlevel5 as ( 
select prodh,stufe from SrcSAP.T179 WHERE STUFE=5 
union
select  prodh,stufe from SrcSAP.T179 WHERE stufe=4 and prodh not in (select left(prodh,8) prodh FROM SrcSAP.T179 where stufe=5)
union
select  prodh,stufe from SrcSAP.T179 WHERE stufe=3 and prodh not in (select left(prodh,6) prodh FROM SrcSAP.T179 where stufe=4)
),
prodhlevel4 as ( 
select prodh,stufe from SrcSAP.T179 WHERE STUFE=4 
union
select  prodh,stufe from SrcSAP.T179 WHERE stufe=3 and prodh not in (select left(prodh,6) prodh FROM SrcSAP.T179 where stufe=4)
),
prodhlevel3 as ( 
select DISTINCT prodh,stufe from SrcSAP.T179 WHERE STUFE=3
UNION 
SELECT prodh, stufe from SrcSAP.T179 WHERE stufe = 2 and prodh not in (select left(prodh, 6) prodh FROM SrcSAP.T179 where stufe=4)
), 
prodhlevel2 as ( 
select prodh,stufe from SrcSAP.T179  WHERE STUFE=2 
), 
prodhlevel1 as ( 
select PRODH,STUFE from SrcSAP.T179  WHERE STUFE=1  
)
SELECT text.VTEXT as [Level 1],text.PRODH as [Level 1 S],
text1.VTEXT as [Level 2],text1.PRODH as [Level 2 S],
text2.VTEXT as [Level 3],text2.PRODH as [Level 3 S],
text3.VTEXT as [Level 4],text3.PRODH as [Level 4 S],
text4.VTEXT as [Level 5],text4.PRODH as [Level 5 S],
text5.VTEXT as [Level 6],text5.PRODH as [Level 6 S] INTO DWSAP.StandardProductHierarchie_Temp
FROM (
select l6.prodh as Level6code, l5.prodh Level5Code , l4.prodh Level4code, l3.prodh Level3code, l2.prodh Level2code, l1.prodh Level1code
FROM prodhlevel6 l6 left join prodhlevel5 l5 on left(l6.prodh,10) = l5.prodh
left join prodhlevel4 l4 on left(l5.prodh,8)  = l4.prodh
left join prodhlevel3 l3 on left(l4.prodh,6)  = l3.prodh
left join prodhlevel2 l2 on left(l3.prodh,4)  = l2.prodh
left join prodhlevel1 l1 on left(l2.prodh,2)  = l1.prodh
) abc 

LEFT JOIN SrcSAP.T179t  text on  abc.Level1code = text .PRODH AND text.SPRAS = 'E'

LEFT JOIN SrcSAP.T179t  text1 on  abc.Level2code = text1.PRODH AND text1.SPRAS = 'E'

LEFT JOIN SrcSAP.T179t  text2 on  abc.Level3code = text2.PRODH AND text2.SPRAS = 'E'

LEFT JOIN SrcSAP.T179t  text3 on  abc.Level4code = text3.PRODH AND text3.SPRAS = 'E'

LEFT JOIN SrcSAP.T179t  text4 on  abc.Level5code = text4.PRODH AND text4.SPRAS = 'E'

LEFT JOIN SrcSAP.T179t  text5 on  abc.Level6code = text5.PRODH AND text5.SPRAS = 'E';

/*JIRA - 10997*/
	UPDATE [DWSAP].[StandardProductHierarchie_Temp]
	SET [Level 6] = NULL
	WHERE [Level 6] = [Level 5]
	
	UPDATE [DWSAP].[StandardProductHierarchie_Temp]
	SET [Level 5] = NULL
	WHERE [Level 5] = [Level 4]
	
	UPDATE [DWSAP].[StandardProductHierarchie_Temp]
	SET [Level 4] = NULL
	WHERE [Level 4] = [Level 3]
	
	UPDATE [DWSAP].[StandardProductHierarchie_Temp]
	SET [Level 3] = NULL
	WHERE [Level 3] = [Level 2]
	
	UPDATE [DWSAP].[StandardProductHierarchie_Temp]
	SET [Level 2] = NULL
	WHERE [Level 2] = [Level 1]
	
  
  	IF OBJECT_ID('DWSAP.StandardProductHierarchie_Table', 'U') IS NOT NULL 
  DROP TABLE DWSAP.StandardProductHierarchie_Table
	
	SELECT * INTO [DWSAP].[StandardProductHierarchie_Table] FROM [DWSAP].[StandardProductHierarchie_Temp]
	DROP TABLE [DWSAP].[StandardProductHierarchie_Temp]
	Select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated
END

