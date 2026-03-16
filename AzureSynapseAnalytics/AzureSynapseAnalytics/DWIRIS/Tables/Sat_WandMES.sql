CREATE TABLE [DWIRIS].[Sat_WandMES] (
    [SKWand]               INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [DWHash]               CHAR (40)      NOT NULL,
    [KeyWand]              NVARCHAR (160) NULL,
    [DWBatchID]            INT            NOT NULL,
    [WandID]               NVARCHAR (255) NULL,
    [CreatedDate]          DATETIME2 (0)  NULL,
    [ManufacturingCountry] NVARCHAR (255) NULL,
    [WandModel]            NVARCHAR (255) NULL
)
WITH (CLUSTERED INDEX([SKWand]), DISTRIBUTION = REPLICATE);

