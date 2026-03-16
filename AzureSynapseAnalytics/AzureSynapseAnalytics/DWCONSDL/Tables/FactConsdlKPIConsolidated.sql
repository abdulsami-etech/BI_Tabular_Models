CREATE TABLE [DWCONSDL].[FactConsdlKPIConsolidated] (
    [DWBatchID]           INT            NOT NULL,
    [DWHashKey]           CHAR (40)      NOT NULL,
    [Region]              NVARCHAR (50)  NULL,
    [CountryFromHostName] NVARCHAR (200) NULL,
    [KPI]                 NVARCHAR (200) NULL,
    [KPIDetails]          NVARCHAR (200) NULL,
    [Level]               NVARCHAR (25)  NULL,
    [StartDate]           DATE           NULL,
    [EndDate]             DATE           NULL,
    [KPIValue]            BIGINT         NULL,
    [CreatedDate]         DATETIME       NULL,
    [ModifiedDate]        DATETIME       NULL
)
WITH (CLUSTERED INDEX([StartDate]), DISTRIBUTION = ROUND_ROBIN);


GO
CREATE STATISTICS [STATS_DWCONSDL_FactConsdlKPIConsolidated_DWHashKey]
    ON [DWCONSDL].[FactConsdlKPIConsolidated]([DWHashKey]);


GO
CREATE STATISTICS [STATS_DWCONSDL_FactConsdlKPIConsolidated_StartDate]
    ON [DWCONSDL].[FactConsdlKPIConsolidated]([StartDate]);


GO
CREATE STATISTICS [STATS_DWCONSDL_FactConsdlKPIConsolidated_Level]
    ON [DWCONSDL].[FactConsdlKPIConsolidated]([Level]);


GO
CREATE STATISTICS [STATS_DWCONSDL_FactConsdlKPIConsolidated_Region]
    ON [DWCONSDL].[FactConsdlKPIConsolidated]([Region]);


GO
CREATE STATISTICS [STATS_DWCONSDL_FactConsdlKPIConsolidated_KPI]
    ON [DWCONSDL].[FactConsdlKPIConsolidated]([KPI]);

