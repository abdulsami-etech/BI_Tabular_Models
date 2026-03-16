CREATE TABLE [SrcWorkday].[SalesRoster] (
    [LZBatchID]                        INT            NOT NULL,
    [ADLSBatchID]                      INT            NOT NULL,
    [ADLSTimestamp]                    DATETIME2 (0)  NULL,
    [Public_Work_Mobile_Phones]        NVARCHAR (MAX) NULL,
    [Primary_Home_Address_State]       NVARCHAR (MAX) NULL,
    [Primary_Home_Address_City]        NVARCHAR (MAX) NULL,
    [Primary_Home_Address_Country]     NVARCHAR (MAX) NULL,
    [Employee_ID]                      NVARCHAR (MAX) NULL,
    [Worker]                           NVARCHAR (MAX) NULL,
    [location]                         NVARCHAR (MAX) NULL,
    [Worker_s_Manager]                 NVARCHAR (MAX) NULL,
    [Hire_Date]                        NVARCHAR (MAX) NULL,
    [Primary_Home_Address_Postal_Code] NVARCHAR (MAX) NULL,
    [primaryWorkEmail]                 NVARCHAR (MAX) NULL,
    [Primary_Home_Address]             NVARCHAR (MAX) NULL,
    [rownum]                           NVARCHAR (MAX) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

