CREATE VIEW [TABSAP].[DimCostCenter]
AS SELECT
KOKRS as [Controlling area] ,
KOSTL as [Cost Center] ,
DATBI as [Valid to] ,
DATAB as [Valid from] ,
VERAK  as [Person Responsible] ,
BUKRS as [Company code] ,
GSBER as [Business area] ,
WAERS  as [Object Currency for CO Object] ,
PRCTR as [Profit Center] ,
VERAK_USER as [User Responsible]
FROM [SrcSAP].[CSKS];