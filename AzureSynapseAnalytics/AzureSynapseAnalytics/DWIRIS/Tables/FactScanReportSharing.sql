CREATE TABLE [DWIRIS].[FactScanReportSharing] (
    [ADLSBatchID]              INT           NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0) NOT NULL,
    [LZBatchID]                INT           NOT NULL,
    [DWBatchID]                INT           NOT NULL,
    [DWHash]                   CHAR (40)     NULL,
    [ID]                       BIGINT        NOT NULL,
    [SourceSystem]             CHAR (10)     NOT NULL,
    [SKCase]                   INT           NOT NULL,
    [KeyCase]                  BIGINT        NOT NULL,
    [CompanyId]                INT           NOT NULL,
    [DoctorId]                 INT           NOT NULL,
    [SharingType]              INT           NOT NULL,
    [SharingDateTime]          DATETIME      NOT NULL,
    [Platform]                 INT           NOT NULL,
    [ScanReportSharingImageId] INT           NOT NULL,
    [ImageType]                INT           NULL,
    [ImageId]                  VARCHAR (128) NULL,
    [IsShared]                 INT           NULL,
    [DownloadCount]            INT           NULL,
    [SKDateTime]               INT           NULL,
    CONSTRAINT [PK_FactScanReportSharing] PRIMARY KEY NONCLUSTERED ([ID] ASC, [ScanReportSharingImageId] ASC, [SourceSystem] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

