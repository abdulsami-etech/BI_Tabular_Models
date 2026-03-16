CREATE TABLE [DWSAP].[TreatMPlantConfig]
(
	[Product Group] [varchar](20) NULL,
	[Production Plant] [int] NULL,
	[OrdAdqPlant] [int] NULL,
	[Treatment Plant] [int] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)