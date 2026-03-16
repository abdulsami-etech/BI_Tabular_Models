CREATE VIEW [TABTOPS].[DimPlant]
AS select	SKPlant
	,	KeyPlant as PlantName
	,	PlantDescription
	,	PlantCategory
from DWTOPS.DimPlant;