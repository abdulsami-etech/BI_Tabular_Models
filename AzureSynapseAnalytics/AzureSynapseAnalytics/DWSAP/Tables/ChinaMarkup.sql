CREATE TABLE [DWSAP].[ChinaMarkup]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NULL,
	[Sales Order] [nvarchar](100) NULL,
	[Production Order] [nvarchar](100) NULL,
	[Company Code] [nvarchar](100) NULL,
	[Plant] [nvarchar](100) NULL,
	[Fiscal Year] [nvarchar](100) NULL,
	[Period] [nvarchar](100) NULL,
	[GL Account] [nvarchar](100) NULL,
	[Category] [nvarchar](100) NULL,
	[FI Document No.] [nvarchar](100) NULL,
	[FI Doc. Line Item] [nvarchar](100) NULL,
	[Amount in Document Currency] [decimal](15, 3) NULL,
	[Document Currency] [nvarchar](100) NULL,
	[Amount in Local Currency] [decimal](15, 3) NULL,
	[Local Currency] [nvarchar](100) NULL,
	[Amount in Local Currency2] [decimal](15, 3) NULL,
	[Local Currency2] [nvarchar](100) NULL,
	[Material] [nvarchar](100) NULL,
	[Units] [nvarchar](100) NULL,
	[UoM] [nvarchar](100) NULL,
	[Profit Center] [nvarchar](100) NULL,
	[Material Doc No] [nvarchar](100) NULL,
	[Storage Location] [nvarchar](100) NULL,
	[Movement Type] [nvarchar](100) NULL,
	[Material in local curr] [decimal](15, 3) NULL,
	[Labor in local curr] [decimal](15, 3) NULL,
	[Over Head in local curr] [decimal](15, 3) NULL,
	[Freight in local curr] [decimal](15, 3) NULL,
	[Base Cost in local curr] [decimal](15, 3) NULL,
	[Mark Up in local curr] [decimal](30, 3) NULL,
	[Variance in Local Currency] [int] NULL,
	[Material in USD] [decimal](15, 3) NULL,
	[Labor in USD] [decimal](30, 3) NULL,
	[Over Head in USD] [decimal](30, 3) NULL,
	[Freight in USD] [decimal](30, 3) NULL,
	[Base Cost in USD] [decimal](15, 3) NULL,
	[Mark-up in USD] [decimal](30, 3) NULL,
	[Variance in USD] [int] NULL,
	[COPA Reporting Channel] [nvarchar](100) NULL,
	[COPA Profit center] [nvarchar](100) NULL,
	[COPA Product Hierarchy] [nvarchar](100) NULL,
	[COPA Item Category] [nvarchar](100) NULL,
	[Insert_Date] [date] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)



