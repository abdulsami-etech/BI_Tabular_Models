CREATE PROC [DW].[LoadDimOrderSFDC] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if not exists (select * from DW.DimOrderSFDC)
		set @IsFullLoad = 1

	if object_id ('DW.Temp_OrdersSFDCToLoad', 'U') is not null
		drop table DW.Temp_OrdersSFDCToLoad

	create table DW.Temp_OrdersSFDCToLoad (Id nchar(18) not null) with (distribution = round_robin, heap)
	ALTER TABLE [DW].[Temp_OrdersSFDCToLoad] ADD CONSTRAINT PK_Temp_OrdersSFDCToLoad PRIMARY KEY NONCLUSTERED (Id) NOT ENFORCED

	if @IsFullLoad = 0
	begin
		insert into [DW].[Temp_OrdersSFDCToLoad] (Id)
		select Id 
		from SrcSFDC.Apttus_Config2__Order__c
		where SystemModStamp >= @LastSuccessfullDWTimestamp 
		union
		select Apttus_Config2__OrderId__c 
		from SrcSFDC.Apttus_Config2__OrderLineItem__c
		where SystemModStamp >= @LastSuccessfullDWTimestamp
	end

	if object_id('DW.Temp_DimOrderSFDC') is not null
		drop table DW.Temp_DimOrderSFDC

	create table DW.Temp_DimOrderSFDC
	(
		SKOrder								bigint		NOT NULL,
	
		ADLSBatchID							int			NOT NULL,
		ADLSTimestamp						datetime2(0) NOT NULL,
		LZBatchID							int			NOT NULL,
		DWBatchID							int			NOT NULL,
		DWHash								char(40)	NOT NULL,

		KeyOrder							bigint		NOT NULL,
		SFDCOrderNumber						nchar(18)	NOT NULL,
		SFDCOrderName						nvarchar(80)	NULL,
		AMRDate								date			NULL,
		CancellationDate					date			NULL,
		CCADate								date			NULL,
		ShipmentDate						date			NULL,
		SubmitDate							date			NULL,
		RejectedImpressionsDate				datetime2(0)	NULL,
		CCUDDate							datetime2(0)	NULL,
		CCAADate							datetime2(0)	NULL,
		ClinicalHoldDate					datetime2(0)	NULL,
		ProductType							nvarchar(128)	NULL,
		AdvantageRebatePeriod				datetime2(7)	NULL,
		AdvantageRebateQualifiedFlag		varchar(10)		NULL,
		TreatmentCategory					nvarchar(30)	NULL,
		SKContact							int			NOT NULL,
		SKAccountTreatmentLocation			int			NOT NULL,
		SKAccountShipTo						int			NOT NULL,
		SKAccountBillTo						int			NOT NULL,
		SKAccountSoldTo						int			NOT NULL,
		SKAccountScanOffice					int			NOT NULL,
		SKAccountPayer						int			NOT NULL,
		PatientSFDCID						nchar(18)		NULL,
		PatientGender						nvarchar(32)	NULL,
		PatientAge							decimal(18,0)	NULL,
		--PatientBirthDate					date			NULL,
		PatientIsArchived					varchar(8)		NULL,
		RefinementFeeDate					date			NULL,
		ListPrice							decimal(18, 2)	NULL,
		NetPrice							decimal(18, 2)	NULL,
		DiscountAmount						decimal(19, 2)	NULL,
		TreatmentID							nvarchar(18)	NULL,
		CurrencyCode						nvarchar(3)	NOT NULL,
		LICaseSetupDeliverableType			nvarchar(30)	NULL,
		LICaseSetupTreatmentOption			nvarchar(30)	NULL,
		LIAlignerDeliverableType			nvarchar(30)	NULL,
		LIAlignerTreatmentOption			nvarchar(30)	NULL,
		LIAlignerQtyFromSFDC				decimal(18, 0)	NULL,
		USListPrice							decimal(18, 5)	NULL,
		PaymentTerms						nvarchar(30)	NULL,
		PaymentMethod						nvarchar(30)	NULL,
		HasComplianceIdicator				nvarchar(10)	NULL,
		PatientTypeBrand					nvarchar(10)	NULL,
		PatientType							nvarchar(32)	NULL,
		ScanType							nvarchar(255)	NULL,
		AdditionalAlignersUsed				DECIMAL(18)     NULL,
		TreatmentExpiryDate		            DATE            NULL,
		TreatedArches						NVARCHAR (255)  NULL,
		UpperQuantity		                DECIMAL (18)    NULL,
		LowerQuantity		                DECIMAL (18)    NULL,
		MAF		                            NVARCHAR (5)    NULL,
		IDSOrderStatus						NVARCHAR (255)  NULL,
		SKPricingGroupTreatLoc				int				NULL,
		SubscriptionPackage					nvarchar(255)	NULL,
		SubscriptionProgram					nvarchar(255)	NULL,
		LICaseSetupProductCode				nvarchar(1300)	NULL,
		LIAlignerProductCode				nvarchar(1300)	NULL,
		ContractNumber						nvarchar(255)	NULL,
		WithinRFDDate						nvarchar(1300)	NULL,
		WithinTEDDate						nvarchar(1300)	NULL,
		HoldReason							nvarchar(255)	NULL,
		HoldDate							datetime2(7)	NULL,
		AARefinementsUsed					decimal(18,2)	NULL,
		ReplacementsUsed					decimal(18,2)	NULL,
		SecRegion							varchar(10)		NULL,
		FirstAMRDate						date			NULL,
		LastAMRDate							date			NULL,
		FirstCCADate						date			NULL,
		LastCCADate							date			NULL
	)
	with
	(
		distribution = hash(SKOrder),
		clustered columnstore index
	)
	
	insert into DW.Temp_DimOrderSFDC (
			SKOrder
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyOrder
		,	SFDCOrderNumber
		,	SFDCOrderName
		,	AMRDate
		,	CancellationDate
		,	CCADate
		,	ShipmentDate
		,	SubmitDate
		,	RejectedImpressionsDate
		,	CCUDDate
		,	CCAADate
		,	ClinicalHoldDate
		,	ProductType
		,	AdvantageRebatePeriod
		,	AdvantageRebateQualifiedFlag
		,	TreatmentCategory
		,	SKContact
		,	SKAccountTreatmentLocation
		,	SKAccountShipTo
		,	SKAccountBillTo
		,	SKAccountSoldTo
		,	SKAccountScanOffice
		,	SKAccountPayer
		,	PatientSFDCID
		,	PatientGender
		,	PatientAge
		--,	PatientBirthDate
		,	PatientIsArchived
		,	RefinementFeeDate
		,	ListPrice
		,	NetPrice
		,	DiscountAmount
		,	TreatmentID
		,	CurrencyCode
		,	LICaseSetupDeliverableType
		,	LICaseSetupTreatmentOption
		,	LIAlignerDeliverableType
		,	LIAlignerTreatmentOption
		,	LIAlignerQtyFromSFDC
		,	USListPrice
		,	PaymentTerms
		,	PaymentMethod
		,	HasComplianceIdicator
		,	PatientTypeBrand
		,	PatientType
		,	ScanType
		,	AdditionalAlignersUsed
		,	TreatmentExpiryDate
		,	TreatedArches
		,	UpperQuantity
		,	LowerQuantity
		,	MAF
		,	IDSOrderStatus
		,	SKPricingGroupTreatLoc 
		,	SubscriptionPackage 
		,	SubscriptionProgram 
		,	LICaseSetupProductCode 
		,	LIAlignerProductCode 
		,	ContractNumber 
		,	WithinRFDDate 
		,	WithinTEDDate 
		,	HoldReason
		,	HoldDate
		,	AARefinementsUsed 
		,	ReplacementsUsed 
		,	SecRegion
		,	FirstAMRDate 
		,	LastAMRDate 
		,	FirstCCADate 
		,	LastCCADate 
	)
	select	ho.SKOrder													as SKOrder
		,	oh.ADLSBatchID												as ADLSBatchID
		,	oh.ADLSTimestamp											as ADLSTimestamp
		,	oh.LZBatchID												as LZBatchID
		,	@BatchId													as DWBatchID
		,	''															as DWHash
		,	ho.KeyOrder													as KeyOrder
		,	oh.id														as SFDCOrderNumber
		,	oh.NAME														as SFDCOrderName
		,	convert(date, oh.Receipt_Date1__c)							as AMRDate
		,	convert(date, oh.Cancelled_Date1__c)						as CancellationDate
		,	convert(date, oh.CCA_Date1__c)								as CCADate	
		,	convert(date, oh.Shipped_Date1__c)							as ShipmentDate
		,	convert(date, oh.Rx_Submission_Date1__c)					as SubmitDate
		,	convert(datetime2(0), oh.Rejected_Impressions_Date__c)		as RejectedImpressionsDate
		,	convert(datetime2(0), oh.Clincheck_Under_Dev__c)			as CCUDDate
		,	convert(datetime2(0), oh.Clinicheck_Awaiting_Approval__c)	as CCAADate
		,	convert(datetime2(0), oh.Clinical_Hold_Date__c)				as ClinicalHoldDate
		,	convert(nvarchar(128), oh.Product_Type__c)					as ProductType
		,	oh.Advantage_Qualification_Date1__c							as AdvantageRebatePeriod
		,	convert(varchar(10),
				case when oh.Advantage_Qualification_Date1__c is not null
					then 'Yes'
					else 'No'
				end
			)															as AdvantageRebateQualifiedFlag
		,	convert(nvarchar(30), oh.Treatment_Category__c)				as TreatmentCategory
		,	isnull(hubContact.SKContact, -1)							as SKContact
		,	isnull(hubAccTL.SKAccount, -1)								as SKAccountTreatmentLocation  
		,	isnull(hubAccShipTo.SKAccount, -1)							as SKAccountShipTo
		,	isnull(hubAccBillTo.SKAccount, -1)							as SKAccountBillTo 
		,	isnull(hubAccSoldTo.SKAccount, -1)							as SKAccountSoldTo
		,	isnull(hubAccScanOffice.SKAccount, -1)						as SKAccountScanOffice
		,	isnull(AccPayer.SKAccount, -1)								as SKAccountPayer
		,	p.Id														as PatientSFDCID
		,	convert(nvarchar(32), p.Gender__c)							as PatientGender
		,	isnull(oh.Patient_Age_Year__c,-1)							as PatientAge
		--,	try_convert(date, p.Date_of_Birth__c)						as PatientBirthDate
		,	convert(varchar(8),
				case when p.IsArchived__c = 1
					then 'Yes'
					else 'No'
				end
			)															as PatientIsArchived
		,	convert(date, oh.Refinement_Fee_Date1__c)					as RefinementFeeDate   
		,	oh.Total_List_Price__c										as ListPrice
		,	oh.Total_Net_Price__c										as NetPrice
		,	oh.Total_List_Price__c - oh.Total_Net_Price__c				as DiscountAmount
		,	convert(nvarchar(18), tr.Treatment_Id__c)					as TreatmentID
		,	oh.CurrencyIsoCode											as CurrencyCode
		,	convert(nvarchar(30), olCS.Deliverable_Type__c)				as LICaseSetupDeliverableType
		,	convert(nvarchar(30), olCS.Treatment_Option__c)				as LICaseSetupTreatmentOption
		,	convert(nvarchar(30), olAl.Deliverable_Type__c)				as LIAlignerDeliverableType
		,	convert(nvarchar(30), olAl.Treatment_Option__c)				as LIAlignerTreatmentOption
		,	olAl.Total_Quantity__c										as LIAlignerQtyFromSFDC
		,	USListPrice.Apttus_Config2__ListPrice__c					as USListPrice
		,	left(oh.Payment_Term__c, 30)								as PaymentTerms
		,	case when len(oh.Payment_Method__c) < 31 
				then left(oh.Payment_Method__c, 30) 
				else null 
			end															as PaymentMethod	
		,	convert(nvarchar(10), isnull(olAl.Compliance_Indicator_Enabled__c, olCS.Compliance_Indicator_Enabled__c))			as HasComplianceIdicator
		,	convert(nvarchar(10), oh.Patient_Type_Brand__c)				as PatientTypeBrand
		,	convert(nvarchar(32), oh.Patient_Type__c)					as PatientType
		,	oh.Scan_Type__c												as ScanType
		,	tr.Number_of_Additional_Aligners_Used__c					as AdditionalAlignersUsed
		,	tr.Treatment_Expiration_Date__c								as TreatmentExpiryDate
		,	tr.Treated_Arches__c										as TreatedArches
		,	oh.Upper_Quantity__C										as UpperQuantity
		,	oh.Lower_Quantity__C										as LowerQuantity
		,	oh.MAF__C													as MAF
		,	oh.IDS_Order_Status__c										as IDSOrderStatus
		,	isnull(hubPricingGTL.SKAccount	, -1)						as SKPricingGroupTreatLoc
		,	olAl.Subscription_Package__c								as SubscriptionPackage
		,	olAl.Subscription_Program__c								as SubscriptionProgram
		,	olCS.Product_Code__C										as LICaseSetupProductCode
		,	olAl.Product_Code__C										as LIAlignerProductCode
		,	olAl.Contract_Number__C										as ContractNumber
		,	olAl.Within_RFD_Date__c										as WithinRFDDate
		,	olAl.Within_TED_Date__c										as WithinTEDDate
		,	oh.Hold_Reasons__c											as HoldReason
		,	oh.Hold_Date__c												as HoldDate
		,	olAl.Number_of_Refinements_Used__c							as AARefinementsUsed
		,	olAl.Number_of_Replacements_Used__c							as ReplacementsUsed
		,	DimReg.SecRegion											as SecRegion
		,	case when oht.Field='Receipt_Date__c' then
				case when try_convert(date,oht.oldValue) is null then try_convert(date,oh.Receipt_Date1__c) Else try_convert(date,oht.oldValue) END END AS FirstAMRDate
		,	case when oht.Field='Receipt_Date__c' then
				case when try_convert(date,oht.NewValue) is null then try_convert(date,oh.Receipt_Date1__c) Else try_convert(date,oht.NewValue) END END AS LastAMRDate
		,	case when ohtt.Field='CCA_Date__c' then
				case when try_convert(date,ohtt.OldValue) is null then try_convert(date,oh.CCA_Date1__c) Else try_convert(date,ohtt.oldValue) END END AS FirstCCADate
		,	case when ohtt.Field='CCA_Date__c' then
				case when try_convert(date,ohtt.NewValue) is null then try_convert(date,oh.CCA_Date1__c) Else try_convert(date,ohtt.NewValue) END END AS LastCCADate
	from SrcSFDC.Apttus_Config2__Order__c oh
	inner join DW.HubOrder ho on ho.KeyOrder = try_convert(bigint, oh.SAP_Order_ID__c)
	left join DW.HubContact hubContact on hubContact.KeyContact = oh.Apttus_Config2__PrimaryContactId__c
	left join DW.HubAccount hubAccTL on hubAccTL.KeyAccount = oh.Treatment_Location__c
	left join DW.HubAccount hubAccShipTo on hubAccShipTo.KeyAccount = oh.Apttus_Config2__ShipToAccountId__c
	left join DW.HubAccount hubAccBillTo on hubAccBillTo.KeyAccount = oh.Apttus_Config2__BillToAccountId__c
	left join DW.HubAccount hubAccSoldTo on hubAccSoldTo.KeyAccount = oh.Apttus_Config2__SoldToAccountId__c
	left join DW.HubAccount hubAccScanOffice on hubAccScanOffice.KeyAccount = oh.Scan_Office_Account__c
	left join DW.DimAccount AccPayer on AccPayer.AccountNumber = oh.Payer__c 
	left join DW.DimAccount DimReg on DimReg.SKAccount = hubAccTL.SKAccount 
	left join DW.DimAccount DimPricingGrp on DimPricingGrp.KeyAccount = oh.Treatment_Location__c
	left join DW.hubAccount hubPricingGTL on DimPricingGrp.PricingGroupC = hubPricingGTL.KeyAccount
	--left join DW.HubAccount hubPricingGTL on hubPricingGTL.KeyAccount=oh.Pricing_Group_Treatment_Location__c
	--left join SrcSFDC.Apttus_Config2__Order__History oht on oh.id=oht.Parentid and oht.Field in ('Receipt_Date__c')
	left join (select * from (select parentid,Field,OldValue,NewValue,CreatedDate,row_number() over (partition by parentid order by createddate desc) as RN
from SrcSFDC.Apttus_Config2__Order__History where Field in ('Receipt_Date__c')) a where  RN=1) oht on oh.id=oht.Parentid and oht.Field in ('Receipt_Date__c')
	left join (select * from (select parentid,Field,OldValue,NewValue,CreatedDate,row_number() over (partition by parentid order by createddate desc) as RN
from SrcSFDC.Apttus_Config2__Order__History where Field in ('CCA_Date__c')) a where RN=1) ohtt on oh.id=ohtt.Parentid and ohtt.Field in ('CCA_Date__c')
	left join SrcSFDC.Treatment__c tr on tr.Id = oh.Treatment_ID__c
	left join SrcSFDC.Patient__c p on p.Id = oh.Patient_ID__c
	left join (
		select top (1) with ties
				Apttus_Config2__OrderId__c
			,	Deliverable_Type__c
			,	Treatment_Option__c
			,	Apttus_Config2__ChargeType__c
			,	Apttus_Config2__ProductId__c
			,   Compliance_Indicator_Enabled__c
			,	Subscription_Package__c		
			,	Subscription_Program__c		
			,	Product_Code__C			
			,	Contract_Number__C				
			,	Within_RFD_Date__c				
			,	Within_TED_Date__c
			,	Number_of_Refinements_Used__c	
			,	Number_of_Replacements_Used__c	
		from SrcSFDC.Apttus_Config2__OrderLineItem__c
		where (@IsFullLoad = 1 or Apttus_Config2__OrderId__c in (select Id from [DW].[Temp_OrdersSFDCToLoad])) and 
		Quote_Order_Flag__c = N'ORDER'
			and Apttus_Config2__ChargeType__c = N'Standard Price' --Case setup
			and Deliverable_Type__c <> 'AUTOFULFILLMENT' 
		order by row_number() over (partition by Apttus_Config2__OrderId__c order by Apttus_Config2__LineNumber__c desc, LastModifiedDate desc)
	) olCS on oh.id = olCS.Apttus_Config2__OrderId__c 
	left join (
		select top (1) with ties
				Apttus_Config2__OrderId__c
			,	Deliverable_Type__c
			,	Treatment_Option__c
			,	Apttus_Config2__ChargeType__c
			,	Total_Quantity__c
			,	Apttus_Config2__ProductId__c
			,   Compliance_Indicator_Enabled__c
			,	Subscription_Package__c		
			,	Subscription_Program__c		
			,	Product_Code__C				
			,	Contract_Number__C				
			,	Within_RFD_Date__c				
			,	Within_TED_Date__c	
			,	Number_of_Refinements_Used__c	
			,	Number_of_Replacements_Used__c	
		from SrcSFDC.Apttus_Config2__OrderLineItem__c
		where (@IsFullLoad = 1 or Apttus_Config2__OrderId__c in (select Id from [DW].[Temp_OrdersSFDCToLoad])) and 
			Quote_Order_Flag__c = N'ORDER'
			and Apttus_Config2__ChargeType__c not in ( N'Standard Price', 'Adjustment')--Aligner
			and Deliverable_Type__c <> 'AUTOFULFILLMENT'
			and Treatment_Option__c <> 'TreatOpt' 
			and Product_Code__C not in (select ProductCode from SrcSFDC.Product2 where Name like '%Processing Fee%')
		order by row_number() over (partition by Apttus_Config2__OrderId__c order by Apttus_Config2__LineNumber__c desc, LastModifiedDate desc)
	) olAl on oh.id = olAl.Apttus_Config2__OrderId__c
	left join (
		select top (1) with ties
				Apttus_Config2__ChargeType__c
			,	Apttus_Config2__ProductId__c
			,	Apttus_Config2__ListPrice__c
		from SrcSFDC.Apttus_Config2__PriceListItem__c
		where Apttus_Config2__PriceListId__c = 'a4Li0000000TQJXEA4' --'Price List for Direct Customers in United States'
			and Apttus_Config2__ListPrice__c != 0
		order by row_number() over (
			partition by Apttus_Config2__ChargeType__c, Apttus_Config2__ProductId__c 
			order by case when Apttus_Config2__Active__c = 'true' then 1 end desc, SystemModStamp desc
		)
	) USListPrice on USListPrice.Apttus_Config2__ChargeType__c = isnull(olAl.Apttus_Config2__ChargeType__c, olCS.Apttus_Config2__ChargeType__c)
		and USListPrice.Apttus_Config2__ProductId__c = isnull(olAl.Apttus_Config2__ProductId__c, olCS.Apttus_Config2__ProductId__c)
	where (@IsFullLoad = 1 or oh.Id in (select Id from [DW].[Temp_OrdersSFDCToLoad]))
		and try_convert(bigint, oh.SAP_Order_ID__c) is not null

	union all

	select	-1				as SKOrder
		,	-1				as ADLSBatchID
		,	'19000101'		as ADLSTimestamp
		,	-1				as LZBatchID
		,	@BatchID		as DWBatchID
		,	''				as DWHash
		,	-1				as KeyOrder
		,	'N/A'			as SFDCOrderNumber
		,	null			as SFDCOrderName
		,	null			as AMRDate
		,	null			as CancellationDate
		,	null			as CCADate
		,	null			as ShipmentDate
		,	null			as SubmitDate
		,	null			as RejectedImpressionsDate
		,	null			as CCUDDate
		,	null			as CCAADate
		,	null			as ClinicalHoldDate
		,	null			as ProductType
		,	null			as AdvantageRebatePeriod
		,	null			as AdvantageRebateQualifiedFlag
		,	null			as TreatmentCategory
		,	-1				as SKContact
		,	-1				as SKAccountTreatmentLocation
		,	-1				as SKAccountShipTo
		,	-1				as SKAccountBillTo
		,	-1				as SKAccountSoldTo
		,	-1				as SKAccountScanOffice
		,	-1				as SKAccountPayer
		,	null			as PatientSFDCID
		,	null			as PatientGender
		,	null			as PatientAge
		--,	null			as PatientBirthDate
		,	null			as PatientIsArchived
		,	null			as RefinementFeeDate
		,	null			as ListPrice
		,	null			as NetPrice
		,	null			as DiscountAmount
		,	null			as TreatmentID
		,	'N/A'			as CurrencyCode
		,	null			as LICaseSetupDeliverableType
		,	null			as LICaseSetupTreatmentOption
		,	null			as LIAlignerDeliverableType
		,	null			as LIAlignerTreatmentOption
		,	null			as LIAlignerQtyFromSFDC
		,	null			as USListPrice
		,	null			as PaymentTerms
		,	null			as PaymentMethod
		,	null			as HasComplianceIdicator
		,	null			as PatientTypeBrand
		,	null			as PatientType
		,	null			as ScanType
		,	null			as AdditionalAlignersUsed
		,	null			as TreatmentExpiryDate
		,	null			as TreatedArches
		,	null			as UpperQuantity
		,	null			as LowerQuantity
		,	null			as MAF
		,	null			as IDSOrderStatus
		,	-1				as SKPricingGroupTreatLoc 
		,	null			as SubscriptionPackage 
		,	null			as SubscriptionProgram 
		,	null			as LICaseSetupProductCode 
		,	null			as LIAlignerProductCode 
		,	null			as ContractNumber 
		,	null			as WithinRFDDate 
		,	null			as WithinTEDDate 
		,	null			as HoldReason
		,	null			as HoldDate
		,	null			as AARefinementsUsed 
		,	null			as ReplacementsUsed 
		,	null			as SecRegion 
		,	null			as FirstAMRDate 
		,	null			as LastAMRDate 
		,	null			as FirstCCADate 
		,	null			as LastCCADate 

	update DW.Temp_DimOrderSFDC set DWHash =
		convert(char(40),
			hashbytes('SHA1',
							 isnull(convert(nvarchar, SFDCOrderNumber), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SFDCOrderName), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AMRDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CancellationDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CCADate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ShipmentDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SubmitDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, RejectedImpressionsDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CCUDDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CCAADate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ClinicalHoldDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ProductType), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvantageRebatePeriod), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvantageRebateQualifiedFlag), N'N/A')
					+ N'|' + isnull(convert(nvarchar, TreatmentCategory), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKContact), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKAccountTreatmentLocation), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKAccountShipTo), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKAccountBillTo), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKAccountSoldTo), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKAccountScanOffice), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKAccountPayer), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PatientSFDCID), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PatientGender), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PatientAge), N'N/A')
					--+ N'|' + isnull(convert(nvarchar, PatientBirthDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PatientIsArchived), N'N/A')
					+ N'|' + isnull(convert(nvarchar, RefinementFeeDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ListPrice), N'N/A')
					+ N'|' + isnull(convert(nvarchar, NetPrice), N'N/A')
					+ N'|' + isnull(convert(nvarchar, DiscountAmount), N'N/A')
					+ N'|' + isnull(convert(nvarchar, TreatmentID), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CurrencyCode), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LICaseSetupDeliverableType), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LICaseSetupTreatmentOption), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LIAlignerDeliverableType), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LIAlignerTreatmentOption), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LIAlignerQtyFromSFDC), N'N/A')
					+ N'|' + isnull(convert(nvarchar, USListPrice), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PaymentTerms), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PaymentMethod), N'N/A')
					+ N'|' + isnull(convert(nvarchar, HasComplianceIdicator), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PatientTypeBrand), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PatientType), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ScanType), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdditionalAlignersUsed), N'N/A')
					+ N'|' + isnull(convert(nvarchar, TreatmentExpiryDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, TreatedArches), N'N/A')
					+ N'|' + isnull(convert(nvarchar, UpperQuantity), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LowerQuantity), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MAF), N'N/A')
					+ N'|' + isnull(convert(nvarchar, IDSOrderStatus), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SKPricingGroupTreatLoc), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SubscriptionPackage), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SubscriptionProgram), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LICaseSetupProductCode), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LIAlignerProductCode), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ContractNumber), N'N/A')
					+ N'|' + isnull(convert(nvarchar, WithinRFDDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, WithinTEDDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, HoldReason), N'N/A')
					+ N'|' + isnull(convert(nvarchar, HoldDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AARefinementsUsed), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ReplacementsUsed), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
					+ N'|' + isnull(convert(nvarchar, FirstAMRDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LastAMRDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, FirstCCADate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LastCCADate), N'N/A')

			)
		, 2)
	where SKOrder != -1

	if @IsFullLoad = 0
	begin
		update DW.DimOrderSFDC
			set	ADLSBatchID = src.ADLSBatchID
			,	ADLSTimestamp = src.ADLSTimestamp
			,	LZBatchID = src.LZBatchID
			,	DWBatchID = src.DWBatchID
			,	DWHash = src.DWHash
			,	SFDCOrderNumber = src.SFDCOrderNumber
			,	SFDCOrderName = src.SFDCOrderName
			,	AMRDate = src.AMRDate
			,	CancellationDate = src.CancellationDate
			,	CCADate = src.CCADate
			,	ShipmentDate = src.ShipmentDate
			,	SubmitDate = src.SubmitDate
			,	RejectedImpressionsDate = src.RejectedImpressionsDate
			,	CCUDDate = src.CCUDDate
			,	CCAADate = src.CCAADate
			,	ClinicalHoldDate = src.ClinicalHoldDate
			,	ProductType = src.ProductType
			,	AdvantageRebatePeriod = src.AdvantageRebatePeriod
			,	AdvantageRebateQualifiedFlag = src.AdvantageRebateQualifiedFlag
			,	TreatmentCategory = src.TreatmentCategory
			,	SKContact = src.SKContact
			,	SKAccountTreatmentLocation = src.SKAccountTreatmentLocation
			,	SKAccountShipTo = src.SKAccountShipTo
			,	SKAccountBillTo = src.SKAccountBillTo
			,	SKAccountSoldTo = src.SKAccountSoldTo
			,	SKAccountScanOffice = src.SKAccountScanOffice
			,	SKAccountPayer = src.SKAccountPayer
			,	PatientSFDCID = src.PatientSFDCID
			,	PatientGender = src.PatientGender
			,	PatientAge = src.PatientAge
			--,	PatientBirthDate = src.PatientBirthDate
			,	PatientIsArchived = src.PatientIsArchived
			,	RefinementFeeDate = src.RefinementFeeDate
			,	ListPrice = src.ListPrice
			,	NetPrice = src.NetPrice
			,	DiscountAmount = src.DiscountAmount
			,	TreatmentID = src.TreatmentID
			,	CurrencyCode = src.CurrencyCode
			,	LICaseSetupDeliverableType = src.LICaseSetupDeliverableType
			,	LICaseSetupTreatmentOption = src.LICaseSetupTreatmentOption
			,	LIAlignerDeliverableType = src.LIAlignerDeliverableType
			,	LIAlignerTreatmentOption = src.LIAlignerTreatmentOption
			,	LIAlignerQtyFromSFDC = src.LIAlignerQtyFromSFDC
			,	USListPrice = src.USListPrice
			,	PaymentTerms = src.PaymentTerms
			,	PaymentMethod = src.PaymentMethod
			,	HasComplianceIdicator = src.HasComplianceIdicator
			,	PatientTypeBrand = src.PatientTypeBrand
			,	PatientType = src.PatientType
			,	ScanType = src.ScanType
			,	AdditionalAlignersUsed = src.AdditionalAlignersUsed 
			,	TreatmentExpiryDate = src.TreatmentExpiryDate
			,	TreatedArches = src.TreatedArches 
			,	UpperQuantity = src.UpperQuantity 
			,	LowerQuantity = src.LowerQuantity 
			,	MAF = src.MAF
			,	IDSOrderStatus = src.IDSOrderStatus
			,	SKPricingGroupTreatLoc  = src.SKPricingGroupTreatLoc 
			,	SubscriptionPackage  = src.SubscriptionPackage 
			,	SubscriptionProgram  = src.SubscriptionProgram 
			,	LICaseSetupProductCode  = src.LICaseSetupProductCode 
			,	LIAlignerProductCode  = src.LIAlignerProductCode 
			,	ContractNumber  = src.ContractNumber 
			,	WithinRFDDate  = src.WithinRFDDate 
			,	WithinTEDDate  = src.WithinTEDDate 
			,	HoldReason		= src.HoldReason
			,	HoldDate		= src.HoldDate
			,	AARefinementsUsed  = src.AARefinementsUsed 
			,	ReplacementsUsed  = src.ReplacementsUsed 
			,	SecRegion  = src.SecRegion 
			,	FirstAMRDate  = src.FirstAMRDate 
			,	LastAMRDate  = src.LastAMRDate 
			,	FirstCCADate  = src.FirstCCADate 
			,	LastCCADate  = src.LastCCADate 

		from DW.Temp_DimOrderSFDC src
		where DW.DimOrderSFDC.SKOrder = src.SKOrder
			and DW.DimOrderSFDC.DWHash != src.DWHash
		option (label = 'DW.LoadDimOrderSFDC_Update');
	
		exec CTRL.GetLastRowCount @Label = 'DW.LoadDimOrderSFDC_Update', @rc = @RowsUpdated out

		insert into DW.DimOrderSFDC (
				SKOrder
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyOrder
			,	SFDCOrderNumber
			,	SFDCOrderName
			,	AMRDate
			,	CancellationDate
			,	CCADate
			,	ShipmentDate
			,	SubmitDate
			,	RejectedImpressionsDate
			,	CCUDDate
			,	CCAADate
			,	ClinicalHoldDate
			,	ProductType
			,	AdvantageRebatePeriod
			,	AdvantageRebateQualifiedFlag
			,	TreatmentCategory
			,	SKContact
			,	SKAccountTreatmentLocation
			,	SKAccountShipTo
			,	SKAccountBillTo
			,	SKAccountSoldTo
			,	SKAccountScanOffice
			,	SKAccountPayer
			,	PatientSFDCID
			,	PatientGender
			,	PatientAge
			--,	PatientBirthDate
			,	PatientIsArchived
			,	RefinementFeeDate
			,	ListPrice
			,	NetPrice
			,	DiscountAmount
			,	TreatmentID
			,	CurrencyCode
			,	LICaseSetupDeliverableType
			,	LICaseSetupTreatmentOption
			,	LIAlignerDeliverableType
			,	LIAlignerTreatmentOption
			,	LIAlignerQtyFromSFDC
			,	USListPrice
			,	PaymentTerms
			,	PaymentMethod
			,	HasComplianceIdicator
			,	PatientTypeBrand
			,	PatientType
			,	ScanType
			,	AdditionalAlignersUsed
			,	TreatmentExpiryDate
			,	TreatedArches
			,	UpperQuantity
			,	LowerQuantity
			,	MAF
			,	IDSOrderStatus
			,	SKPricingGroupTreatLoc 
			,	SubscriptionPackage 
			,	SubscriptionProgram 
			,	LICaseSetupProductCode 
			,	LIAlignerProductCode 
			,	ContractNumber 
			,	WithinRFDDate 
			,	WithinTEDDate 
			,	HoldReason
			,	HoldDate
			,	AARefinementsUsed 
			,	ReplacementsUsed 
			,	SecRegion 
			,	FirstAMRDate 
			,	LastAMRDate 
			,	FirstCCADate 
			,	LastCCADate 
		)
		select	src.SKOrder
			,	src.ADLSBatchID
			,	src.ADLSTimestamp
			,	src.LZBatchID
			,	src.DWBatchID
			,	src.DWHash
			,	src.KeyOrder
			,	src.SFDCOrderNumber
			,	src.SFDCOrderName
			,	src.AMRDate
			,	src.CancellationDate
			,	src.CCADate
			,	src.ShipmentDate
			,	src.SubmitDate
			,	src.RejectedImpressionsDate
			,	src.CCUDDate
			,	src.CCAADate
			,	src.ClinicalHoldDate
			,	src.ProductType
			,	src.AdvantageRebatePeriod
			,	src.AdvantageRebateQualifiedFlag
			,	src.TreatmentCategory
			,	src.SKContact
			,	src.SKAccountTreatmentLocation
			,	src.SKAccountShipTo
			,	src.SKAccountBillTo
			,	src.SKAccountSoldTo
			,	src.SKAccountScanOffice
			,	src.SKAccountPayer
			,	src.PatientSFDCID
			,	src.PatientGender
			,	src.PatientAge
			--,	src.PatientBirthDate
			,	src.PatientIsArchived
			,	src.RefinementFeeDate
			,	src.ListPrice
			,	src.NetPrice
			,	src.DiscountAmount
			,	src.TreatmentID
			,	src.CurrencyCode
			,	src.LICaseSetupDeliverableType
			,	src.LICaseSetupTreatmentOption
			,	src.LIAlignerDeliverableType
			,	src.LIAlignerTreatmentOption
			,	src.LIAlignerQtyFromSFDC
			,	src.USListPrice
			,	src.PaymentTerms
			,	src.PaymentMethod
			,	src.HasComplianceIdicator
			,	src.PatientTypeBrand
			,	src.PatientType
			,	src.ScanType
			,	src.AdditionalAlignersUsed
			,	src.TreatmentExpiryDate
			,	src.TreatedArches
			,	src.UpperQuantity
			,	src.LowerQuantity
			,	src.MAF
			,	src.IDSOrderStatus
			,	src.SKPricingGroupTreatLoc 
			,	src.SubscriptionPackage 
			,	src.SubscriptionProgram 
			,	src.LICaseSetupProductCode 
			,	src.LIAlignerProductCode 
			,	src.ContractNumber 
			,	src.WithinRFDDate 
			,	src.WithinTEDDate 
			,	src.HoldReason 
			,	src.HoldDate 
			,	src.AARefinementsUsed 
			,	src.ReplacementsUsed 
			,	src.SecRegion 
			,	src.FirstAMRDate 
			,	src.LastAMRDate 
			,	src.FirstCCADate 
			,	src.LastCCADate 
		from DW.Temp_DimOrderSFDC src
		where not exists (select * from DW.DimOrderSFDC dst where dst.SKOrder = src.SKOrder)
		option (label = 'DW.LoadDimOrderSFDC_Insert');

		exec CTRL.GetLastRowCount @Label = 'DW.LoadDimOrderSFDC_Insert', @rc = @RowsInserted out

		drop table DW.Temp_DimOrderSFDC
	end
	else
	begin --full load
		if object_id ('DW.DimOrderSFDCPrevious', 'U') is not null
			drop table DW.DimOrderSFDCPrevious

		rename object DW.DimOrderSFDC to DimOrderSFDCPrevious
		rename object DW.Temp_DimOrderSFDC to DimOrderSFDC
		drop table DW.DimOrderSFDCPrevious

		create index IX_DimOrderSFDC_KeyOrder on DW.DimOrderSFDC (KeyOrder)

		select @RowsInserted = count(*)
		from DW.DimOrderSFDC 

	end

	If object_id ('DW.Temp_OrdersSFDCToLoad', 'U') is not null
	Drop table DW.Temp_OrdersSFDCToLoad ;
	
	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
