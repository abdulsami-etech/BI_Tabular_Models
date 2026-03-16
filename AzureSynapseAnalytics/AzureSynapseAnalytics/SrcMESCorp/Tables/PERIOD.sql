CREATE TABLE [SrcMESCorp].[PERIOD] (
    [LZBatchID]           INT           NOT NULL,
    [ADLSBatchID]         INT           NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0) NOT NULL,
    [PeriodID]            INT           NOT NULL,
    [PeriodDate]          DATETIME      NULL,
    [PeriodDateEnd]       DATETIME      NULL,
    [PeriodWeek]          INT           NULL,
    [PeriodWeekStart]     DATETIME      NULL,
    [PeriodWeekEnd]       DATETIME      NULL,
    [PeriodMonth]         INT           NULL,
    [PeriodMonthStart]    DATETIME      NULL,
    [PeriodMonthEnd]      DATETIME      NULL,
    [PeriodQuarter]       INT           NULL,
    [PeriodQuarterStart]  DATETIME      NULL,
    [PeriodQuarterEnd]    DATETIME      NULL,
    [PeriodYear]          INT           NULL,
    [PeriodYearStart]     DATETIME      NULL,
    [PeriodYearEnd]       DATETIME      NULL,
    [PeriodDayOfYear]     INT           NULL,
    [PeriodFiscalMonth]   INT           NULL,
    [PeriodFiscalQuarter] INT           NULL,
    [PeriodFiscalYear]    INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

