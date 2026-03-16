CREATE TABLE [SrcMESCorp].[Conf_ReasonCodes] (
    [ReasonCodeID]   INT           NOT NULL,
    [CompleteReason] VARCHAR (50)  NOT NULL,
    [ReasonType]     VARCHAR (50)  NULL,
    [Start_Oper]     VARCHAR (100) NULL,
    [End_Oper]       VARCHAR (100) NULL,
    [ReasonDesc]     VARCHAR (250) NULL,
    [IsActive]       BIT           NULL,
    [RouteName]      VARCHAR (200) NULL,
    [ArcName]        VARCHAR (50)  NULL,
    [ReportType]     VARCHAR (50)  NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

