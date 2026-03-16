CREATE TABLE [DWCONSDL].[FactGAUMsC] (
    [DWBatchID]           INT            NOT NULL,
    [DWHashKey]           CHAR (40)      NOT NULL,
    [Level]               NVARCHAR (25)  NULL,
    [Region]              NVARCHAR (50)  NULL,
    [StartDate]           DATE           NULL,
    [EndDate]             DATE           NULL,
    [CountryFromHostName] NVARCHAR (200) NULL,
    [UVs]                 INT            NULL,
    [UPVs]                INT            NULL,
    [Sessions]            INT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [ModifiedDate]        DATETIME       NULL
)
WITH (CLUSTERED INDEX([StartDate]), DISTRIBUTION = ROUND_ROBIN);

