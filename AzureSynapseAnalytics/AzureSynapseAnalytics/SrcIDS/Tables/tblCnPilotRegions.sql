CREATE TABLE [SrcIDS].[tblCnPilotRegions] (
    [LZBatchID]       INT            NOT NULL,
    [ADLSBatchID]     INT            NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0)  NOT NULL,
    [pilot_region_id] INT            NOT NULL,
    [product]         NVARCHAR (255) NULL,
    [country]         NVARCHAR (50)  NULL,
    [create_date]     DATETIME2 (7)  NULL,
    [user_name]       NVARCHAR (50)  NULL,
    [disable_date]    DATETIME2 (7)  NULL,
    [region_code]     NVARCHAR (50)  NULL,
    [doctor_category] NVARCHAR (11)  NULL,
    [_Region]         VARCHAR (32)   NOT NULL
)
WITH (CLUSTERED INDEX([pilot_region_id]), DISTRIBUTION = HASH([pilot_region_id]));

