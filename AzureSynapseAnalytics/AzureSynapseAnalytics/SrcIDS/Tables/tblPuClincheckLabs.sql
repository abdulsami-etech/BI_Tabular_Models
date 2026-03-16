CREATE TABLE [SrcIDS].[tblPuClincheckLabs] (
    [LZBatchID]                INT            NOT NULL,
    [ADLSBatchID]              INT            NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)  NOT NULL,
    [id]                       BIGINT         NOT NULL,
    [name]                     NVARCHAR (100) NOT NULL,
    [email]                    NVARCHAR (100) NOT NULL,
    [phone_number]             NVARCHAR (100) NULL,
    [contact_name]             NVARCHAR (100) NOT NULL,
    [address_line1]            NVARCHAR (100) NOT NULL,
    [address_line2]            NVARCHAR (100) NULL,
    [city]                     NVARCHAR (100) NOT NULL,
    [state]                    NVARCHAR (100) NULL,
    [country]                  NVARCHAR (100) NOT NULL,
    [postal_code]              NVARCHAR (100) NOT NULL,
    [lab_type]                 INT            NOT NULL,
    [is_active]                BIT            NOT NULL,
    [last_active_changed_date] DATETIME2 (7)  NULL,
    [_Region]                  VARCHAR (32)   NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

