CREATE TABLE [DWCONSDL].[FactGAGoalsEMEADailyC] (
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
    [G_ID10]              INT            NULL,
    [G_ID11]              INT            NULL,
    [G_ID12]              INT            NULL,
    [G_ID13]              INT            NULL,
    [G_ID14]              INT            NULL,
    [G_ID15]              INT            NULL,
    [G_ID16]              INT            NULL,
    [G_ID17]              INT            NULL,
    [G_ID18]              INT            NULL,
    [G_ID19]              INT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [ModifiedDate]        DATETIME       NULL
)
WITH (CLUSTERED INDEX([VisitDate]), DISTRIBUTION = ROUND_ROBIN);

