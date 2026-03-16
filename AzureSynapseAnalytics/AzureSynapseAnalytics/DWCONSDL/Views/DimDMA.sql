CREATE VIEW [DWCONSDL].[DimDMA]
AS SELECT  Zip			
	,	DMAName
	,	ConsumerMarketingDBName
	,	ConsumerMarketingName
	,	UsStateCode
FROM [SrcCONSDL].[DMA];