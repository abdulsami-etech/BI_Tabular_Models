CREATE TABLE [SrcMESCorp].[AT_at_TechGeneral] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [atr_key]              BIGINT        NOT NULL,
    [site_num]             INT           NOT NULL,
    [atr_name]             NVARCHAR (64) NULL,
    [purge_status]         INT           NULL,
    [creation_time]        DATETIME      NULL,
    [InspectionRatio_I]    BIGINT        NULL,
    [MaxCases_I]           BIGINT        NULL,
    [ProfileID_I]          BIGINT        NULL,
    [Region_S]             NVARCHAR (80) NULL,
    [Station_S]            NVARCHAR (80) NULL,
    [TechID_I]             BIGINT        NULL,
    [ManufacturingCell_S]  NVARCHAR (80) NULL,
    [DoctorType_I]         BIGINT        NULL,
    [last_modified_time]   DATETIME      NULL,
    [creation_time_u]      DATETIME      NULL,
    [creation_time_z]      NVARCHAR (64) NULL,
    [last_modified_time_u] DATETIME      NULL,
    [last_modified_time_z] NVARCHAR (64) NULL,
    [parent_key]           BIGINT        NULL,
    [SiteName_S]           NVARCHAR (80) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

