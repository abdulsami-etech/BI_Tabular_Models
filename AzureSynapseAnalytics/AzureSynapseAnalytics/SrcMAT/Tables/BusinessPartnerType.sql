CREATE TABLE [SrcMAT].[BusinessPartnerType] (
    [LZBatchID]                             INT            NOT NULL,
    [ADLSBatchID]                           INT            NOT NULL,
    [ADLSTimestamp]                         DATETIME2 (0)  NOT NULL,
    [BusinessPartnerTypeID]                 SMALLINT       NOT NULL,
    [BusinessPartnerTypeGenericDescription] VARCHAR (50)   NOT NULL,
    [ExtendedAttributesMainTable]           NVARCHAR (128) NOT NULL,
    [Notes]                                 VARCHAR (MAX)  NOT NULL,
    [DisplayOrder]                          INT            NOT NULL,
    [IsGroupHeader]                         BIT            NOT NULL,
    [BusinessPartnerTypeGroupID]            SMALLINT       NOT NULL,
    [BusinessPartnerTypeGroupOverrideID]    SMALLINT       NOT NULL,
    [ResourceTypeID]                        SMALLINT       NOT NULL,
    [RowStatusID]                           TINYINT        NOT NULL,
    [DateCreated]                           DATETIME       NOT NULL,
    [CreatedByUserID]                       INT            NOT NULL,
    [DateUpdated]                           DATETIME       NOT NULL,
    [UpdatedByUserID]                       INT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

