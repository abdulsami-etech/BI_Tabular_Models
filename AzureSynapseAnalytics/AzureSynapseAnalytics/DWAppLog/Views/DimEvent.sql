CREATE VIEW [DWAppLog].[DimEvent]
AS Select 
		SKEvent,
		FullName,
		SourceSystemCode,
		H_Level1 as [HierarchyLevel1],
		H_Level2 as [HierarchyLevel2],
		H_Level3 as [HierarchyLevel3],
		H_Level4 as [HierarchyLevel4]
	from [DWAppLog].[DictEvent];