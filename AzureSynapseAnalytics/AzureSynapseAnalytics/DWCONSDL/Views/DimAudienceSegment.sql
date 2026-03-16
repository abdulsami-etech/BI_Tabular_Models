CREATE VIEW [DWCONSDL].[DimAudienceSegment]
AS SELECT  AudienceSegmentKey			
	,	AudienceSegment
	,	BusinessSegment
	,	SortOrder		
FROM [SrcCONSDL].[AudienceSegment];