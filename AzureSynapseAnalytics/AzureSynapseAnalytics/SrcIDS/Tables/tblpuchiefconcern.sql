CREATE TABLE [SrcIDS].[tblpuchiefconcern]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[vip_patient_id] [int] NOT NULL,
	[crowding] [bit] NULL,
	[spacing] [bit] NULL,
	[class_1] [bit] NULL,
	[class_2] [bit] NULL,
	[class_3] [bit] NULL,
	[open_bite] [bit] NULL,
	[deep_bite] [bit] NULL,
	[anterior_crossbite] [bit] NULL,
	[posterior_crossbite] [bit] NULL,
	[narrow_arch] [bit] NULL,
	[flared_teeth] [bit] NULL,
	[overjet] [bit] NULL,
	[uneven_smile] [bit] NULL,
	[misshapen_teeth] [bit] NULL,
	[other] [bit] NULL,
	[other_concern] [varchar](256) NULL,
	[other_concern_internal] [varchar](256) NULL,
    [_Region] [varchar] (32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [vip_patient_id] ),
	CLUSTERED COLUMNSTORE INDEX
);


