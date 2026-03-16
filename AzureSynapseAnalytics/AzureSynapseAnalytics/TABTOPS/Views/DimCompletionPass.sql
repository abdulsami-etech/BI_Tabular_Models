CREATE VIEW [TABTOPS].[DimCompletionPass]
AS select	SKCompletionPass
	,	KeyCompletionPass as CompletionPass
from DWTOPS.DimCompletionPass;