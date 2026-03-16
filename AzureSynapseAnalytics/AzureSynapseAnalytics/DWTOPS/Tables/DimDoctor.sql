CREATE TABLE [DWTOPS].[DimDoctor] (
    [SKDoctor]                  INT            NOT NULL,
    [ADLSBatchID]               INT            NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0)  NOT NULL,
    [LZBatchID]                 INT            NOT NULL,
    [DWBatchID]                 INT            NOT NULL,
    [DWHash]                    CHAR (40)      NOT NULL,
    [KeyDoctor]                 NVARCHAR (80)  NOT NULL,
    [ClinicianID]               NVARCHAR (50)  NULL,
    [DoctorFirstName]           NVARCHAR (50)  NULL,
    [DoctorLastName]            NVARCHAR (50)  NULL,
    [DoctorFullName]            NVARCHAR (101) NULL,
    [DoctorSource]              VARCHAR (80)   NULL,
    [DoctorCertLevel]           INT            NULL,
    [DoctorCalculatedLevel]     INT            NULL,
    [DoctorCalculatedLevelFlag] VARCHAR (30)   NULL,
    [DoctorJDETeam]             INT            NULL,
    [DoctorSkillLevel]          INT            NULL,
    [DoctorRegionMES]           NVARCHAR (100) NULL,
    [SKCountry]                 INT            NULL
)
WITH (CLUSTERED INDEX([SKDoctor]), DISTRIBUTION = REPLICATE);

