CREATE TABLE [DW].[FactSagaEnrollment] (
    [LZBatchID]                          INT             NOT NULL,
    [ADLSBatchID]                        INT             NOT NULL,
    [ADLSTimestamp]                      DATETIME2 (0)   NOT NULL,
    [DWBatchID]                          INT             NOT NULL,
    [DWHash]                             CHAR (40)       NULL,
    [ID]                                 NCHAR (18)      NOT NULL,
    [SKAccountSoldTo]                    INT             NULL,
    [SoldToAccountNumber]                NVARCHAR (40)   NULL,
    [ContractNumber]                     NVARCHAR (255)  NULL,
    [IsActive]                           BIT             NULL,
    [CreatedDate]                        DATETIME2 (7)   NOT NULL,
    [StartDate]                          DATETIME2 (7)   NULL,
    [EligibilityStartDate]               DATETIME2 (7)   NULL,
    [EndDate]                            DATETIME2 (7)   NULL,
    [EnrollmentType]                     NVARCHAR (255)  NULL,
    [PreEnrollmentAllowed]               VARCHAR (5)     NULL,
    [AllowableAligners]                  DECIMAL (18)    NULL,
    [AlignersUsed]                       DECIMAL (18)    NULL,
    [AlignersLeft]                       DECIMAL (18, 2) NULL,
    [AccountPricingGroupTreatLocCountry] NVARCHAR (1300) NULL,
    [AccountPricingGroupTreatLoc]        NVARCHAR (1300) NULL,
    [SecRegion]                          VARCHAR (10)    NULL,
    [SoldToAccountType]                  NVARCHAR (40)   NULL,
    [SoldToAccountSubType]               NVARCHAR (255)  NULL,
    CONSTRAINT [PK_FactSagaEnrollment] PRIMARY KEY NONCLUSTERED ([ID] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

