CREATE TABLE [DWIRIS].[DimCase] (
    [SKCase]               INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [LZBatchID]            INT           NOT NULL,
    [DWBatchID]            INT           NOT NULL,
    [DWHash]               CHAR (40)     NOT NULL,
    [KeyCase]              INT           NOT NULL,
    [CaseCode]             VARCHAR (12)  NULL,
    [CaseTypeId]           SMALLINT      NULL,
    [CaseTypeName]         NVARCHAR (64) NULL,
    [IsIDX]                NCHAR (3)     DEFAULT (N'No') NOT NULL,
    [IsIDE]                NCHAR (3)     DEFAULT (N'No') NOT NULL,
    [IsInactive]           NCHAR (3)     DEFAULT (N'No') NOT NULL,
    [IsWithoutMilling]     NCHAR (3)     DEFAULT (N'No') NOT NULL,
    [IsDigital]            NVARCHAR (20) DEFAULT (N'Unknown') NOT NULL,
    [ScannerID]            INT           NULL,
    [ITeroVersion]         NVARCHAR (50) NULL,
    [IsScannerKnown]       NCHAR (3)     NULL,
    [NumberOfModels]       TINYINT       NULL,
    [CaseDateCreated]      DATETIME      NULL,
    [MillingSiteID]        INT           NULL,
    [InterpretationSiteID] INT           NULL,
    [ModelingSiteID]       INT           NULL,
    [InitiatorPartnerID]   INT           NULL,
    [InitiatorContactID]   INT           NULL,
    [ScanArrivalDate]      DATETIME      NULL,
    [CurrentBillOfWork]    INT           NULL,
    [ProductTypeID]        TINYINT       NULL,
    [DueDate]              DATETIME      NULL,
    [MaxDateUpdated]       DATETIME      NULL,
    [PartnerLabID]         INT           NULL,
    [InstrCode]            NVARCHAR (50) NULL,
    [AnteriorPosterior]    NVARCHAR (9)  NULL,
    [BaseUnitSN]           VARCHAR (50)  NULL,
    [WandSN]               VARCHAR (50)  NULL,
    [IsDirectToLab]        VARCHAR (10)  NULL,
    [IsColorScan]          char(3) NULL,
    [TotalColorScans]      int
)
WITH
(
	DISTRIBUTION = HASH ( [SKCase] ),
	CLUSTERED COLUMNSTORE INDEX
);

GO
CREATE NONCLUSTERED INDEX [IX_DimCase_KeyOrder]
    ON [DWIRIS].[DimCase]([KeyCase] ASC);

