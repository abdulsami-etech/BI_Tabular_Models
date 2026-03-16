CREATE TABLE [Custom].[MMD_NABDandSalesIndex] (
    [Year]                                      INT            NOT NULL,
    [Quarter]                                   NVARCHAR (2)   NOT NULL,
    [DateKey]                                   DATE           NOT NULL,
    [WeekDay]                                   NVARCHAR (25)  NULL,
    [USHoliday]                                 NVARCHAR (255) NULL,
    [WeekNumber]                                NVARCHAR (25)  NULL,
    [IsBusinessDay]                             INT            NULL,
    [Cumulative_BD]                             INT            NULL,
    [Historical_BD]                             FLOAT (53)     NULL,
    [Adjust]                                    FLOAT (53)     NULL,
    [Percent_Complete_Net_Receipt]              FLOAT (53)     NULL,
    [Percent_Complete_CCA]                      FLOAT (53)     NULL,
    [Adjust_SemiAnnual]                         FLOAT (53)     NULL,
    [Percent_Complete_NetReceipts_SemiAnnual]   FLOAT (53)     NULL,
    [Percent_Complete_CCA_SemiAnnual]           FLOAT (53)     NULL,
    [Percent_Complete_Gross_Receipt]            FLOAT (53)     NULL,
    [Percent_Complete_GrossReceipts_SemiAnnual] FLOAT (53)     NULL,
    CONSTRAINT [PK_NABDandSalesIndex] PRIMARY KEY NONCLUSTERED ([DateKey] ASC) NOT ENFORCED
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

