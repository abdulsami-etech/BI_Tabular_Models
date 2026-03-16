CREATE PROC [DW].[LoadDimOrderIDS] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted			int = 0
		,	@RowsUpdated			int = 0
		,	@IsFullLoad				bit = 0
		,	@IsMainTableFullLoad	bit = 0
		,	@SQL					varchar(max)

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if not exists (select * from DW.DimOrderIDS)
		set @IsFullLoad = 1

	--if @IsFullLoad = 1 or not exists (select * from DW.DimOrder where DWHashIDS is not null)
	--	set @IsMainTableFullLoad = 1

	if object_id('DW.Temp_DimOrderIDS') is not null
		drop table DW.Temp_DimOrderIDS

	set @SQL = 'create table DW.Temp_DimOrderIDS
	(
		SKOrder								bigint		NOT NULL,
	
		ADLSBatchID							int			NOT NULL,
		ADLSTimestamp						datetime2(0) NOT NULL,
		LZBatchID							int			NOT NULL,
		DWBatchID							int			NOT NULL,
		DWHash								char(40)	NOT NULL,
		DWHashMainSubset					char(40)		NULL,
		
		KeyOrder							bigint		NOT NULL,
		IDSOrderNumber						bigint		NOT NULL,
		SKContact							int			NOT NULL,
		OrderType varchar(40) null,
		DeliverableType	varchar(40) null,
		TreatmentCategory varchar(40) null,
		TreatmentType varchar(40) null,
		PatientCurrentStageLowerArch int NULL,
		PatientCurrentStageUpperArch int NULL,
		LastStaffDiscountUtilizedDate datetime2(7) NULL,
		CancelReasonCode nvarchar(3) NULL,
		TreatedArches int NULL,
		IsIOScan nvarchar(3) NULL,
		ScanType varchar(20) NULL,
		CaseCode nvarchar(50) NULL,
		SubmissionType varchar(6) NULL,
		SubmitDate datetime2(0) NULL,
		AMRDate datetime2(0) NULL,
		FirstCCUDDate datetime2(0) NULL,
		LastCCUDDate datetime2(0) NULL,
		FirstCCAADate datetime2(0) NULL,
		LastCCAADate datetime2(0) NULL,
		FirstCCMODDate datetime2(0) NULL,
		LastCCMODDate datetime2(0) NULL,
		CCADate datetime2(0) NULL,
		ShipmentScheduledDate datetime2(0) NULL,
		ShipmentDate datetime2(0) NULL,
		CancellationDate datetime2(0) NULL,
		FirstMaterialsRequiredDate datetime2(0) NULL,
		LastMaterialsRequiredDate datetime2(0) NULL,
		ClinicalHoldDate datetime2(0) NULL,
		UnknownOrderConvertedDate datetime2(0) NULL,
		ProductSwitchDate datetime2(0) NULL,
		FirstGenerateMTPDate datetime2(0) NULL,
		LastGenerateMTPDate datetime2(0) NULL,
		TreatmentID int NULL,
		EECDDate datetime2(0) NULL,
		ArchConversion varchar(32) NULL,
		PatientVIPID int NULL,
		--PatientBirthDate date NULL,
		PatientGender varchar(7) NULL,
		PatientIsArchived varchar(8) NULL,
		HoldReason nvarchar(256) NULL,
		LoanNumber nvarchar(35) NULL,
		LoanTreatmentFee float NULL,
		LoanApproveAmount float NULL,
		ScanOfficeContactSFID nvarchar(18) NULL,
		SKAccount			  INT			default (-1) NOT NULL,
		SecRegion			  nvarchar(20)	default ('''') NOT NULL,
		ReClinCheckCount int null,
		LastAMRDate datetime2(0) NULL,
		LastCCADate datetime2(0) NULL,
		TreatmentFeature nvarchar(50) NULL,
		OrderCompleteDate date	NULL,
		CCAAAgeing varchar(16) NULL,
		MTP varchar(20) NULL,
		FullOrPartial	varchar(10) NULL,
		_Region	varchar(32) NOT NULL
	)'

	if @IsFullLoad = 0
	begin
		truncate table DW.Temp_OrdersIDSToLoad

		insert into DW.Temp_OrdersIDSToLoad (vip_order_id)
		select vip_order_id
		from SrcIDS.tblPuOrderStatusHistory posh
		where posh.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		union
		select posh.vip_order_id
		from SrcIDS.tblPuOrderStatusHistory posh
		inner join SrcIDS.tblPuFormData d on d.rx_form_id = posh.rx_form_id
											 and d._Region = posh._Region
		where d.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		union
		select tom.vip_order_id
		from SrcIDS.tblPuTreatmentOrderMap tom
		inner join SrcIDS.tblPuTreatmentStatusHistory tsh on tsh.treatment_id = tom.treatment_id
															 and tsh._Region = tom._Region
		where tsh.ADLSTimestamp >= @LastSuccessfullDWTimestamp
		union
		select pom.vip_order_id
		from SrcIDS.tblCnPatientOrderMap pom
		inner join SrcIDS.tblpupatienttransfer pt on pt.vip_patient_id = pom.vip_patient_id
													 and pt._Region = pom._Region
		where pt.transfer_type = 3
			and pt.ADLSTimestamp >= @LastSuccessfullDWTimestamp


		set @SQL += 'with (distribution = round_robin, heap)'
	end 
	else 
	begin
		set @SQL += 'with (distribution = hash(SKOrder), clustered columnstore index)'
	end

	exec (@SQL)
	
	insert into DW.Temp_DimOrderIDS (
			SKOrder
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	DWHashMainSubset
		,	KeyOrder
		,	IDSOrderNumber
		,	SKContact
		,	OrderType
		,	DeliverableType
		,	TreatmentCategory
		,	TreatmentType
		,	PatientCurrentStageLowerArch
		,	PatientCurrentStageUpperArch
		,	LastStaffDiscountUtilizedDate
		,	CancelReasonCode
		,	TreatedArches
		,	IsIOScan
		,	ScanType
		,	CaseCode
		,	SubmissionType
		,	SubmitDate
		,	AMRDate
		,	FirstCCUDDate
		,	LastCCUDDate
		,	FirstCCAADate
		,	LastCCAADate
		,	FirstCCMODDate
		,	LastCCMODDate
		,	CCADate
		,	ShipmentScheduledDate
		,	ShipmentDate
		,	CancellationDate
		,	FirstMaterialsRequiredDate
		,	LastMaterialsRequiredDate
		,	ClinicalHoldDate
		,	UnknownOrderConvertedDate
		,	ProductSwitchDate
		,	FirstGenerateMTPDate
		,	LastGenerateMTPDate
		,	TreatmentID
		,	EECDDate
		,	ArchConversion
		,	PatientVIPID
		--,	PatientBirthDate
		,	PatientGender
		,	PatientIsArchived
		,	HoldReason
		,	LoanNumber
		,	LoanTreatmentFee
		,	LoanApproveAmount
		,	ScanOfficeContactSFID
		,	SKAccount
		,	SecRegion
		,	ReClinCheckCount
		,	LastAMRDate
		,	LastCCADate
		,	TreatmentFeature
		,	OrderCompleteDate 
		,	CCAAAgeing
		,	MTP
		,	FullOrPartial
		,	_Region
	)
	select	SKOrder
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID
		,	DWHash
		,	null as DWHashMainSubset
		,	KeyOrder
		,	IDSOrderNumber
		,	SKContact
		,	OrderType
		,	DeliverableType
		,	TreatmentCategory
		,	TreatmentType
		,	PatientCurrentStageLowerArch
		,	PatientCurrentStageUpperArch
		,	LastStaffDiscountUtilizedDate
		,	CancelReasonCode
		,	TreatedArches
		,	IsIOScan
		,	ScanType
		,	CaseCode
		,	SubmissionType
		,	SubmitDate
		,	AMRDate
		,	FirstCCUDDate
		,	LastCCUDDate
		,	FirstCCAADate
		,	LastCCAADate
		,	FirstCCMODDate
		,	LastCCMODDate
		,	CCADate
		,	ShipmentScheduledDate
		,	ShipmentDate
		,	CancellationDate
		,	FirstMaterialsRequiredDate
		,	LastMaterialsRequiredDate
		,	ClinicalHoldDate
		,	UnknownOrderConvertedDate
		,	ProductSwitchDate
		,	FirstGenerateMTPDate
		,	LastGenerateMTPDate
		,	TreatmentID
		,	EECDDate
		,	ArchConversion
		,	PatientVIPID
		--,	PatientBirthDate
		,	PatientGender
		,	PatientIsArchived
		,	HoldReason
		,	LoanNumber
		,	LoanTreatmentFee
		,	LoanApproveAmount
		,	ScanOfficeContactSFID
		,   ISNULL(SKAccount,-1)
		,	ISNULL(SecRegion,'')
		,	ReClinCheckCount
		,	LastAMRDate
		,	LastCCADate
		,	TreatmentFeature
		,	OrderCompleteDate
		,	CCAAAgeing
		,	MTP
		,	FullOrPartial
		,	_Region
	from (
		select 
		-- top (1) with ties
				ho.SKOrder												as SKOrder
			,	pos.ADLSBatchID											as ADLSBatchID
			,	pos.ADLSTimestamp										as ADLSTimestamp
			,	pos.LZBatchID											as LZBatchID
			,	convert(char(40), '')									as DWHash
			,	pom.jde_order_id										as KeyOrder
			,	pos.vip_order_id										as IDSOrderNumber
			,	isnull(hubCon.SKContact, -1)							as SKContact
			,	ot.OrderType											as OrderType
			,	ot.DeliverableType										as DeliverableType
			,	ot.TreatmentCategory									as TreatmentCategory
			,	tt.TreatmentType										as TreatmentType
			,	d.[39bbdffce86a27e2c266487ff2c0325e]					as PatientCurrentStageLowerArch 
			,	d.[48d9a451cd768c96ef0efb480c37cd80]					as PatientCurrentStageUpperArch 
			,	ud.LastStaffDiscountUtilizedDate						as LastStaffDiscountUtilizedDate
			,	convert(nvarchar(3), posh.cancelled_reason)				as CancelReasonCode
			,	posh.tx_treated_arches									as TreatedArches
			,	osh.IsIOScan											as IsIOScan
			,	osh.ScanType											as ScanType
			,	osh.CaseCode											as CaseCode
			,	osh.SubmissionType										as SubmissionType
			,	convert(datetime2(0), osh.SubmitDate)					as SubmitDate
			,	convert(datetime2(0), osh.AMRDate)						as AMRDate
			,	convert(datetime2(0), osh.FirstCCUDDate)				as FirstCCUDDate
			,	convert(datetime2(0), osh.LastCCUDDate)					as LastCCUDDate
			,	convert(datetime2(0), osh.FirstCCAADate)				as FirstCCAADate
			,	convert(datetime2(0), osh.LastCCAADate)					as LastCCAADate
			,	convert(datetime2(0), osh.FirstCCMODDate)				as FirstCCMODDate
			,	convert(datetime2(0), osh.LastCCMODDate)				as LastCCMODDate
			,	convert(datetime2(0), osh.CCADate)						as CCADate
			,	convert(datetime2(0), osh.ShipmentScheduledDate)		as ShipmentScheduledDate
			,	convert(datetime2(0), osh.ShipmentDate)					as ShipmentDate
			,	convert(datetime2(0), osh.CancellationDate)				as CancellationDate
			,	convert(datetime2(0), osh.FirstMaterialsRequiredDate)	as FirstMaterialsRequiredDate
			,	convert(datetime2(0), osh.LastMaterialsRequiredDate)	as LastMaterialsRequiredDate
			,	convert(datetime2(0), osh.ClinicalHoldDate)				as ClinicalHoldDate
			,	convert(datetime2(0), osh.UnknownOrderConvertedDate)	as UnknownOrderConvertedDate
			,	convert(datetime2(0), osh.ProductSwitchDate)			as ProductSwitchDate
			,	convert(datetime2(0), osh.FirstGenerateMTPDate)			as FirstGenerateMTPDate
			,	convert(datetime2(0), osh.LastGenerateMTPDate)			as LastGenerateMTPDate
			,	ts.treatment_id											as TreatmentID
			,	convert(datetime2(0), tsh.tx_eecd)						as EECDDate
			,	archconv.ArchConversion									as ArchConversion
			,	pom.vip_patient_id										as PatientVIPID
			--,	p.birth_date											as PatientBirthDate
			,	case p.gender
					when '1' then 'Male'
					when '0' then 'Female'
					else null
				end 													as PatientGender
			,	convert(varchar(8),
					case p.archive
						when 1 then 'Yes'
						when 0 then 'No'
						else null 
					end
				)														as PatientIsArchived
			,	hold.HoldReason											as HoldReason
			,	fin.loan_id												as LoanNumber
			,	fin.treatment_fee										as LoanTreatmentFee
			,	fin.approved_loan_amount								as LoanApproveAmount
			,	pt.contact_sfid											as ScanOfficeContactSFID
			,	dwa.SKAccount											as SKAccount
			,	dwa.SecRegion											as SecRegion
			,	osh.ReClinCheckCount									as ReClinCheckCount
			,	osh.LastAMRDate											as LastAMRDate
			,	osh.LastCCADate											as LastCCADate
			,	posh.treatment_feature									as TreatmentFeature
			,	case when posh.event_type = 'OrderComplete' then convert(date, posh.ss_ship_date) end as OrderCompleteDate
			,	ccaa.CCAAAgeing
			,	null as MTP
			,	case when tsh.tx_type_id in (201, 1501, 701, 801) then 'Partial' else 'Full' end as FullOrPartial
			,	pom._Region
		from (
			select	jde_order_id
				,	vip_order_id
				,	vip_patient_id
				,	_Region
			from (
				select	jde_order_id
					,	vip_order_id
					,	vip_patient_id
					,	_Region
					,	row_number() over (partition by jde_order_id order by case when _Region = 'Global' then 1 else 0 end, vip_order_id desc) as rn
				from SrcIDS.tblCnPatientOrderMap
				where jde_order_id > 0
			) pom
			where rn = 1
		) pom
		inner join SrcIDS.tblPuOrderStatus pos on pom.vip_order_id = pos.vip_order_id
												  and pom._Region = pos._Region
		inner join SrcIDS.tblPuOrderStatusHistory posh on posh.order_status_history_id = pos.order_status_history_id
														  and posh._Region = pos._Region
		inner join DW.HubOrder ho on ho.KeyOrder = pom.jde_order_id
		left join Custom.CCAAAgingBuckets ccaa on case when posh.event_type = 'ClinCheckAwaitingApproval' 
													   then datediff(dd, posh.modified_date, getdate()) else 10000 end between ccaa.RangeBegin and ccaa.RangeEnd    
		left join SrcIDS.tblcndoctorpatientmap dpm on dpm.vip_patient_id = pom.vip_patient_id
													  and dpm._Region = pom._Region
		left join SrcIDS.tblCnAccounts acc on acc.master_user_id = dpm.master_user_id
											  and acc._Region = dpm._Region	
		left join DW.DimAccount dwa on dwa.AccountNumber=convert(nvarchar(40),dpm.lid_treat_location)
		left join DW.HubContact hubCon on hubCon.KeyContact = acc.contact_sfid
		left join Custom.IDSOrderType ot on ot.OrderTypeId = posh.vip_order_type
		left join SrcIDS.tblPuFormData d on d.rx_form_id = posh.rx_form_id
											and d._Region = posh._Region
		left join (
			select	rx_form_id
				,	_Region
				,	max(modified_at) as LastStaffDiscountUtilizedDate
			from SrcIDS.tblPuDiscountStatus
			where [status] = 4
				and modified_at is not null
			group by rx_form_id, _Region
		) ud on ud.rx_form_id = posh.rx_form_id
				and ud._Region = posh._Region
		left join (
			select	posh.vip_order_id
				,	posh._Region
				,	case when max(d.b372657b264dd0ad13d90ce9b0aa5553) = 1
						then N'Yes'
						else N'No'
					end as IsIOScan
				,	convert(varchar(20),
						case	when max(d.[7dc8a6355722a0bdc6767aa59c7acdc3]) > 0 
									then 'iTero'
								when max(d.[310d814d4e16c5954a468dbc43966541]) > 0 
									then '3M'
								when max(d.[5ddcf65377d65d13edb62389605352ce]) > 0 
									then 'Sirona'
								when max(d.[fdaaaf16139c2cf87e296c582e33f28b]) > 0 
									then '3Shape'
								else 'PVS' 
						end
					) as ScanType
				,	nullif(max(d.fc85aa6a593635375540afcadde330bc), '') as CaseCode
				,	case when max(case when posh.event_type = 'Paperformsubmitted' then 1 end) = 1 then 'Paper' else 'Online' end as SubmissionType
				,	nullif(min(case when posh.event_type in ('PaperFormSubmitted', 'TreatmentFormSubmitted', 'Orderinitiated', 'RetainerOrderCreated')	then posh.tx_submit_date else '99991231' end), '99991231') as SubmitDate
				,	nullif(min(case when posh.event_type = 'AllMaterialsReceived' then posh.rc_all_materials_received_date else '99991231' end), '99991231') as AMRDate
				,	nullif(min(case when posh.event_type = 'ClinCheckUnderDevelopment' then posh.modified_date else '99991231' end), '99991231') as FirstCCUDDate
				,	max(case when posh.event_type = 'ClinCheckUnderDevelopment' then posh.modified_date end) as LastCCUDDate
				,	nullif(min(case when posh.event_type = 'ClinCheckAwaitingApproval' then posh.modified_date else '99991231' end), '99991231') as FirstCCAADate
				,	max(case when posh.event_type = 'ClinCheckAwaitingApproval' then posh.modified_date end) as LastCCAADate
				,	nullif(min(case when posh.event_type = 'ClinCheckModified' then posh.cc_mod_date else '99991231' end), '99991231') as FirstCCMODDate
				,	max(case when posh.event_type = 'ClinCheckModified' then posh.cc_mod_date end) as LastCCMODDate
				,	nullif(min(case when posh.event_type in ('ClinCheckAccepted', 'ClinCheckAutoAccepted', 'FirstSevenTreatmentPurchased') then posh.cc_accept_date else '99991231' end), '99991231') as CCADate
				,	nullif(min(case when posh.event_type = 'ShipmentScheduled' then posh.promised_ship_date else '99991231' end), '99991231') as ShipmentScheduledDate
				,	nullif(min(case when posh.event_type = 'Shipped' then posh.ss_ship_date else '99991231' end), '99991231') as ShipmentDate
				,	nullif(min(case when posh.event_type = 'OrderCancelled' then posh.cancelled_date else '99991231' end), '99991231') as CancellationDate
				,	nullif(min(case when posh.event_type = 'MaterialsRequired' then posh.hold_date else '99991231' end), '99991231') as FirstMaterialsRequiredDate
				,	max(case when posh.event_type = 'MaterialsRequired' then posh.hold_date end) as LastMaterialsRequiredDate
				,	nullif(min(case when posh.event_type = 'ClinicalHold' then posh.hold_date else '99991231' end), '99991231') as ClinicalHoldDate
				,	nullif(min(case when posh.event_type = 'ConvertOrderfromUnknown' then posh.modified_date else '99991231' end), '99991231') as UnknownOrderConvertedDate
				,	nullif(min(case when posh.event_type = 'OrderChangeSwitch' then posh.modified_date else '99991231' end), '99991231') as ProductSwitchDate
				,	nullif(min(case when posh.event_type = 'GenerateMTP' then posh.modified_date else '99991231' end), '99991231') as FirstGenerateMTPDate
				,	max(case when posh.event_type = 'GenerateMTP' then posh.modified_date end) as LastGenerateMTPDate
				,	sum(case when posh.event_type = 'ClinCheckModified' then 1 end) as ReClinCheckCount

				,	max(case when posh.event_type = 'AllMaterialsReceived' then posh.rc_all_materials_received_date end) as LastAMRDate
				,	max(case when posh.event_type in ('ClinCheckAccepted', 'ClinCheckAutoAccepted', 'FirstSevenTreatmentPurchased') then posh.cc_accept_date end) as LastCCADate
			from SrcIDS.tblPuOrderStatusHistory posh
			left join SrcIDS.tblPuFormData d on d.rx_form_id = posh.rx_form_id
												and d._Region = posh._Region
			where @IsFullLoad = 1		
				or posh.vip_order_id in (select vip_order_id from DW.Temp_OrdersIDSToLoad)
			group by posh.vip_order_id, posh._Region
		) osh on osh.vip_order_id = pos.vip_order_id
				 and osh._Region = pos._Region
		left join SrcIDS.tblPuTreatmentOrderMap tom on tom.vip_order_id = pos.vip_order_id
													   and tom._Region = pos._Region
		left join SrcIDS.tblPuTreatmentStatus ts on ts.treatment_id = tom.treatment_id
													and ts._Region = tom._Region
		left join SrcIDS.tblPuTreatmentStatusHistory tsh on tsh.treatment_status_history_id = ts.treatment_status_history_id
															and tsh._Region = ts._Region
		left join Custom.IDSTreatmentType tt on tt.TreatmentTypeId = tsh.tx_type_id
		left join (
			select	osh1.vip_order_id
				,	osh1._Region
				,	convert(varchar(32),
						case	when max(osh1.tx_treated_arches) < 3 and max(osh2.tx_treated_arches) = 3
									then 'Single to Dual' 
								when max(osh1.tx_treated_arches) = 3 and max(osh2.tx_treated_arches) < 3 
									then 'Dual to Single' 
								else 'No Conversion' 
						end 
				) as ArchConversion
			from SrcIDS.tblPuOrderStatusHistory osh1
			inner join SrcIDS.tblPuOrderStatusHistory osh2 on osh2.vip_order_id = osh1.vip_order_id 
															  and osh2._Region = osh1._Region
			where (@IsFullLoad = 1 or osh1.vip_order_id in (select vip_order_id from DW.Temp_OrdersIDSToLoad))
				and osh1.event_type in ('TreatmentFormSubmitted', 'PaperFormSubmitted', 'AllMaterialsReceived') -- AllMaterialsReceived--paper/tx submitted
				and osh2.event_type = 'OrderComplete'
			group by osh1.vip_order_id, osh1._Region
		) archconv on archconv.vip_order_id = pos.vip_order_id
					  and archconv._Region = pos._Region
		left join SrcIDS.tblCnPatients p on p.vip_patient_id = pom.vip_patient_id
											and p._Region = pom._Region
		left join (
			select	vip_order_id
				,	HoldReason
				,	_Region
			from (
				select	vip_order_id
					,	hold_reason		as HoldReason
					,	_Region
					,	row_number() over (partition by vip_order_id, _Region order by hold_date desc, order_status_history_id desc) as rn
				from SrcIDS.tblPuOrderStatusHistory 
				where (@IsFullLoad = 1 or vip_order_id in (select vip_order_id from DW.Temp_OrdersIDSToLoad))
					and hold_reason is not null
			) t
			where t.rn = 1
		) hold on hold.vip_order_id = pos.vip_order_id
				  and hold._Region = pos._Region
		left join SrcIDS.order_financing fin on fin.vip_order_id = pos.vip_order_id
												and fin._Region = pos._Region
		left join (
			select	vip_patient_id
				,	contact_sfid
				,	_Region
			from (
				select	pt.vip_patient_id
					,	cna.contact_sfid
					,	pt._Region
					,	row_number() over (partition by pt.vip_patient_id, pt._Region order by pt.transfer_id) as rn
				from SrcIDS.tblpupatienttransfer pt
				inner join SrcIDS.tblCnAccounts cna on cna.master_user_id = pt.from_master_user_id 
													   and cna._Region = pt._Region
				where pt.transfer_type = 3
			) t
			where t.rn = 1
		) pt on pt.vip_patient_id = pom.vip_patient_id
				and pt._Region = pom._Region
		where (@IsFullLoad = 1 or pom.vip_order_id in (select vip_order_id from DW.Temp_OrdersIDSToLoad))
		-- order by row_number() over (
			-- partition by pom.jde_order_id 
			-- order by 
				-- case when pos._Region = 'Global' then 1 else 0 end, --first we take a record from NOT the Global region, i.e. from China
				-- pom.vip_order_id desc
		--)
	) t

	union all

	select	-1				as SKOrder
		,	-1				as ADLSBatchID
		,	'19000101'		as ADLSTimestamp
		,	-1				as LZBatchID
		,	@BatchID		as DWBatchID
		,	''				as DWHash
		,	''				as DWHashMainSubset
		,	-1				as KeyOrder
		,	-1				as IDSOrderNumber
		,	-1				as SKContact
		,	null			as OrderType
		,	null			as DeliverableType
		,	null			as TreatmentCategory
		,	null			as TreatmentType
		,	null			as PatientCurrentStageLowerArch
		,	null			as PatientCurrentStageUpperArch
		,	null			as LastStaffDiscountUtilizedDate
		,	null			as CancelReasonCode
		,	null			as TreatedArches
		,	null			as IsIOScan
		,	null			as ScanType
		,	null			as CaseCode
		,	null			as SubmissionType
		,	null			as SubmitDate
		,	null			as AMRDate
		,	null			as FirstCCUDDate
		,	null			as LastCCUDDate
		,	null			as FirstCCAADate
		,	null			as LastCCAADate
		,	null			as FirstCCMODDate
		,	null			as LastCCMODDate
		,	null			as CCADate
		,	null			as ShipmentScheduledDate
		,	null			as ShipmentDate
		,	null			as CancellationDate
		,	null			as FirstMaterialsRequiredDate
		,	null			as LastMaterialsRequiredDate
		,	null			as ClinicalHoldDate
		,	null			as UnknownOrderConvertedDate
		,	null			as ProductSwitchDate
		,	null			as FirstGenerateMTPDate
		,	null			as LastGenerateMTPDate
		,	null			as TreatmentID
		,	null			as EECDDate
		,	null			as ArchConversion
		,	null			as PatientVIPID
		--,	null			as PatientBirthDate
		,	null			as PatientGender
		,	null			as PatientIsArchived
		,	null			as HoldReason
		,	null			as LoanNumber
		,	null			as LoanTreatmentFee
		,	null			as LoanApproveAmount
		,	null			as ScanOfficeContactSFID
		,   -1				as SKAccount
		,   ''				as SecRegion
		,	null			as ReClinCheckCount
		,	null			as LastAMRDate
		,	null			as LastCCADate
		,	null			as TreatmentFeature
		,	null			as OrderCompleteDate
		,   null			as CCAAAgeing
		,	null			as MTP
		,	null			as FullOrPartial
		,	'N/A'			as _Region

		
/*1. MTP Direct to fab*/  
	UPDATE tdoi SET MTP = 'MTP Direct to fab'  
	FROM DW.Temp_DimOrderIDS tdoi  
 -- JOIN DW.DimOrder do on tdo.OrderKey=do.OrderKey   
 INNER JOIN DW.FactVolume fv ON tdoi.KeyOrder = fv.SAPOrderNumber AND fv.SKOrderStatus = 101 /*MTP evaluating plan quality*/ 
																  AND tdoi._Region = fv._Region
 INNER JOIN SrcIDS.stp_data stp ON stp.so_number = fv.SAPOrderNumber AND stp.qc_status = 1  
																	 AND stp._Region = fv._Region
 WHERE tdoi.MTP IS NULL -- AND stp.Region = @Region  
 AND tdoi.TreatmentCategory='Primary'  
 
 /*2. MTP Re-approval*/  
 	UPDATE tdoi SET MTP = 'MTP Re-approval'  
	FROM DW.Temp_DimOrderIDS tdoi  
 -- JOIN DW.DimOrder do on tdo.OrderKey=do.OrderKey   
 INNER JOIN DW.FactVolume fv ON tdoi.KeyOrder = fv.SAPOrderNumber AND fv.SKOrderStatus = 101 /*MTP evaluating plan quality*/  
																  AND tdoi._Region = fv._Region
 INNER JOIN SrcIDS.stp_data stp ON stp.so_number = fv.SAPOrderNumber AND stp.qc_status = 0  
																	 AND stp._Region = fv._Region
 WHERE tdoi.MTP IS NULL -- AND stp.Region = @Region  
 AND tdoi.TreatmentCategory='Primary'
 
 /*3.1 MTP Modify w/ switch*/  
	UPDATE tdoi SET MTP ='MTP Modify w/ switch'
	FROM DW.Temp_DimOrderIDS tdoi
 -- JOIN DM.DimOrder do on tdo.OrderKey=do.OrderKey   
 INNER JOIN DW.FactVolume fv1 ON tdoi.KeyOrder = fv1.SAPOrderNumber AND fv1.SKOrderStatus = 81 /*MTP awaiting review*/  
																	AND tdoi._Region = fv1._Region
 INNER JOIN DW.FactVolume fv2 ON tdoi.KeyOrder = fv2.SAPOrderNumber AND fv2.SKOrderStatus IN (82,83,85) /*ClinCheck Modification,ClinCheck Under Development*/ 
																	AND tdoi._Region = fv2._Region
 INNER JOIN DW.FactVolume fv3 ON tdoi.KeyOrder = fv3.SAPOrderNumber AND fv3.SKOrderStatus IN (90,100) AND fv3.ProductHierarchy != fv2.ProductHierarchy
																	AND tdoi._Region = fv3._Region
 -- AND CCAA.ProductKey != CCMOD.ProductKey /*ClinCheck Awaiting Approval*/  
 WHERE tdoi.MTP IS NULL
 AND tdoi.TreatmentCategory='Primary'  
 
/*3.2 MTP Modify*/  
	UPDATE tdoi SET MTP ='MTP Modify'
	FROM DW.Temp_DimOrderIDS tdoi
 -- JOIN DM.DimOrder do on tdo.OrderKey=do.OrderKey   
 INNER JOIN DW.FactVolume fv1 ON tdoi.KeyOrder = fv1.SAPOrderNumber AND fv1.SKOrderStatus = 81 /*MTP awaiting review*/  
																	AND tdoi._Region = fv1._Region
 INNER JOIN DW.FactVolume fv2 ON tdoi.KeyOrder = fv2.SAPOrderNumber AND fv2.SKOrderStatus IN (82,83,85) /*ClinCheck Modification,ClinCheck Under Development*/ 
																	AND tdoi._Region = fv2._Region
 WHERE tdoi.MTP IS NULL
 AND tdoi.TreatmentCategory='Primary'

/*3.5 MTP Switch*/  
 /* in case when doctor see MTP and decides to switch from ALTA */  
 UPDATE tdoi  SET MTP = 'MTP Switch'  
 FROM DW.Temp_DimOrderIDS tdoi  
 -- JOIN DM.DimOrder do ON tdo.OrderKey = do.OrderKey   
 INNER JOIN DW.FactVolume fv ON tdoi.KeyOrder = fv.SAPOrderNumber AND fv.SKOrderStatus = 81 /*MTP awaiting review*/  
																  AND tdoi._Region = fv._Region
 -- INNER JOIN DW.DimProduct p on p.ProductKey = do.AlignerProdHierKey  
 WHERE tdoi.MTP IS NULL 
 /*product is chosen and product is not invisalign go / go PLUS*/  
 AND fv.ProductHierarchy NOT IN (  
  'Unknown'  
  ,'A1A1T1C2G2' /*Invisalign Go 20*/  
  ,'A1A1T1C2G3' /*Invisalign Go Plus 26*/  
  )  
 AND tdoi.TreatmentCategory = 'Primary'   
 
 /*4. MTP Failed*/  
  
  IF OBJECT_ID(N'tempdb..#TransactionLog') IS NOT NULL DROP TABLE #TransactionLog
	CREATE TABLE #TransactionLog WITH (distribution = round_robin, heap) AS  
 SELECT LEFT([xml],CHARINDEX('</chan:ChangeOrderRequest>',[xml])+25) as xml, etl.external_id,tdoi.KeyOrder 
 FROM [SrcIDS].[tblCnEaiTransactionLog] etl  
 INNER JOIN DW.DimOrderIDS doi on doi.IDSOrderNumber= etl.external_id  
								  AND etl._Region = doi._Region
 INNER JOIN DW.Temp_DimOrderIDS tdoi on tdoi.KeyOrder = doi.KeyOrder 
 -- JOIN DM.DimProduct p on p.ProductKey=do.AlignerProdHierKey  -- DimOrderIDS (OrderType)
 WHERE etl.queue_name = 'QUEUE:changeProduct.request'  
 AND tdoi.MTP IS NULL 
 AND doi.TreatmentCategory = 'Primary' --AND etl.Region = @Region  
  
  
 UPDATE tdoi  SET MTP = 'MTP Failed'  
 FROM DW.Temp_DimOrderIDS tdoi  
 JOIN (  
  SELECT *  
  FROM #TransactionLog tl  
  where  tl.[xml] like '<chan:ChangeOrderRequest%<chan:RequestBody>%<chan:MTPGenerated>0</chan:MTPGenerated>%</chan:RequestBody>%</chan:ChangeOrderRequest>'
  --tl.[xml].exist('declare namespace chan="http://aligntech/order/changeorderservice-1.0.xsd"; (/chan:ChangeOrderRequest/chan:RequestBody/chan:MTPGenerated[.="0"])') =1  
  ) as Failed  
  on Failed.keyOrder = tdoi.KeyOrder
 
 /*5. MTP in progress*/  
  
 UPDATE tdoi SET MTP = 'MTP in progress' 
 FROM DW.Temp_DimOrderIDS tdoi  
 -- JOIN DM.DimOrder do on tdo.OrderKey=do.OrderKey   
 INNER JOIN DW.FactVolume fv ON tdoi.KeyOrder = fv.SAPOrderNumber AND fv.SKOrderStatus = 79 /*MTP generation*/  
																  AND tdoi._Region = fv._Region
 WHERE tdoi.MTP IS NULL
 AND tdoi.TreatmentCategory = 'Primary'  
  
  
 UPDATE tdoi SET MTP = 'MTP in progress' 
 FROM DW.Temp_DimOrderIDS tdoi  
 -- INNER JOIN DM.DimOrder do on tdo.OrderKey=do.OrderKey   
 -- INNER JOIN Dm.DimOrderDeliverableType odt on odt.DeliverableTypeKey=CaseSetupDeliverableTypeKey   --(DeliverableType in DimOrderIDS)
 WHERE tdoi.MTP IS NULL  
 AND tdoi.DeliverableType IN ('CLEAR_ALIGNER_GO','GO_PLUS','GO_STD','IGO_PLUS','IGO_STD')  
 AND tdoi.TreatmentCategory='Primary'  
 --and do.SapOrderNumber=25890198  
 
 
  /*6. Prescriptive*/  
 UPDATE DW.Temp_DimOrderIDS SET MTP = 'Prescriptive'  
 WHERE MTP IS NULL  


	update DW.Temp_DimOrderIDS 
		set	DWHash =
				convert(char(40),
					hashbytes('SHA1',
								 isnull(convert(nvarchar, IDSOrderNumber), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SKContact), N'N/A')
						+ N'|' + isnull(convert(nvarchar, OrderType), N'N/A')
						+ N'|' + isnull(convert(nvarchar, DeliverableType), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TreatmentCategory), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TreatmentType), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PatientCurrentStageLowerArch), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PatientCurrentStageUpperArch), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastStaffDiscountUtilizedDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CancelReasonCode), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TreatedArches), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsIOScan), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ScanType), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CaseCode), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SubmissionType), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SubmitDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, AMRDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstCCUDDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastCCUDDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstCCAADate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastCCAADate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstCCMODDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastCCMODDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CCADate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ShipmentScheduledDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ShipmentDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CancellationDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstMaterialsRequiredDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastMaterialsRequiredDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ClinicalHoldDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, UnknownOrderConvertedDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ProductSwitchDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstGenerateMTPDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastGenerateMTPDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TreatmentID), N'N/A')
						+ N'|' + isnull(convert(nvarchar, EECDDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ArchConversion), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PatientVIPID), N'N/A')
						--+ N'|' + isnull(convert(nvarchar, PatientBirthDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PatientGender), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PatientIsArchived), N'N/A')
						+ N'|' + isnull(convert(nvarchar, HoldReason), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LoanNumber), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LoanTreatmentFee), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LoanApproveAmount), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ScanOfficeContactSFID), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SKAccount), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ReClinCheckCount), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastAMRDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastCCADate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TreatmentFeature), N'N/A')
						+ N'|' + isnull(convert(nvarchar, OrderCompleteDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CCAAAgeing), N'N/A')
						+ N'|' + isnull(convert(nvarchar, MTP), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FullOrPartial), N'N/A')
						+ N'|' + isnull(convert(nvarchar, _Region), N'N/A')
					)
				, 2)
		,	DWHashMainSubset =
				convert(char(40),
					hashbytes('SHA1',
								 isnull(convert(nvarchar, IDSOrderNumber), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastStaffDiscountUtilizedDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CancelReasonCode), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TreatedArches), N'N/A')
						+ N'|' + isnull(convert(nvarchar, IsIOScan), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ScanType), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SubmitDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstCCUDDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastCCUDDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstCCAADate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastCCAADate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, FirstCCMODDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, LastCCMODDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CCADate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ShipmentScheduledDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, CancellationDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ClinicalHoldDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, UnknownOrderConvertedDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ProductSwitchDate), N'N/A')
						+ N'|' + isnull(convert(nvarchar, TreatmentID), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ArchConversion), N'N/A')
						+ N'|' + isnull(convert(nvarchar, PatientIsArchived), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SKAccount), N'N/A')
						+ N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
						+ N'|' + isnull(convert(nvarchar, ReClinCheckCount), N'N/A')
					)
				, 2)
	where SKOrder != -1

	if @IsFullLoad = 0
	begin
		update DW.DimOrderIDS
			set	ADLSBatchID = src.ADLSBatchID
			,	ADLSTimestamp = src.ADLSTimestamp
			,	LZBatchID = src.LZBatchID
			,	DWBatchID = @BatchID
			,	DWHash = src.DWHash
			,	DWHashMainSubset = src.DWHashMainSubset
			,	IDSOrderNumber = src.IDSOrderNumber
			,	SKContact = src.SKContact
			,	OrderType = src.OrderType
			,	DeliverableType = src.DeliverableType
			,	TreatmentCategory = src.TreatmentCategory
			,	TreatmentType = src.TreatmentType
			,	PatientCurrentStageLowerArch = src.PatientCurrentStageLowerArch
			,	PatientCurrentStageUpperArch = src.PatientCurrentStageUpperArch
			,	LastStaffDiscountUtilizedDate = src.LastStaffDiscountUtilizedDate
			,	CancelReasonCode = src.CancelReasonCode
			,	TreatedArches = src.TreatedArches
			,	IsIOScan = src.IsIOScan
			,	ScanType = src.ScanType
			,	CaseCode = src.CaseCode
			,	SubmissionType = src.SubmissionType
			,	SubmitDate = src.SubmitDate
			,	AMRDate = src.AMRDate
			,	FirstCCUDDate = src.FirstCCUDDate
			,	LastCCUDDate = src.LastCCUDDate
			,	FirstCCAADate = src.FirstCCAADate
			,	LastCCAADate = src.LastCCAADate
			,	FirstCCMODDate = src.FirstCCMODDate
			,	LastCCMODDate = src.LastCCMODDate
			,	CCADate = src.CCADate
			,	ShipmentScheduledDate = src.ShipmentScheduledDate
			,	ShipmentDate = src.ShipmentDate
			,	CancellationDate = src.CancellationDate
			,	FirstMaterialsRequiredDate = src.FirstMaterialsRequiredDate
			,	LastMaterialsRequiredDate = src.LastMaterialsRequiredDate
			,	ClinicalHoldDate = src.ClinicalHoldDate
			,	UnknownOrderConvertedDate = src.UnknownOrderConvertedDate
			,	ProductSwitchDate = src.ProductSwitchDate
			,	FirstGenerateMTPDate = src.FirstGenerateMTPDate
			,	LastGenerateMTPDate = src.LastGenerateMTPDate
			,	TreatmentID = src.TreatmentID
			,	EECDDate = src.EECDDate
			,	ArchConversion = src.ArchConversion
			,	PatientVIPID = src.PatientVIPID
			--,	PatientBirthDate = src.PatientBirthDate
			,	PatientGender = src.PatientGender
			,	PatientIsArchived = src.PatientIsArchived
			,	HoldReason = src.HoldReason
			,	LoanNumber = src.LoanNumber
			,	LoanTreatmentFee = src.LoanTreatmentFee
			,	LoanApproveAmount = src.LoanApproveAmount
			,	ScanOfficeContactSFID = src.ScanOfficeContactSFID
			,   SKAccount = src.SKAccount
			,   SecRegion = src.SecRegion
			,	ReClinCheckCount = src.ReClinCheckCount
			,	LastAMRDate = src.LastAMRDate
			,	LastCCADate = src.LastCCADate
			,	TreatmentFeature = src.TreatmentFeature
			,	OrderCompleteDate = src.OrderCompleteDate
			,	CCAAAgeing = src.CCAAAgeing
			,   MTP = src.MTP
			,	FullOrPartial = src.FullOrPartial
			,	_Region = src._Region
		from DW.Temp_DimOrderIDS src
		where DW.DimOrderIDS.SKOrder = src.SKOrder
			and DW.DimOrderIDS.DWHash != src.DWHash
		option (label = 'DW.LoadDimOrderIDS_Update');
	
		exec CTRL.GetLastRowCount @Label = 'DW.LoadDimOrderIDS_Update', @rc = @RowsUpdated out

		insert into DW.DimOrderIDS (
				SKOrder
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	DWHashMainSubset
			,	KeyOrder
			,	IDSOrderNumber
			,	SKContact
			,	OrderType
			,	DeliverableType
			,	TreatmentCategory
			,	TreatmentType
			,	PatientCurrentStageLowerArch
			,	PatientCurrentStageUpperArch
			,	LastStaffDiscountUtilizedDate
			,	CancelReasonCode
			,	TreatedArches
			,	IsIOScan
			,	ScanType
			,	CaseCode
			,	SubmissionType
			,	SubmitDate
			,	AMRDate
			,	FirstCCUDDate
			,	LastCCUDDate
			,	FirstCCAADate
			,	LastCCAADate
			,	FirstCCMODDate
			,	LastCCMODDate
			,	CCADate
			,	ShipmentScheduledDate
			,	ShipmentDate
			,	CancellationDate
			,	FirstMaterialsRequiredDate
			,	LastMaterialsRequiredDate
			,	ClinicalHoldDate
			,	UnknownOrderConvertedDate
			,	ProductSwitchDate
			,	FirstGenerateMTPDate
			,	LastGenerateMTPDate
			,	TreatmentID
			,	EECDDate
			,	ArchConversion
			,	PatientVIPID
			--,	PatientBirthDate
			,	PatientGender
			,	PatientIsArchived
			,	HoldReason
			,	LoanNumber
			,	LoanTreatmentFee
			,	LoanApproveAmount
			,	ScanOfficeContactSFID
			,   SKAccount
			,   SecRegion
			,	ReClinCheckCount
			,	LastAMRDate
			,	LastCCADate
			,	TreatmentFeature
			,	OrderCompleteDate
			,	CCAAAgeing
			,	MTP
			,	FullOrPartial
			,	_Region
		)
		select	src.SKOrder
			,	src.ADLSBatchID
			,	src.ADLSTimestamp
			,	src.LZBatchID
			,	@BatchID
			,	src.DWHash
			,	src.DWHashMainSubset
			,	src.KeyOrder
			,	src.IDSOrderNumber
			,	src.SKContact
			,	src.OrderType
			,	src.DeliverableType
			,	src.TreatmentCategory
			,	src.TreatmentType
			,	src.PatientCurrentStageLowerArch
			,	src.PatientCurrentStageUpperArch
			,	src.LastStaffDiscountUtilizedDate
			,	src.CancelReasonCode
			,	src.TreatedArches
			,	src.IsIOScan
			,	src.ScanType
			,	src.CaseCode
			,	src.SubmissionType
			,	src.SubmitDate
			,	src.AMRDate
			,	src.FirstCCUDDate
			,	src.LastCCUDDate
			,	src.FirstCCAADate
			,	src.LastCCAADate
			,	src.FirstCCMODDate
			,	src.LastCCMODDate
			,	src.CCADate
			,	src.ShipmentScheduledDate
			,	src.ShipmentDate
			,	src.CancellationDate
			,	src.FirstMaterialsRequiredDate
			,	src.LastMaterialsRequiredDate
			,	src.ClinicalHoldDate
			,	src.UnknownOrderConvertedDate
			,	src.ProductSwitchDate
			,	src.FirstGenerateMTPDate
			,	src.LastGenerateMTPDate
			,	src.TreatmentID
			,	src.EECDDate
			,	src.ArchConversion
			,	src.PatientVIPID
			--,	src.PatientBirthDate
			,	src.PatientGender
			,	src.PatientIsArchived
			,	src.HoldReason
			,	src.LoanNumber
			,	src.LoanTreatmentFee
			,	src.LoanApproveAmount
			,	src.ScanOfficeContactSFID
			,	src.SKAccount
			,	src.SecRegion
			,	src.ReClinCheckCount
			,	src.LastAMRDate
			,	src.LastCCADate
			,	src.TreatmentFeature
			,	src.OrderCompleteDate
			,	src.CCAAAgeing
			,	src.MTP
			,	src.FullOrPartial
			,	src._Region
		from DW.Temp_DimOrderIDS src
		where not exists (select * from DW.DimOrderIDS dst where dst.SKOrder = src.SKOrder)
		option (label = 'DW.LoadDimOrderIDS_Insert');

		exec CTRL.GetLastRowCount @Label = 'DW.LoadDimOrderIDS_Insert', @rc = @RowsInserted out
	end
	else
	begin --full load
		if object_id ('DW.DimOrderIDSPrevious', 'U') is not null
			drop table DW.DimOrderIDSPrevious

		rename object DW.DimOrderIDS to DimOrderIDSPrevious
		rename object DW.Temp_DimOrderIDS to DimOrderIDS
		drop table DW.DimOrderIDSPrevious

		create index IX_DimOrderIDS_KeyOrder on DW.DimOrderIDS (KeyOrder)

		select @RowsInserted = count(*)
		from DW.DimOrderIDS 
	end
/*
	if @IsMainTableFullLoad = 0
	begin
		update DW.DimOrder
			set	DWBatchID = @BatchID
			,	DWHashIDS = src.DWHashMainSubset
			,	ADLSTimestampIDS = src.ADLSTimestamp
			,	IDSOrderNumber = src.IDSOrderNumber
			,	LastStaffDiscountUtilizedDate = src.LastStaffDiscountUtilizedDate
			,	CancelReasonCode = src.CancelReasonCode
			,	TreatedArches = src.TreatedArches
			,	IsIOScan = src.IsIOScan
			,	ScanType = src.ScanType
			,	SubmitionDate = src.SubmitDate
			,	FirstCCUDDate = src.FirstCCUDDate
			,	LastCCUDDate = src.LastCCUDDate
			,	FirstCCAADate = src.FirstCCAADate
			,	LastCCAADate = src.LastCCAADate
			,	FirstCCMODDate = src.FirstCCMODDate
			,	LastCCMODDate = src.LastCCMODDate
			,	CCADate = src.CCADate
			,	PromisedShipDate = src.ShipmentScheduledDate
			,	CancellationDate = src.CancellationDate
			,	ClinicalHoldDate = src.ClinicalHoldDate
			,	UnknownOrderConvertedDate = src.UnknownOrderConvertedDate
			,	ProductSwitchDate = src.ProductSwitchDate
			,	TreatmentID = src.TreatmentID
			,	ArchConversion = src.ArchConversion
			,	IsArchived = src.PatientIsArchived
			,	SKAccountIDS = src.SKAccount
			,	SecRegion = src.SecRegion
			,	ReClinCheckCount = src.ReClinCheckCount
			,	FullOrPartial = src.FullOrPartial
			,	MTP = src.MTP
			,	CCAAAgeing = src.CCAAAgeing
			,	OrderCompleteDate = src.OrderCompleteDate
		from DW.Temp_DimOrderIDS src
		where src.SKOrder = DW.DimOrder.SKOrder
			and src.DWHashMainSubset != isnull(DW.DimOrder.DWHashIDS, '*')
	end
	else
	begin
		update DW.DimOrder
			set	DWBatchID = @BatchID
			,	DWHashIDS = src.DWHashMainSubset
			,	ADLSTimestampIDS = src.ADLSTimestamp
			,	IDSOrderNumber = src.IDSOrderNumber
			,	LastStaffDiscountUtilizedDate = src.LastStaffDiscountUtilizedDate
			,	CancelReasonCode = src.CancelReasonCode
			,	TreatedArches = src.TreatedArches
			,	IsIOScan = src.IsIOScan
			,	ScanType = src.ScanType
			,	SubmitionDate = src.SubmitDate
			,	FirstCCUDDate = src.FirstCCUDDate
			,	LastCCUDDate = src.LastCCUDDate
			,	FirstCCAADate = src.FirstCCAADate
			,	LastCCAADate = src.LastCCAADate
			,	FirstCCMODDate = src.FirstCCMODDate
			,	LastCCMODDate = src.LastCCMODDate
			,	CCADate = src.CCADate
			,	PromisedShipDate = src.ShipmentScheduledDate
			,	CancellationDate = src.CancellationDate
			,	ClinicalHoldDate = src.ClinicalHoldDate
			,	UnknownOrderConvertedDate = src.UnknownOrderConvertedDate
			,	ProductSwitchDate = src.ProductSwitchDate
			,	TreatmentID = src.TreatmentID
			,	ArchConversion = src.ArchConversion
			,	IsArchived = src.PatientIsArchived
			,	SKAccountIDS = src.SKAccount
			,	SecRegion = src.SecRegion
			,	ReClinCheckCount = src.ReClinCheckCount
			,	FullOrPartial = src.FullOrPartial
			,	MTP = src.MTP
			,	CCAAAgeing = src.CCAAAgeing
			,	OrderCompleteDate = src.OrderCompleteDate
		from DW.DimOrderIDS src
		where src.SKOrder = DW.DimOrder.SKOrder
			and src.DWHashMainSubset != isnull(DW.DimOrder.DWHashIDS, '*')
	end
	*/
	
	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end