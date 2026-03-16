CREATE TABLE [DWMyInvisalignApp].[SatAPIUser] (
    [SKAPIUser]        INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [LZBatchID]     INT            NOT NULL,
    [DWBatchID]     INT            NOT NULL,
    [DWHash]        CHAR (40)      NOT NULL,
	lead_id         varchar(50),
	SKContact       int,
	clin_id         varchar(50),
	user_type       varchar(50),
	mailing_country nvarchar(50),
	remote_care_invite_status varchar(50),
	remote_care_accept_terms varchar(50),
	created_date    datetime,
	updated_date    datetime,
	is_app_user     bit,
	is_demo         bit,
	InitialUserType varchar(50),
	ConvertedToProspect datetime,
	ConvertedToPatient	datetime,
	SKGeography			INT
)
WITH (CLUSTERED INDEX([SKAPIUser]), DISTRIBUTION = HASH(SKAPIUser));