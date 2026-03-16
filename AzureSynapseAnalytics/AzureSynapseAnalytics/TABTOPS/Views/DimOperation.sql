CREATE VIEW [TABTOPS].[DimOperation]
AS select	h.SKOperation 
	,	d.OperationName
	,	d.OperationDescription
	,	d.OperationCategory
from DWTOPS.HubOperation h
left join DWTOPS.DimOperation d on d.SKOperation = h.SKOperation;