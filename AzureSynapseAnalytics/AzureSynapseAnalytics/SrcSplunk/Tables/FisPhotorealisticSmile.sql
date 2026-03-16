create table SrcSplunk.FisPhotorealisticSmile
(
    LZBatchID     int          not null,
    ADLSBatchID   int          not null,
    ADLSTimestamp datetime2(0) not null,
    id            varchar(36)  not null,
    _time         datetimeoffset,
    vpi_md5       varchar(32),
    vpi_sha256    varchar(64),
    response      varchar(32),
    region        varchar(32)
)
WITH (CLUSTERED INDEX(id), DISTRIBUTION = HASH(vpi_md5));