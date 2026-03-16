CREATE VIEW DWC.DimContactClinicalPreferencesHistory
as
select	hc.SKContact
	,	hc.KeyContact
	,	c.ClinId
	,	c.SecRegion
	,	tp.treatment_pref_id as ClinicalPreferenceId
	,	tp.create_date as DateCreated
	,	tp.ToothNumberingSystem
	,	tp.PassiveAligners
	,	tp.IPROnFirstClinCheck
	,	tp.DelayStageToStartIPR
	,	tp.DelayAttachmentPlacement
	,	tp.DelayStageOfExtraction
	,	tp.PonticsForOpenSpaces
	,	tp.ArchExpansion
	,	tp.ExpansionPerQuadrant
	,	tp.ToothSizeDiscrepancy
	,	tp.Leveling
	,	tp.ApplyVirtualCChainMethod
	,	tp.AlignerTrimming
	,	tp.TerminalMolarDistortion
	,	tp.OptimizedAttachmentSizeAnterior
	,	tp.OptimizedAttachmentSizePosterior
	,	tp.OptimizedAttachmentVsPrecisionCut
	,	try_convert(int, tp.StageToStartPrecisionCuts) as StageToStartPrecisionCuts
	,	tp.SpecialInstructions
	,	tp.SpecialInstructionsLength
from SrcIDS.tblPuTreatmentPrefs tp
inner join SrcIDS.tblCnAccounts a on a.master_user_id = tp.master_user_id
inner join DW.HubContact hc on hc.KeyContact = a.contact_sfid
inner join DW.DimContact c on c.SKContact = hc.SKContact
inner join DWGlobal.GeographyRegion gr on gr.RegionGroup = c.SecRegion
										and gr.dataset = 'DWC'
