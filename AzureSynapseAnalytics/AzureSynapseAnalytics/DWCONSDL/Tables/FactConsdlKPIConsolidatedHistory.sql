CREATE TABLE [DWCONSDL].[FactConsdlKPIConsolidatedHistory] (
    [Region]            	NVARCHAR (50)  		NULL,
	[GA_Region]            	NVARCHAR (50)  		NULL,
	[Country_Rollup]		NVARCHAR (200) 		NULL,
	[Country]			    NVARCHAR (200) 		NULL,
	[KPI]       			NVARCHAR (200) 		NULL,
	[KPIDetails]       		NVARCHAR (200) 		NULL,
	[Level]            		NVARCHAR (25)  		NULL,
    [StartDate]             DATE		   		NULL,
	[EndDate]               DATE		   		NULL,
	[KPIValue]				BIGINT		   		NULL,
	[ModifiedDate]			DATETIME	   		NULL
)
WITH (CLUSTERED INDEX([StartDate]), DISTRIBUTION = ROUND_ROBIN)