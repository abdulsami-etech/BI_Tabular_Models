CREATE TABLE [SrcSAPFile].[CustomProfitCenter] (
    [LZBatchID]                       INT           NOT NULL,
    [ADLSBatchID]                     INT           NOT NULL,
    [ADLSTimestamp]                   DATETIME2 (0) NOT NULL,
    [ProfitCenterCode]                NVARCHAR (10) NOT NULL,
    [BusinessSegment]                 NVARCHAR (35) NULL,
    [BusinessSegmentSubgroup]         NVARCHAR (35) NULL,
    [GlobalRegionsExternal]           NVARCHAR (35) NULL,
    [GlobalRegionsExecutive]          NVARCHAR (35) NULL,
    [GlobalRegionsManagement]         NVARCHAR (35) NULL,
    [GlobalRegionsManagementSubgroup] NVARCHAR (35) NULL,
    [Markets]                         NVARCHAR (35) NULL,
    [BusinessLine]                    NVARCHAR (35) NULL,
    [Hedgedunhedged]                  NVARCHAR (12) NULL,
    [GlobalRegionsManufacturing]      NVARCHAR (35) NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

