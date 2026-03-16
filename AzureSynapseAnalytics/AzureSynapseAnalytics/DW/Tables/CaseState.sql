CREATE TABLE [DW].[CaseState] (
    [DWBatchID]                      INT            NOT NULL,
    [ClinID]                         NVARCHAR (80)  NULL,
    [DID]                            NVARCHAR (80)  NULL,
    [TreatmentID]                    NVARCHAR (15)  NULL,
    [SAPOrderNumber]                 NVARCHAR (64)  NOT NULL,
    [SFDCOrderNumber]                NVARCHAR (64)  NULL,
    [IDSOrderNumber]                 NVARCHAR (80)  NULL,
    [TreatmentCategory]              NVARCHAR (225) NULL,
    [CurrentOrderStatus]             NVARCHAR (64)  NULL,
    [CurrentOrderStatusDateTime_UTC] DATETIME       NULL,
    [ProductType]                    NVARCHAR (225) NULL,
    [SourceSystem]                   VARCHAR (25)   NOT NULL,
    [EECDDate]                       DATETIME       NULL,
    [CCDDate]                        DATETIME2 (7)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SAPOrderNumber]));


GO
CREATE NONCLUSTERED INDEX [IX_CaseState_DWBatchID]
    ON [DW].[CaseState]([DWBatchID] ASC);

