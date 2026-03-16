CREATE VIEW [DWCONSDL].[DimLevelOfInterest]
AS SELECT  LevelOfInterestKey			
	,	LevelOfInterestName
	,	LevelOfInterestGroupKey
	,	LevelOfInterestGroup		
FROM [SrcCONSDL].[LevelOfInterest];