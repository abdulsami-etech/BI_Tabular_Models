CREATE TABLE [DWSAP].[ValueConfig] (
    [Id]                  INT          NULL,
    [ItemCategory]        VARCHAR (50) NULL,
    [DeliverableCategory] VARCHAR (50) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

