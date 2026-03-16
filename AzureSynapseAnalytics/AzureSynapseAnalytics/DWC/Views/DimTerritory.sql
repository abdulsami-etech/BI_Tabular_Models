CREATE VIEW [DWC].[DimTerritory]
AS select t.[SKTerritory], t.[KeyTerritory], t.[TerritoryName], t.[TerritoryLabel], t.[TerritoryType], t.[SKUserOwner], t.[SKTerritoryParentTerritory]
from [DW].[DimTerritory] t
inner join dw.DimTerritoryHierarchy th on t.SKTerritory = th.SKTerritory
inner join dwglobal.GeographyRegion d
on d.RegionGroup = isnull(Case th.[TerritoryNameL1] when 'North America' then 'NA' when 'N/A' then 'Unassigned' else th.TerritoryNameL1 END ,'Unassigned')
and dataset='DWC';