CREATE VIEW [TABSAP].[DimPlant]
AS SELECT [WERKS] as [Plant],
[NAME1] as [Plant Text],
[PSTLZ] as [BAS: Postal Code (Geo-Relevant)],
[EKORG] as [Purchasing organization],
[VKORG] as [Sales Organization],
[FABKL] as [Factory Calendar ID],
[LAND1] as [Country Key],
[REGIO] as [Region (State, Province, County)],
[COUNC] as [County Code],
[VTWEG] as [Distribution Channel],
[KUNNR] as [Customer Number of Plant],
[VLFKZ] as [Plant category],
[BZIRK] as [Sales District],
[STORETYPE] as [Store Category],
[DEP_STORE] as [Superordinate Department Store]
FROM [SrcSAP].[T001W];