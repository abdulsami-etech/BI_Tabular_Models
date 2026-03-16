CREATE VIEW [TABTOPS].[DimPart]
AS select	h.SKPart
	,	d.PartNumber
	,	d.PartRevision
	,	d.PartDescription
	,	d.PartCategory
from DWTOPS.HubPart h
left join DWTOPS.DimPart d on d.SKPart = h.SKPart;