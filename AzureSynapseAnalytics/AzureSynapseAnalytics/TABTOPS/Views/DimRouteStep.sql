CREATE VIEW [TABTOPS].[DimRouteStep]
AS select	h.SKRouteStep
	,	d.RouteStepName
	,	d.RouteStepType
	,	d.RouteStepCategory
from DWTOPS.HubRouteStep h
left join DWTOPS.DimRouteStep d on d.SKRouteStep = h.SKRouteStep;