CREATE VIEW DWC.DimContactClinicalPreferences
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
	,	tp.AlignerTrimming
	,	tp.ApplyVirtualCChainMethod
	,	tp.TerminalMolarDistortion
	,	tp.OptimizedAttachmentSizeAnterior
	,	tp.OptimizedAttachmentSizePosterior
	,	tp.OptimizedAttachmentVsPrecisionCut
	,	try_convert(int, tp.StageToStartPrecisionCuts) as StageToStartPrecisionCuts
	,	tp.SpecialInstructions
	,	tp.SpecialInstructionsLength
from (
	select	master_user_id
		,	max(treatment_pref_id) as treatment_pref_id
	from SrcIDS.tblPuTreatmentPrefs
	group by master_user_id
) cur
inner join SrcIDS.tblPuTreatmentPrefs tp on tp.master_user_id = cur.master_user_id
										and tp.treatment_pref_id = cur.treatment_pref_id
inner join SrcIDS.tblCnAccounts a on a.master_user_id = tp.master_user_id
inner join DW.HubContact hc on hc.KeyContact = a.contact_sfid
inner join DW.DimContact c on c.SKContact = hc.SKContact
inner join DWGlobal.GeographyRegion gr on gr.RegionGroup = c.SecRegion
										and gr.dataset = 'DWC'
