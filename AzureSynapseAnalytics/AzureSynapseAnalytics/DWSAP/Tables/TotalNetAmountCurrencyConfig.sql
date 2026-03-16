CREATE TABLE [DWSAP].[TotalNetAmountCurrencyConfig]
(
	[Total Net Amount Unit/Currency] [varchar](3) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)