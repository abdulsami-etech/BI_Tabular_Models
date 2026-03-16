CREATE VIEW [TABTOPS].[DimTeamRegion]
AS select	h.SKTeamRegion
	,	h.KeyTeamRegion as RegionName
	,	d.GroupRegion
	,   g.[SKGroupRegion]
from DWTOPS.HubTeamRegion h
left join DWTOPS.DimTeamRegion d on d.SKTeamRegion = h.SKTeamRegion
left join [TABTOPS].[DimGroupRegion] g on g.GroupRegion=d.GroupRegion;