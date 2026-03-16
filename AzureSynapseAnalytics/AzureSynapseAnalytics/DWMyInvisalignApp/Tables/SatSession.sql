CREATE TABLE [DWMyInvisalignApp].[SatSession] (
    [SKSession]             INT            NOT NULL,
    [ADLSBatchID]           INT            NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)  NOT NULL,
    [LZBatchID]             INT            NOT NULL,
    [DWBatchID]             INT            NOT NULL,
    [DWHash]                CHAR (40)      NOT NULL,
    [SessionTimestamp]      BIGINT         NOT NULL,
    [DeviceCategory]        NVARCHAR (50)  NULL,
    [DeviceBrandName]       NVARCHAR (100) NULL,
    [DeviceModelName]       NVARCHAR (100) NULL,
    [DeviceMarketingName]   NVARCHAR (100) NULL,
    [DeviceOSHardwareModel] NVARCHAR (100) NULL,
    [DeviceOS]              NVARCHAR (100) NULL,
    [DeviceOSVersion]       NVARCHAR (100) NULL,
    [AppVersion]            NVARCHAR (100) NULL,
    [AppInstallSource]      NVARCHAR (100) NULL
)
WITH (CLUSTERED INDEX([SKSession]), DISTRIBUTION = REPLICATE);

