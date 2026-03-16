CREATE TABLE [DWSAP].[ConfigCOPATransformations] (
    [Value_Field]      NVARCHAR (40) NULL,
    [Sign_Flip]        NVARCHAR (20) NULL,
    [Date_Period]      NVARCHAR (20) NULL,
    [Date_From]        NVARCHAR (30) NULL,
    [Date_To]          NVARCHAR (30) NULL,
    [Value_Field_Type] NVARCHAR (20) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = REPLICATE);

