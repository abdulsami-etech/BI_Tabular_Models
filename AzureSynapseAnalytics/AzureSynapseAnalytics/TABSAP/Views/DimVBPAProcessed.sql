CREATE VIEW [TABSAP].[DimVBPAProcessed]
AS select * from(
 select [KUNNR],[VBELN],[PARVW] FROM [SrcSAP].[VBPA] ) src
pivot
( max([KUNNR]) for [PARVW] in (ZA,ZM,ZF,ZJ,ZS,ZE)) piv;