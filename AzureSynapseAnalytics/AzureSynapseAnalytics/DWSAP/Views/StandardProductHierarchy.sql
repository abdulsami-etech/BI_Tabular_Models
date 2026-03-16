CREATE VIEW [DWSAP].[StandardProductHierarchy]
AS SELECT  
fph.[LEVEL1] as [Level 1 S],
tt1.VTEXT as [Level 1 Text],
fph.[LEVEL2] as [Level 2 S],
tt2.VTEXT as [Level 2 Text],
fph.[LEVEL3] as [Level 3 S],
tt3.VTEXT as [Level 3 Text],
fph.[LEVEL4] as [Level 4 S],
tt4.VTEXT as [Level 4 Text],
fph.[LEVEL5] as [Level 5 S],
tt5.VTEXT as [Level 5 Text],
fph.[LEVEL6] as [Level 6 S],
tt6.VTEXT as [Level 6 Text]
FROM  SrcSAPFile.FlattenedProductHierarchy fph 
LEFT JOIN SrcSAP.T179T   tt1 on tt1.PRODH  = fph.[LEVEL1] AND tt1.SPRAS = 'E'
LEFT  JOIN SrcSAP.T179T   tt2 on tt2.PRODH  = fph.[LEVEL2] AND tt2.SPRAS = 'E'
LEFT  JOIN SrcSAP.T179T   tt3 on tt3.PRODH  = fph.[LEVEL3] AND tt3.SPRAS = 'E'
LEFT  JOIN SrcSAP.T179T   tt4 on tt4.PRODH  = fph.[LEVEL4] AND tt4.SPRAS = 'E'
LEFT  JOIN SrcSAP.T179T   tt5 on tt5.PRODH  = fph.[LEVEL5] AND tt5.SPRAS = 'E'
LEFT  JOIN SrcSAP.T179T   tt6 on tt6.PRODH  = fph.[LEVEL6] AND tt6.SPRAS = 'E';