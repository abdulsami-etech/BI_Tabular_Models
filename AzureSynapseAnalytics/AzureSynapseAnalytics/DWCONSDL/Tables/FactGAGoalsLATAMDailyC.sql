CREATE TABLE [DWCONSDL].[FactGAGoalsLATAMDailyC] (
    [DWBatchID]           INT            NOT NULL,
    [DWHashKey]           CHAR (40)      NOT NULL,
    [VisitDate]           DATE           NOT NULL,
    [CountryFromHostName] NVARCHAR (200) NOT NULL,
    [G_ID1]               INT            NULL,
    [G_ID2]               INT            NULL,
    [G_ID3]               INT            NULL,
    [G_ID4]               INT            NULL,
    [G_ID5]               INT            NULL,
    [G_ID6]               INT            NULL,
    [G_ID7]               INT            NULL,
    [G_ID8]               INT            NULL,
    [G_ID9]               INT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [ModifiedDate]        DATETIME       NULL
)
WITH (CLUSTERED INDEX([VisitDate]), DISTRIBUTION = ROUND_ROBIN);

