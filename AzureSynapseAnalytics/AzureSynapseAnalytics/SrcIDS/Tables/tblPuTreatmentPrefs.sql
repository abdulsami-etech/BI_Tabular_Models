CREATE TABLE [SrcIDS].[tblPuTreatmentPrefs]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[master_user_id] [int] NOT NULL,
	[treatment_pref_id] [int] NOT NULL,
	[create_date] [datetime2](7) NOT NULL,
	[modified_date] [datetime2](7) NULL,
	[ToothNumberingSystem] [varchar](16) NULL,
	[PassiveAligners] [varchar](40) NULL,
	[IPROnFirstClinCheck] [varchar](8) NULL,
	[DelayStageToStartIPR] [varchar](64) NULL,
	[DelayAttachmentPlacement] [varchar](64) NULL,
	[DelayStageOfExtraction] [varchar](64) NULL,
	[PonticsForOpenSpaces] [varchar](64) NULL,
	[ArchExpansion] [varchar](64) NULL,
	[ExpansionPerQuadrant] [varchar](32) NULL,
	[ToothSizeDiscrepancy] [varchar](64) NULL,
	[Leveling] [varchar](64) NULL,
	[ApplyVirtualCChainMethod] [varchar](8) NULL,
	[TerminalMolarDistortion] [varchar](64) NULL,
	[OptimizedAttachmentSizeAnterior] [varchar](64) NULL,
	[OptimizedAttachmentSizePosterior] [varchar](64) NULL,
	[OptimizedAttachmentVsPrecisionCut] [varchar](64) NULL,
	[StageToStartPrecisionCuts] [varchar](64) NULL,
	[AlignerTrimming] [varchar](64) NULL,
	[SpecialInstructions] [nvarchar](4000) NULL,
	[SpecialInstructionsLength] [int] NULL,
    [_Region] [varchar](32) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [master_user_id] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO

