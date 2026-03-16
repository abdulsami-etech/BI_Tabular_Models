create table SrcAvro.LeadWebApp
(
	LZBatchID int not null,
	ADLSBatchID int not null,
	ADLSTimestamp datetime2(0) not null,
	SequenceNumber bigint not null,
	Partition int not null,
	BlobName varchar(250) not null,
	Offset varchar(50),
	EnqueuedTimeUtc varchar(50),
	event_name varchar(250) not null,
	event_category varchar(50),
	event_action varchar(50),
	clin_id varchar(50),
	lead_id varchar(50),
	status varchar(50),
	app_name varchar(50),
	app_version varchar(50),
	api_type varchar(50),
	country_code varchar(50),
	created_at varchar(50),
	patient_id varchar(50)
)WITH
(
	DISTRIBUTION = hash(SequenceNumber),
	clustered index(SequenceNumber,Partition)
)

