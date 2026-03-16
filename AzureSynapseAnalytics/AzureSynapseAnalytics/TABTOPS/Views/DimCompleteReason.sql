CREATE VIEW [TABTOPS].[DimCompleteReason]
AS SELECT	SKCompleteReason, 
		KeyCompleteReason as CompleteReason,
		IsCompletion,
		IsReject,
		IsRework,
		IsTask
FROM DWTOPS.DimCompleteReason;