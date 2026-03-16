CREATE TABLE [SrcSAP].[ZRTR_BKPF_BSEG1_ParquetLoad]
(
	[MANDT] [nvarchar](25) NULL,
	[BUKRS] [nvarchar](25) NOT NULL,
	[BELNR] [nvarchar](40) NOT NULL,
	[MATNR] [nvarchar](30) NULL,
	[WERKS] [nvarchar](25) NULL,
	[GJAHR] [nvarchar](25) NOT NULL,
	[BUZEI] [nvarchar](25) NOT NULL,
	[BUDAT] [nvarchar](25) NULL,
	[CPUDT] [nvarchar](25) NULL,
	[DMBTR] [decimal](13, 2) NULL,
	[DMBE2] [decimal](13, 2) NULL,
	[MEINS] [nvarchar](25) NULL,
	[GSBER] [nvarchar](25) NULL,
	[KOKRS] [nvarchar](25) NULL,
	[KOSTL] [nvarchar](25) NULL,
	[KUNNR] [nvarchar](25) NULL,
	[SHKZG] [nvarchar](25) NULL,
	[VBEL2] [nvarchar](25) NULL,
	[HKONT] [nvarchar](25) NULL,
	[LIFNR] [nvarchar](20) NULL,
	[AWKEY] [nvarchar](40) NULL,
	[AWTYP] [nvarchar](25) NULL,
	[PSWSL] [nvarchar](25) NULL,
	[KOART] [nvarchar](25) NULL,
	[WRBTR] [decimal](13, 2) NULL,
	[PSWBT] [decimal](13, 2) NULL,
	[HWAE2] [nvarchar](25) NULL,
	[UPDDT] [nvarchar](20) NULL,
	[AEDAT] [nvarchar](20) NULL,
	[KURSF] [decimal](13, 2) NULL,
	[CURT2] [nvarchar](10) NULL,
	[POSN2] [nvarchar](10) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)




