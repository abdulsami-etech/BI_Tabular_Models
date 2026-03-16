CREATE TABLE [DW].[CaseState_TEMP] (
    [DWBatchID]                      INT             NOT NULL,
    [ClinID]                         NVARCHAR (1300) NULL,
    [DID]                            NVARCHAR (1300) NULL,
    [TreatmentID]                    NVARCHAR (1300) NULL,
    [SAPOrdernumber]                 NVARCHAR (64)   NOT NULL,
    [SFDCOrderNumber]                NVARCHAR (80)   NULL,
    [IDSOrderNumber]                 NVARCHAR (255)  NULL,
    [TreatmentCategory]              NVARCHAR (255)  NULL,
    [CurrentOrderStatus]             NVARCHAR (100)  NULL,
    [CurrentOrderStatusDateTime_UTC] DATETIME        NULL,
    [ProductType]                    NVARCHAR (1300) NULL,
    [SourceSystem]                   VARCHAR (25)    NOT NULL,
    [EECDDate]                       DATETIME2 (7)   NULL,
    [CCDDate]                        DATETIME2 (7)   NULL,
    [IsCurrent]                      BIGINT          NULL
)
WITH (HEAP, DISTRIBUTION = HASH([SAPOrdernumber]));

