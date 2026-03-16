CREATE PROC [DW].[LoadDimAccount] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimAccount') is not null
		drop table #TempDimAccount

	create table #TempDimAccount with (distribution = round_robin, heap) as 
	select	a.ADLSBatchID						as ADLSBatchID
		,	a.ADLSTimestamp						as ADLSTimestamp
		,	a.LZBatchID							as LZBatchID
		,	convert(char(40), '')				as DWHash
		
		,	hub.SKAccount						as SKAccount
		,	a.ID								as KeyAccount

		,	a.Account_Number__c					as AccountNumber
		,	a.Name								as AccountName
		,	a.OwnerId							as OwnerID
		,	a.ParentId							as ParentAccountID
		,	p.Account_Number__c					as ParentAccountNumber
		,	a.Mailing_Name__c					as MailingName
		,	isnull(rt.Name, N'Unknown')			as RecordType
		,	a.Type								as AccountType
		,	a.Phone								as Phone
		,	a.Fax								as Fax
		,	a.Website							as Website
		,	a.Email__c							as Email
		,	a.Notification_Email__c				as NotificationEmail
		,	a.Customer_Group__c					as CustomerGroup
		,	a.ShippingCity						as ShippingCity
		,	a.ShippingCountry					as ShippingCountry
		,	a.ShippingCountryCode				as ShippingCountryCode
		,	a.ShippingStateCode					as ShippingStateCode
		,	a.ShippingState						as ShippingState
		,	a.ShippingPostalCode				as ShippingPostalCode
		,	gh.CountryGroup						as ShippingCountryGroup
		,	gh.RegionPC							as ShippingRegionPC
		,	gh.RegionGroup						as ShippingRegionGroup
		,	gh.GlobalRegion						as ShippingGlobalRegion
		,	a.Shipping_County__c				as ShippingCounty
		,	a.Address_Street_1__c				as AddressStreet1
		,	a.Address_Street_2__c				as AddressStreet2
		,	a.Address_Street_3__c				as AddressStreet3
		,	a.Address_Street_4__c				as AddressStreet4
		,	a.Account_Currency__c				as Currency
		,	a.Account_Status__c					as AccountStatus
		,	a.Status_Reason__c					as AccountStatusReason
		,	a.Line_of_Business__c				as LineOfBusiness
		,	a.Business_Unit__c					as BusinessUnit
		,	a.Treatment_Team__c					as TreatTeam
		,	a.Doctor_Locator__c					as DoctorLocator
		,	a.Indirect_Customer_Number__c		as IndirectCustomerNumber
		,	a.Longitude__c						as Longitude
		,	a.Latitude__c						as Lattitude
		,	a.Scanner_Type__c					as ScannerType
		,	a.MAT_ID__c							as MATID
		,	a.Account_Sub_Type__c				as SubType
		,	isnull(dma.MetroArea, N'Unknown')	as MSA
		,	isnull(dma.DMA, N'Unknown')			as DMA
		,	a.Group_Account_Is_Targetable__c	as GroupAccountIsTargetable
		,	a.Invisalign_Sales_Channel__c		as InvisalignChannel
		,	a.Study_Group__c					as StudyGroupName
		,	a.DSO_Private_Practice__c			as PrivatePractice
		,	a.Translated_City__c				as TranslatedCity
		,	a.Translated_State__c				as TranslatedState
		,	a.Translated_Name2__c				as TranslatedDoctorName
		,	a.Translated_Name__c				as TranslatedName
		,	a.Special_account__c				as SpecialAccount
		,	a.Billing_Language__c				as BillingLanguage
		,	a.CreatedDate						as CreatedDate
		,	a.LastModifiedDate					as ModifiedDate
		,	a.Contact_Preference__c				as ContactPreference
		,	gh.SecRegion						as SecRegion
		,	a.Pricing_Group__c					as PricingGroupC
		,	a.Account_Segmentation__c			as AccountSegmentation
		,	a.Account_Accepted_Programs__c		as AcceptedPrograms
		,	hub1.SKAccount 						as SKParentLevel1
		,	hub2.SKAccount 						as SKParentLevel2
		,	hub3.SKAccount 						as SKParentLevel3
		,	ia.TerritoryNameL1 					as InvTerritoryL1
		,	ia.OwnerUserNameL1 					as InvTerritoryOwnerL1
		,	ia.TerritoryNameL2 					as InvTerritoryL2
		,	ia.OwnerUserNameL2 					as InvTerritoryOwnerL2
		,	ia.TerritoryNameL3 					as InvTerritoryL3
		,	ia.OwnerUserNameL3 					as InvTerritoryOwnerL3
		,	ia.TerritoryNameL4 					as InvTerritoryL4
		,	ia.OwnerUserNameL4 					as InvTerritoryOwnerL4
		,	ia.TerritoryNameL5 					as InvTerritoryL5
		,	ia.OwnerUserNameL5 					as InvTerritoryOwnerL5
		,	ia.TerritoryNameL6 					as InvTerritoryL6
		,	ia.OwnerUserNameL6 					as InvTerritoryOwnerL6
		,	ia.TerritoryNameL7 					as InvTerritoryL7
		,	ia.OwnerUserNameL7 					as InvTerritoryOwnerL7
	from SrcSFDC.Account a
	inner join DW.HubAccount hub on hub.KeyAccount = a.Id
	left join (select KeyAccount, KeyTerritory from (select ObjectId as KeyAccount, Territory2Id as KeyTerritory
	, row_number() over (partition by ObjectId order by LastModifiedDate desc) as rn 
	from SrcSFDC.ObjectTerritory2Association) ota where rn = 1) ota on ota.KeyAccount = hub.KeyAccount
	left join DW.DimTerritoryHierarchy ia on ia.KeyTerritory = ota.KeyTerritory 
													and ia.TerritoryType = 'Invisalign'
	left join SrcSFDC.Account p on a.ParentID = p.ID
	left join DW.HubAccount hub1 on hub1.KeyAccount = p.Id
	left join SrcSFDC.Account p2 on p.ParentID = p2.ID
	left join DW.HubAccount hub2 on hub2.KeyAccount = p2.Id
	left join SrcSFDC.Account p3 on p2.ParentID = p3.ID
	left join DW.HubAccount hub3 on hub3.KeyAccount = p3.Id
	left join SrcSFDC.RecordType rt on rt.ID = a.RecordTypeId
	left join Custom.GeographyHierarchy gh on gh.CountryCode=a.ShippingCountryCode
	left join Custom.MSA_DMA dma on left(ltrim(a.ShippingPostalCode), 5) = dma.PostalCode 
									and gh.GlobalRegion = 'Americas' 
									and gh.CountryCode = 'US'
	--where a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DW.DimAccount)

	update #TempDimAccount set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						  isnull(convert(nvarchar, AccountNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AccountName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, OwnerID), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ParentAccountID), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ParentAccountNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, MailingName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, RecordType), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AccountType), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Phone), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Fax), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Website), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Email), N'N/A')
				  + N'|' + isnull(convert(nvarchar, NotificationEmail), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CustomerGroup), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingCity), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingCountry), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingCountryCode), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingStateCode), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingState), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingPostalCode), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingCountryGroup), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingRegionPC), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingRegionGroup), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingGlobalRegion), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ShippingCounty), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AddressStreet1), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AddressStreet2), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AddressStreet3), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AddressStreet4), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Currency), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AccountStatus), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AccountStatusReason), N'N/A')
				  + N'|' + isnull(convert(nvarchar, LineOfBusiness), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BusinessUnit), N'N/A')
				  + N'|' + isnull(convert(nvarchar, TreatTeam), N'N/A')
				  + N'|' + isnull(convert(nvarchar, DoctorLocator), N'N/A')
				  + N'|' + isnull(convert(nvarchar, IndirectCustomerNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Longitude), N'N/A')
				  + N'|' + isnull(convert(nvarchar, Lattitude), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ScannerType), N'N/A')
				  + N'|' + isnull(convert(nvarchar, MATID), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SubType), N'N/A')
				  + N'|' + isnull(convert(nvarchar, MSA), N'N/A')
				  + N'|' + isnull(convert(nvarchar, DMA), N'N/A')
				  + N'|' + isnull(convert(nvarchar, GroupAccountIsTargetable), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvisalignChannel), N'N/A')
				  + N'|' + isnull(convert(nvarchar, StudyGroupName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PrivatePractice), N'N/A')
				  + N'|' + isnull(convert(nvarchar, TranslatedCity), N'N/A')
				  + N'|' + isnull(convert(nvarchar, TranslatedState), N'N/A')
				  + N'|' + isnull(convert(nvarchar, TranslatedDoctorName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, TranslatedName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SpecialAccount), N'N/A')
				  + N'|' + isnull(convert(nvarchar, BillingLanguage), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CreatedDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ModifiedDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ContactPreference), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PricingGroupC), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AccountSegmentation), N'N/A')
				  + N'|' + isnull(convert(nvarchar, AcceptedPrograms), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKParentLevel1), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKParentLevel2), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SKParentLevel3), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryL1), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryOwnerL1), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryL2), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryOwnerL2), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryL3), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryOwnerL3), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryL4), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryOwnerL4), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryL5), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryOwnerL5), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryL6), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryOwnerL6), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryL7), N'N/A')
				  + N'|' + isnull(convert(nvarchar, InvTerritoryOwnerL7), N'N/A')
				)
			, 2)

	if not exists (select * from DW.DimAccount where SKAccount = -1)
	begin
		declare @Hash char(40) = ''

		insert into DW.DimAccount (
				SKAccount
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyAccount
			,	AccountNumber
			,	AccountName
			,	OwnerID
			,	ParentAccountID
			,	ParentAccountNumber
			,	MailingName
			,	RecordType
			,	AccountType
			,	Phone
			,	Fax
			,	Website
			,	Email
			,	NotificationEmail
			,	CustomerGroup
			,	ShippingCity
			,	ShippingCountry
			,	ShippingCountryCode
			,	ShippingStateCode
			,	ShippingState
			,	ShippingPostalCode
			,	ShippingCountryGroup
			,	ShippingRegionPC
			,	ShippingRegionGroup
			,	ShippingGlobalRegion
			,	ShippingCounty
			,	AddressStreet1
			,	AddressStreet2
			,	AddressStreet3
			,	AddressStreet4
			,	Currency
			,	AccountStatus
			,	AccountStatusReason
			,	LineOfBusiness
			,	BusinessUnit
			,	TreatTeam
			,	DoctorLocator
			,	IndirectCustomerNumber
			,	Longitude
			,	Lattitude
			,	ScannerType
			,	MATID
			,	SubType
			,	MSA
			,	DMA
			,	GroupAccountIsTargetable
			,	InvisalignChannel
			,	StudyGroupName
			,	PrivatePractice
			,	TranslatedCity
			,	TranslatedState
			,	TranslatedDoctorName
			,	TranslatedName
			,	SpecialAccount
			,	BillingLanguage
			,	CreatedDate
			,	ModifiedDate
			,	ContactPreference
			,	SecRegion
			,	PricingGroupC
			,	AccountSegmentation
			,	AcceptedPrograms
			,	SKParentLevel1	
			,	SKParentLevel2     
			,	SKParentLevel3     
			,	InvTerritoryL1	
			,	InvTerritoryOwnerL1
			,	InvTerritoryL2    
			,	InvTerritoryOwnerL2
			,	InvTerritoryL3    
			,	InvTerritoryOwnerL3
			,	InvTerritoryL4   
			,	InvTerritoryOwnerL4
			,	InvTerritoryL5    
			,	InvTerritoryOwnerL5
			,	InvTerritoryL6   
			,	InvTerritoryOwnerL6
			,	InvTerritoryL7    
			,	InvTerritoryOwnerL7
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	'19000101'
			,	'19000101'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	-1
			,	-1
			,	-1
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
			,	N'N/A'
		)
	end

	update DW.DimAccount
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash

		,	AccountNumber			=			src.AccountNumber
		,	AccountName				=			src.AccountName
		,	OwnerID					=			src.OwnerID
		,	ParentAccountID			=			src.ParentAccountID
		,	ParentAccountNumber		=			src.ParentAccountNumber
		,	MailingName				=			src.MailingName
		,	RecordType				=			src.RecordType
		,	AccountType				=			src.AccountType
		,	Phone					=			src.Phone
		,	Fax						=			src.Fax
		,	Website					=			src.Website
		,	Email					=			src.Email
		,	NotificationEmail		=			src.NotificationEmail
		,	CustomerGroup			=			src.CustomerGroup
		,	ShippingCity			=			src.ShippingCity
		,	ShippingCountry			=			src.ShippingCountry
		,	ShippingCountryCode		=			src.ShippingCountryCode
		,	ShippingStateCode		=			src.ShippingStateCode
		,	ShippingState			=			src.ShippingState
		,	ShippingPostalCode		=			src.ShippingPostalCode
		,	ShippingCountryGroup	=			src.ShippingCountryGroup
		,	ShippingRegionPC		=			src.ShippingRegionPC
		,	ShippingRegionGroup		=			src.ShippingRegionGroup
		,	ShippingGlobalRegion	=			src.ShippingGlobalRegion
		,	ShippingCounty			=			src.ShippingCounty
		,	AddressStreet1			=			src.AddressStreet1
		,	AddressStreet2			=			src.AddressStreet2
		,	AddressStreet3			=			src.AddressStreet3
		,	AddressStreet4			=			src.AddressStreet4
		,	Currency				=			src.Currency
		,	AccountStatus			=			src.AccountStatus
		,	AccountStatusReason		=			src.AccountStatusReason
		,	LineOfBusiness			=			src.LineOfBusiness
		,	BusinessUnit			=			src.BusinessUnit
		,	TreatTeam				=			src.TreatTeam
		,	DoctorLocator			=			src.DoctorLocator
		,	IndirectCustomerNumber	=			src.IndirectCustomerNumber
		,	Longitude				=			src.Longitude
		,	Lattitude				=			src.Lattitude
		,	ScannerType				=			src.ScannerType
		,	MATID					=			src.MATID
		,	SubType					=			src.SubType
		,	MSA						=			src.MSA
		,	DMA						=			src.DMA
		,	GroupAccountIsTargetable=			src.GroupAccountIsTargetable
		,	InvisalignChannel		=			src.InvisalignChannel
		,	StudyGroupName			=			src.StudyGroupName
		,	PrivatePractice			=			src.PrivatePractice
		,	TranslatedCity			=			src.TranslatedCity
		,	TranslatedState			=			src.TranslatedState
		,	TranslatedDoctorName	=			src.TranslatedDoctorName
		,	TranslatedName			=			src.TranslatedName
		,	SpecialAccount			=			src.SpecialAccount
		,	BillingLanguage			=			src.BillingLanguage
		,	CreatedDate				=			src.CreatedDate
		,	ModifiedDate			=			src.ModifiedDate
		,	ContactPreference		=			src.ContactPreference
		,	SecRegion				=			src.SecRegion
		,	PricingGroupC			=			src.PricingGroupC
		,	AccountSegmentation		=			src.AccountSegmentation
		,	AcceptedPrograms		=			src.AcceptedPrograms
		,	SKParentLevel1			=			src.SKParentLevel1
		,	SKParentLevel2     		=			src.SKParentLevel2
		,	SKParentLevel3     		=			src.SKParentLevel3
		,	InvTerritoryL1			=			src.InvTerritoryL1
		,	InvTerritoryOwnerL1		=			src.InvTerritoryOwnerL1
		,	InvTerritoryL2			=			src.InvTerritoryL2
		,	InvTerritoryOwnerL2		=			src.InvTerritoryOwnerL2
		,	InvTerritoryL3			=			src.InvTerritoryL3
		,	InvTerritoryOwnerL3		=			src.InvTerritoryOwnerL3
		,	InvTerritoryL4			=			src.InvTerritoryL4
		,	InvTerritoryOwnerL4		=			src.InvTerritoryOwnerL4
		,	InvTerritoryL5			=			src.InvTerritoryL5
		,	InvTerritoryOwnerL5		=			src.InvTerritoryOwnerL5
		,	InvTerritoryL6			=			src.InvTerritoryL6
		,	InvTerritoryOwnerL6		=			src.InvTerritoryOwnerL6
		,	InvTerritoryL7			=			src.InvTerritoryL7
		,	InvTerritoryOwnerL7		=			src.InvTerritoryOwnerL7
	from #TempDimAccount src
	where DW.DimAccount.SKAccount = src.SKAccount
		and DW.DimAccount.DWHash != src.DWHash
	option (label = 'DW.LoadDimAccount_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimAccount_Update', @rc = @RowsUpdated out

	insert into DW.DimAccount (
			SKAccount
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyAccount
		,	AccountNumber
		,	AccountName
		,	OwnerID
		,	ParentAccountID
		,	ParentAccountNumber
		,	MailingName
		,	RecordType
		,	AccountType
		,	Phone
		,	Fax
		,	Website
		,	Email
		,	NotificationEmail
		,	CustomerGroup
		,	ShippingCity
		,	ShippingCountry
		,	ShippingCountryCode
		,	ShippingStateCode
		,	ShippingState
		,	ShippingPostalCode
		,	ShippingCountryGroup
		,	ShippingRegionPC
		,	ShippingRegionGroup
		,	ShippingGlobalRegion
		,	ShippingCounty
		,	AddressStreet1
		,	AddressStreet2
		,	AddressStreet3
		,	AddressStreet4
		,	Currency
		,	AccountStatus
		,	AccountStatusReason
		,	LineOfBusiness
		,	BusinessUnit
		,	TreatTeam
		,	DoctorLocator
		,	IndirectCustomerNumber
		,	Longitude
		,	Lattitude
		,	ScannerType
		,	MATID
		,	SubType
		,	MSA
		,	DMA
		,	GroupAccountIsTargetable
		,	InvisalignChannel
		,	StudyGroupName
		,	PrivatePractice
		,	TranslatedCity
		,	TranslatedState
		,	TranslatedDoctorName
		,	TranslatedName
		,	SpecialAccount
		,	BillingLanguage
		,	CreatedDate
		,	ModifiedDate
		,	ContactPreference
		,	SecRegion
		,	PricingGroupC
		,	AccountSegmentation
		,	AcceptedPrograms
		,	SKParentLevel1	
		,	SKParentLevel2     
		,	SKParentLevel3     
		,	InvTerritoryL1	
		,	InvTerritoryOwnerL1
		,	InvTerritoryL2    
		,	InvTerritoryOwnerL2
		,	InvTerritoryL3    
		,	InvTerritoryOwnerL3
		,	InvTerritoryL4   
		,	InvTerritoryOwnerL4
		,	InvTerritoryL5    
		,	InvTerritoryOwnerL5
		,	InvTerritoryL6   
		,	InvTerritoryOwnerL6
		,	InvTerritoryL7    
		,	InvTerritoryOwnerL7
	)
	select	SKAccount
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID
		,	DWHash
		,	KeyAccount
		,	AccountNumber
		,	AccountName
		,	OwnerID
		,	ParentAccountID
		,	ParentAccountNumber
		,	MailingName
		,	RecordType
		,	AccountType
		,	Phone
		,	Fax
		,	Website
		,	Email
		,	NotificationEmail
		,	CustomerGroup
		,	ShippingCity
		,	ShippingCountry
		,	ShippingCountryCode
		,	ShippingStateCode
		,	ShippingState
		,	ShippingPostalCode
		,	ShippingCountryGroup
		,	ShippingRegionPC
		,	ShippingRegionGroup
		,	ShippingGlobalRegion
		,	ShippingCounty
		,	AddressStreet1
		,	AddressStreet2
		,	AddressStreet3
		,	AddressStreet4
		,	Currency
		,	AccountStatus
		,	AccountStatusReason
		,	LineOfBusiness
		,	BusinessUnit
		,	TreatTeam
		,	DoctorLocator
		,	IndirectCustomerNumber
		,	Longitude
		,	Lattitude
		,	ScannerType
		,	MATID
		,	SubType
		,	MSA
		,	DMA
		,	GroupAccountIsTargetable
		,	InvisalignChannel
		,	StudyGroupName
		,	PrivatePractice
		,	TranslatedCity
		,	TranslatedState
		,	TranslatedDoctorName
		,	TranslatedName
		,	SpecialAccount
		,	BillingLanguage
		,	CreatedDate
		,	ModifiedDate
		,	ContactPreference
		,	SecRegion
		,	PricingGroupC
		,	AccountSegmentation
		,	AcceptedPrograms
		,	SKParentLevel1	
		,	SKParentLevel2     
		,	SKParentLevel3     
		,	InvTerritoryL1	
		,	InvTerritoryOwnerL1
		,	InvTerritoryL2    
		,	InvTerritoryOwnerL2
		,	InvTerritoryL3    
		,	InvTerritoryOwnerL3
		,	InvTerritoryL4   
		,	InvTerritoryOwnerL4
		,	InvTerritoryL5    
		,	InvTerritoryOwnerL5
		,	InvTerritoryL6   
		,	InvTerritoryOwnerL6
		,	InvTerritoryL7    
		,	InvTerritoryOwnerL7
	from #TempDimAccount src
	where not exists(select * from DW.DimAccount dst where dst.SKAccount = src.SKAccount)
	option (label = 'DW.LoadDimAccount_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimAccount_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end

