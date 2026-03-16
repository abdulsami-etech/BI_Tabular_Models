CREATE TABLE [SrcSAP].[KONH] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [MANDT]         NVARCHAR (3)   NOT NULL,
    [KNUMH]         NVARCHAR (10)  NOT NULL,
    [ERNAM]         NVARCHAR (12)  NOT NULL,
    [ERDAT]         NVARCHAR (8)   NOT NULL,
    [KVEWE]         NVARCHAR (1)   NOT NULL,
    [KOTABNR]       NVARCHAR (3)   NOT NULL,
    [KAPPL]         NVARCHAR (2)   NOT NULL,
    [KSCHL]         NVARCHAR (4)   NOT NULL,
    [VAKEY]         NVARCHAR (100) NOT NULL,
    [DATAB]         NVARCHAR (8)   NOT NULL,
    [DATBI]         NVARCHAR (8)   NOT NULL,
    [KOSRT]         NVARCHAR (10)  NOT NULL,
    [KZUST]         NVARCHAR (3)   NOT NULL,
    [KNUMA_PI]      NVARCHAR (10)  NOT NULL,
    [KNUMA_AG]      NVARCHAR (10)  NOT NULL,
    [KNUMA_SQ]      NVARCHAR (10)  NOT NULL,
    [KNUMA_SD]      NVARCHAR (10)  NOT NULL,
    [AKTNR]         NVARCHAR (10)  NOT NULL,
    [KNUMA_BO]      NVARCHAR (10)  NOT NULL,
    [LICNO]         NVARCHAR (20)  NOT NULL,
    [LICDT]         NVARCHAR (8)   NOT NULL,
    [VADAT]         NVARCHAR (100) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([KNUMH]));

