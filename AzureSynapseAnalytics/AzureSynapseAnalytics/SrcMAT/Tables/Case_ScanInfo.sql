CREATE TABLE [SrcMAT].[Case_ScanInfo] (
    [LZBatchID]                        INT           NOT NULL,
    [ADLSBatchID]                      INT           NOT NULL,
    [ADLSTimestamp]                    DATETIME2 (0) NOT NULL,
    [SalesOrderHeaderID]               INT           NOT NULL,
    [iTeroVersion]                     VARCHAR (50)  NOT NULL,
    [NumOfScans]                       SMALLINT      NOT NULL,
    [NumOfAdditionalScans]             SMALLINT      NOT NULL,
    [GuidedScanDuration]               VARCHAR (15)  NOT NULL,
    [GuidedAndAdditionalScansDuration] VARCHAR (15)  NOT NULL,
    [CartSN]                           VARCHAR (50)  NOT NULL,
    [EmbeddedHeadSN]                   VARCHAR (50)  NOT NULL,
    [SchemeTypeId]                     SMALLINT      NOT NULL,
    [DateCreated]                      DATETIME      NOT NULL,
    [RTM]                              SMALLINT      NULL,
    [DurationProcedureTime]            INT           NULL,
    [DurationScanningTime]             INT           NULL,
    [ScanningOperatorId]               INT           NULL
)
WITH (CLUSTERED INDEX([SalesOrderHeaderID]), DISTRIBUTION = ROUND_ROBIN);

