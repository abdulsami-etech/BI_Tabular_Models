CREATE TABLE [SrcMAT].[BusinessPartner] (
    [LZBatchID]                       INT            NOT NULL,
    [ADLSBatchID]                     INT            NOT NULL,
    [ADLSTimestamp]                   DATETIME2 (0)  NOT NULL,
    [BusinessPartnerID]               INT            NOT NULL,
    [Notes]                           NVARCHAR (MAX) NOT NULL,
    [LocaleID]                        SMALLINT       NOT NULL,
    [ContactBusinessPartnerLinkID]    INT            NOT NULL,
    [PrimaryEmailLinkID]              INT            NULL,
    [PrimaryPhoneLinkID]              INT            NULL,
    [PrimaryAddressLinkID]            INT            NULL,
    [WebSite]                         NVARCHAR (100) NOT NULL,
    [WorkingHours]                    NVARCHAR (200) NOT NULL,
    [PrimaryAddressCountryID]         SMALLINT       NULL,
    [PrimaryAddressCountryCodeAlpha2] CHAR (2)       NULL,
    [BusinessPartnerHostCode]         VARCHAR (16)   NULL,
    [RowStatusID]                     TINYINT        NOT NULL,
    [DateCreated]                     DATETIME       NOT NULL,
    [CreatedByUserID]                 INT            NOT NULL,
    [DateUpdated]                     DATETIME       NOT NULL,
    [UpdatedByUserID]                 INT            NOT NULL,
    [BusinessPartnerTypeNames]        NVARCHAR (500) NOT NULL,
    [BusinessPartnerName1]            NVARCHAR (35)  NOT NULL,
    [BusinessPartnerName2]            NVARCHAR (35)  NOT NULL,
    [BusinessPartnerName]             NVARCHAR (71)  NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

