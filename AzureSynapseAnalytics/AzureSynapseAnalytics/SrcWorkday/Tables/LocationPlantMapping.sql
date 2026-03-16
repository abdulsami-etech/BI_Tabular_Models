CREATE TABLE [SrcWorkday].[LocationPlantMapping] (
    [KeyPlant]           VARCHAR (64)  NOT NULL,
    [HRPlantDescription] VARCHAR (200) NOT NULL
)
WITH (CLUSTERED INDEX([KeyPlant]), DISTRIBUTION = REPLICATE);

