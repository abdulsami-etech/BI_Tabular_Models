CREATE TABLE [DW].[CaseStateAlertConfig] (
    [SourceSystem]         NVARCHAR (25)  NULL,
    [OperationName]        NVARCHAR (200) NULL,
    [Plant]                VARCHAR (50)   NULL,
    [PercentageThreshhold] INT            NULL,
    [RecordsThreshhold]    INT            NULL,
    [Email]                NVARCHAR (500) NULL,
    [IsActive]             INT            NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

