CREATE VIEW [TABTOPS].[FactCCModCategory]
AS SELECT 
A.object_key																			AS [SKLotKey],
U.[SKUser],
OP.[SKOperation],
CONVERT(varchar,(MAX(CCMOD.complete_time) OVER (PARTITION BY a.dc_instance_key)),112)	AS [SKCCModdate],
convert(varchar,TOH.complete_time,112)													AS [SKCategorizationDate],
B.description_S																			AS [Category],
C.description_S																			AS [SubCategory],
TOH.complete_time																		AS [CategorizationDate],
MAX(CCMOD.complete_time) OVER (PARTITION BY a.dc_instance_key)							AS [CCModDate],
COUNT(CCMOD.tobj_history_key) OVER (PARTITION BY a.dc_instance_key)						AS [NumberRCC] 

FROM [SrcMESCorp].[DC_at_CCModCategoryHistory] A
INNER JOIN [SrcMESCorp].[AT_at_CCModCategory] B ON B.[id_I] = A.category_id
INNER JOIN [DWTOPS].[DimUser] U ON U.[KeyUser] = A.user_name
INNER JOIN [SrcMESCorp].[AT_at_CCModSubcategory] C ON C.[id_I] = A.subcategory_id
INNER JOIN [DWTOPS].[DimOperation] OP ON OP.[OperationName] = A.op_name
INNER JOIN [SrcMESCorp].[TRACKED_OBJECT_HISTORY] TOH WITH (NOLOCK) ON (a.object_key = TOH.tobj_key
														AND TOH.op_name = a.op_name
														AND a.ccmod_date_u BETWEEN TOH.start_time_u AND TOH.complete_time_u)
INNER JOIN
[SrcMESCorp].[TRACKED_OBJECT_HISTORY] CCMOD
WITH (NOLOCK) ON (CCMOD.tobj_key = a.object_key AND CCMOD.complete_time_u < a.ccmod_date_u AND CCMOD.op_name = 'ClinCheck' AND CCMOD.complete_reason = 'Fail');