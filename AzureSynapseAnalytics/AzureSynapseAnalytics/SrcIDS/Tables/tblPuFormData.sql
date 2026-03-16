CREATE TABLE [SrcIDS].[tblPuFormData] (
    [LZBatchID]                        INT           NOT NULL,
    [ADLSBatchID]                      INT           NOT NULL,
    [ADLSTimestamp]                    DATETIME2 (0) NOT NULL,
    [rx_form_id]                       INT           NOT NULL,
    [39bbdffce86a27e2c266487ff2c0325e] INT           NULL,
    [48d9a451cd768c96ef0efb480c37cd80] INT           NULL,
    [b372657b264dd0ad13d90ce9b0aa5553] SMALLINT      NULL,
    [fc85aa6a593635375540afcadde330bc] NVARCHAR (50) NULL,
    [7dc8a6355722a0bdc6767aa59c7acdc3] INT           NULL,
    [310d814d4e16c5954a468dbc43966541] INT           NULL,
    [5ddcf65377d65d13edb62389605352ce] INT           NULL,
    [fdaaaf16139c2cf87e296c582e33f28b] INT           NULL,
    [id]                               INT           NULL,
    [_Region]                          VARCHAR (32)  NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([rx_form_id]));

