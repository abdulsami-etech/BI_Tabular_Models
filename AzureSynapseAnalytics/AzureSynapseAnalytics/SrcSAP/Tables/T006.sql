CREATE TABLE [SrcSAP].[T006]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[MANDT] [nvarchar](20) NULL,
	[MSEHI] [nvarchar](40) NULL,
	[KZEX3] [nvarchar](40) NULL,
	[KZEX6] [nvarchar](40) NULL,
	[ANDEC] [nvarchar](40) NULL,
	[KZKEH] [nvarchar](40) NULL,
	[KZWOB] [nvarchar](40) NULL,
	[KZ1EH] [nvarchar](40) NULL,
	[KZ2EH] [nvarchar](40) NULL,
	[DIMID] [nvarchar](40) NOT NULL,
	[ZAEHL] [nvarchar](40) NULL,
	[NENNR] [nvarchar](40) NULL,
	[EXP10] [nvarchar](40) NULL,
	[ADDKO] [decimal](20, 8) NULL,
	[EXPON] [nvarchar](40) NULL,
	[DECAN] [nvarchar](40) NULL,
	[ISOCODE] [nvarchar](40) NULL,
	[PRIMARY] [nvarchar](40) NULL,
	[TEMP_VALUE] [nvarchar](40) NULL,
	[TEMP_UNIT] [nvarchar](40) NULL,
	[FAMUNIT] [nvarchar](40) NULL,
	[PRESS_VAL] [nvarchar](40) NULL,
	[PRESS_UNIT] [nvarchar](40) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [DIMID] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


