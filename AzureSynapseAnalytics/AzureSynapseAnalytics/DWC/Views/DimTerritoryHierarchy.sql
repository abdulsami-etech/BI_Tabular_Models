CREATE VIEW [DWC].[DimTerritoryHierarchy]
AS select t.[SKTerritory], t.[KeyTerritory], t.[TerritoryType], t.[TerritoryNameL7], t.[OwnerUserNameL7],t.[SKUserOwnerL7], t.OwnerUserEmailL7, t.OwnerUserRoleL7
, t.[TerritoryNameL6], t.[OwnerUserNameL6], t.[SKUserOwnerL6], t.OwnerUserEmailL6, t.OwnerUserRoleL6
, t.[TerritoryNameL5], t.[OwnerUserNameL5], t.[SKUserOwnerL5], t.OwnerUserEmailL5, t.OwnerUserRoleL5
, t.[TerritoryNameL4], t.[OwnerUserNameL4], t.[SKUserOwnerL4], t.OwnerUserEmailL4, t.OwnerUserRoleL4
, t.[TerritoryNameL3], t.[OwnerUserNameL3], t.[SKUserOwnerL3], t.OwnerUserEmailL3, t.OwnerUserRoleL3
, t.[TerritoryNameL2], t.[OwnerUserNameL2], t.[SKUserOwnerL2], t.OwnerUserEmailL2, t.OwnerUserRoleL2
, t.[TerritoryNameL1], t.[OwnerUserNameL1], t.[SKUserOwnerL1], t.OwnerUserEmailL1, t.OwnerUserRoleL1
from [DW].[DimTerritoryHierarchy] t
inner join dwglobal.GeographyRegion d on d.RegionGroup = isnull(Case t.[TerritoryNameL1] when 'North America' then 'NA' when 'N/A' then 'Unassigned' else t.TerritoryNameL1 END ,'Unassigned') and d.dataset='DWC';