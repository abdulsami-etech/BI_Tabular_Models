CREATE VIEW [TABTOPS].[DimTime]
AS select	SKTime
	,	AmPm
	,	MilitaryTime
	,	StandardTime
	,	TimeOfDay
from DW.DimTime;