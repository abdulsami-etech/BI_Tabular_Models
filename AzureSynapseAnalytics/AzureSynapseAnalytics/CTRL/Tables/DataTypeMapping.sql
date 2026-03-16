CREATE TABLE [CTRL].[DataTypeMapping](
	[ADFDataType] [varchar](64) NOT NULL,
	[SQLDataType] [varchar](64) NOT NULL
 
)WITH (HEAP, DISTRIBUTION = ROUND_ROBIN)