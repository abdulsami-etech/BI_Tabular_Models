CREATE TABLE [DW].[DimCurrency]
(
    [CurrencyCode] [char](3) NOT NULL,
	[CurrencyName] [nvarchar](25) NOT NULL,
	[CurrencyISOCode] [nchar](3) NOT NULL,
	[MinorUnit] [tinyint] NULL,
	[CurrencySymbol] [nvarchar](5) NULL,
	[CurrencySortKey] [smallint] NULL,
	[CurrencyLanguage] [smallint] NULL,
	[Multiplier] [int] NULL
)
WITH
(
    DISTRIBUTION = HASH ([CurrencyCode]),
    CLUSTERED COLUMNSTORE INDEX
)
