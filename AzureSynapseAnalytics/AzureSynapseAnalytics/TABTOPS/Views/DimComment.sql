CREATE VIEW [TABTOPS].[DimComment]
AS select	SKComment
	,	KeyComment as Comment
from DWTOPS.DimComment;