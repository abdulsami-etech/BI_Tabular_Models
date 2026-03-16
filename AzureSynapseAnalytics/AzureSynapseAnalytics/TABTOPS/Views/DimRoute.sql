CREATE VIEW [TABTOPS].[DimRoute]
AS select	h.SKRoute
	,	d.RouteName
from DWTOPS.HubRoute h
left join DWTOPS.DimRoute d on d.SKRoute = h.SKRoute;