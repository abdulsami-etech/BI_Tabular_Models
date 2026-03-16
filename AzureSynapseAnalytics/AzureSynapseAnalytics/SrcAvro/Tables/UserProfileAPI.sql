create table SrcAvro.UserProfileApi
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
	uuid varchar(50),
	lead_id varchar(50),
	device varchar(255),
	clin_id varchar(50),
	user_type varchar(50),
	mailing_country nvarchar(50),
	remote_care_invite_status varchar(50),
	remote_care_accept_terms varchar(50),
	app_name varchar(50) not null,
	app_version varchar(50),
	api_type varchar(50),
	created_date varchar(50),
	updated_date varchar(50),
	is_app_user bit,
	is_demo bit,
	country varchar(100),
	product_name varchar(100),
	treatment_start_date varchar(30),
	number_lower_aligners varchar(10),
	vip_patient_id_md5 varchar(32),
	vip_patient_id_sha256 varchar(64)
)
WITH
(
	DISTRIBUTION = hash(uuid),
	clustered index(SequenceNumber,Partition)
)
