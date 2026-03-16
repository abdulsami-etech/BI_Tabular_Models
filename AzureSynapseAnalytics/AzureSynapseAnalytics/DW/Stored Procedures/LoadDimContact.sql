CREATE PROC [DW].[LoadDimContact] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	IF OBJECT_ID(N'tempdb..#SrcIDS_tblCnAccounts') IS NOT NULL DROP TABLE #SrcIDS_tblCnAccounts
	CREATE TABLE #SrcIDS_tblCnAccounts WITH (distribution = round_robin, heap) AS
	SELECT * FROM (select master_user_id
				,	contact_sfid
				,	_Region
				,   row_number() over (partition by master_user_id order by case when _Region = 'Global' then 1 else 0 end) as rn
				FROM SrcIDS.tblCnAccounts) a where rn = 1;
				
	if object_id('tempdb..#TempDimContact') is not null
		drop table #TempDimContact
				
	create table #TempDimContact with (distribution = round_robin, heap) as 
	select	c.ADLSBatchID															as ADLSBatchID
		,	c.ADLSTimestamp															as ADLSTimestamp
		,	c.LZBatchID																as LZBatchID
		,	convert(char(40), '')													as DWHash
		
		,	hub.SKContact															as SKContact
		,	c.Id																	as KeyContact

		,	hubAccount.SKAccount													as PrimarySKAccount
		,	c.AccountId																as PrimaryAccountID
		,	convert(nvarchar(40), c.Account_Number__c)								as PrimaryAccountNumber
		,	convert(nvarchar(40), c.Contact_Id__c)									as ContactNumber
		,	c.OwnerId																as OwnerID
		,	convert(nvarchar(121), c.LastName + isnull(N', ' + c.FirstName, N''))	as ContactName
		,	rt.Name																	as RecordType
		,	c.Contact_Type__c														as ContactType
		,	convert(nvarchar(50), c.Line_of_Business__c)							as LineofBusiness
		,	c.Salutation															as Salutation
		,	c.FirstName																as ContactFirstName
		,	c.LastName																as ContactLastName
		,	convert(nvarchar(50), c.Professional_Category__c)						as ProfessionalCategory
		,	c.Contact_Status__c														as Status
		,	c.Status_Reason__c														as StatusReason
		,	c.LeadSource															as LeadSource
		,	c.Phone																	as Phone
		,	c.MobilePhone															as Mobile
		,	c.Fax																	as Fax
		,	c.OtherPhone															as OtherPhone
		,	c.Email																	as Email
		,	c.HasOptedOutOfEmail													as EmailOptout
		,	c.DoNotCall																as DoNotCall
		,	c.HasOptedOutOfFax														as FaxOptOut
		,	c.Mail_Opt_Out__c														as MailOptOut
		,	nullif(c.Mailing_Street_1__c, N'0')										as MailingStreet1
		,	nullif(c.Mailing_Street_2__c, N'0')										as MailingStreet2
		,	nullif(c.Mailing_Street_3__c, N'0')										as MailingStreet3
		,	c.MailingCity															as MailingCity
		,	convert(nvarchar(50), c.MailingState)									as MailingState
		,	c.MailingPostalCode														as MailingPostalCode
		,	convert(nvarchar(50), c.MailingCountry)									as MailingCountry
		,	c.MailingCountryCode													as MailingCountryCode				
		,	gh.CountryGroup															as MailingCountryGroup
		,	gh.RegionPC																as MailingRegionPC
		,	gh.RegionGroup															as MailingRegionGroup
		,	gh.GlobalRegion															as MailingGlobalRegion
		,	convert(nvarchar(2), c.Alumni_state__c)									as AlumniStateCode
		,	c.Alumni_of_University__c												as AlumniUniversity
		,	try_convert(int, c.CE_Hours__c)											as CEHours
		,	convert(date, c.Certification_Date__c)									as CertificationDate
		,	c.Certification_Location__c												as CertificationLocation
		,	c.Clinician_ID__c														as ClinID
		,	convert(nvarchar(8), c.Gender__c)										as Gender
		,	try_convert(int, c.Graduation_Year__c)									as GraduationYear
		,	convert(date, c.Reactivation_Date__c)									as ReactivationDate
		,	convert(nvarchar(255), c.Product_Eligibility__c)						as ProductEligibility
		,	c.Time_Zone__c															as TimeZone
		,	c.CreatedDate															as CreatedDate
		,	c.LastModifiedDate														as ModifiedDate
		,	case when c.Teen_Provider__c = 1
				then N'Yes'
				else N'No'
			end																		as TeenProviderFlag
		,	loyalty.CurrentProgramCode												as AdvCurrentAdvantageProgram
		,	loyalty.LoyaltyLevel													as AdvCurrentAdvantageLevel
		,	loyalty.CurrentPoints													as AdvCurrentAdvantagePoints
		,	loyalty.AdditionalPointsForNextLevel									as AdvAdditionalPointsForNextLevel
		,	loyalty.CurrentAdvantageRegistrationStatus								as AdvRegistrationStatus
		,	loyalty.CumulativeTier													as AdvCumulativeTier
		--,	as FBURL
		--,	as FBProfileVersion
		--,	as TwitterURL
		--,	as YTURL
		--,	as FourSquareURL
		,	convert(nvarchar(100), cclab.ContactClincheckLab)						as ClincheckLab
		,	iodt.ContactIOScanEnabledDate											as IOScanEnabledDate
		,	case when c.EPT_T_C__c = 1
				then N'Yes' 
				else N'No' 
			end																		as EPTOptIn
		,	convert(date, c.Fusion_Contract_Date__c)								as iTeroFusionContractDate
		,	c.Private_Practice_ClinId__c											as PrivatePracticeClinID
		,	c.TPS_Terms_and_Condition_flag__c										as TPSTermsCondition
		,	prf.ContactProfileCreationDate											as ProfileCreationDate
		,	isnull(c.MAT_Contact_ID__c,cfl.ContactID)								as MATContactID
		,	EMEA_Segmentation__c													as EMEASegmentation
		,	Doctor_Segment__c														as DoctorSegment
		,	DimReg.SecRegion														as SecRegion
		,	c.Doctor_Accepted_Programs__c											as AcceptedPrograms
	from SrcSFDC.Contact c
	inner join DW.HubContact hub on hub.KeyContact = c.Id
	left join DW.HubAccount hubAccount on hubAccount.keyAccount = c.AccountId
	left join Custom.GeographyHierarchy gh on gh.CountryCode = c.MailingCountryCode
	left join SrcSFDC.RecordType rt on rt.ID = c.RecordTypeId
	left join DW.DimAccount DimReg on DimReg.SKAccount = hubAccount.SKAccount 
	left join (
		select top (1) with ties
				l.Apttus_Config2__ContactId__c						as ContactID
			,	l.Apttus_Config2__LoyaltyLevel__c					as LoyaltyLevel
			,	l.Apttus_Config2__Points__c							as CurrentPoints
			,	l.Apttus_Config2__AdditionalPointsForNextLevel__c	as AdditionalPointsForNextLevel
			,	l.Cumulative_Tier__c								as CumulativeTier
			,	pr.Program_Code__c									as CurrentProgramCode
			,	pr.Current_Status__c								as CurrentAdvantageRegistrationStatus
		from SrcSFDC.Apttus_Config2__IncentiveLoyaltyEnrollment__c l
		inner join SrcSFDC.Program_Registration__c pr on l.Program_Registration__c = pr.Id
		where l.Apttus_Config2__Active__c = 'true' 
				and pr.Program_Code__c in ( --logic provided by Swaran
					select Program_Code__c from SrcSFDC.Advantage_Eligibility_Check__c
					union 
					select Loyalty_Code__c from SrcSFDC.APAC_Advantage_Eligibility_Check__c		
				)
		order by row_number() over (
			partition by l.Apttus_Config2__ContactId__c 
			order by 
					case when pr.Current_Status__c = l.Apttus_Config2__CustomerType__c then 0 else 1 end --this logic was provided by Geen, required for EMEA because of NCP
				,	l.LastModifiedDate desc
		)
	) loyalty on loyalty.ContactID = c.Id
	left join (
		select top(1) with ties
				a.contact_sfid
			,	l.name as ContactClincheckLab
		from SrcIDS.tblPuClincheckLabDoctors d
		inner join #SrcIDS_tblCnAccounts a on a.master_user_id = d.master_user_id and a._Region = d._Region
		inner join SrcIDS.tblPuClincheckLabs l on l.id = d.lab_id and l._Region = d._Region
		order by row_number() over (partition by a.contact_sfid order by d.last_assigned_on desc)
	) cclab on cclab.contact_sfid = c.Id
	left join (
		select	a.contact_sfid
			,	convert(date, min(cpd.create_date)) as ContactIOScanEnabledDate
		from SrcIDS.tblCnPilotDoctors cpd
		inner join #SrcIDS_tblCnAccounts a on a.master_user_id = cpd.master_user_id and a._Region = cpd._Region
		where cpd.product = 'intraoral'
		group by a.contact_sfid
	) iodt on iodt.contact_sfid = c.Id
	left join (
		select	cna.contact_sfid
			,	min(p.create_date) as ContactProfileCreationDate
		from srcids.tblPuDoctorProfile p
		inner join #srcids_tblCnAccounts cna on cna.master_user_id = p.master_user_id  and cna._Region = p._Region
		group by cna.contact_sfid
	) prf on prf.contact_sfid = c.Id
	left join (
		select 
			SalesforceContactId, 
			ContactID
			from (select SalesforceContactId, ContactID, row_number() over (partition by SalesforceContactId order by DateUpdated desc) as rn   
				  from SrcMAT.Contact_SalesforceLink
				 ) r
		where r.rn = 1
	) cfl
		on cfl.SalesforceContactId = c.Contact_Id__c
	--where c.ADLSTimestamp >= @LastSuccessfullDWTimestamp--(select isnull(max(ADLSTimestamp), '19000101') from DW.DimContact)

	update #TempDimContact set DWHash=
		convert(char(40),
			hashbytes('SHA1',
							 isnull(convert(nvarchar, PrimarySKAccount), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PrimaryAccountID), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PrimaryAccountNumber), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ContactNumber), N'N/A')
					+ N'|' + isnull(convert(nvarchar, OwnerID), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ContactName), N'N/A')
					+ N'|' + isnull(convert(nvarchar, RecordType), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ContactType), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LineofBusiness), N'N/A')
					+ N'|' + isnull(convert(nvarchar, Salutation), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ContactFirstName), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ContactLastName), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ProfessionalCategory), N'N/A')
					+ N'|' + isnull(convert(nvarchar, Status), N'N/A')
					+ N'|' + isnull(convert(nvarchar, StatusReason), N'N/A')
					+ N'|' + isnull(convert(nvarchar, LeadSource), N'N/A')
					+ N'|' + isnull(convert(nvarchar, Phone), N'N/A')
					+ N'|' + isnull(convert(nvarchar, Mobile), N'N/A')
					+ N'|' + isnull(convert(nvarchar, Fax), N'N/A')
					+ N'|' + isnull(convert(nvarchar, OtherPhone), N'N/A')
					+ N'|' + isnull(convert(nvarchar, Email), N'N/A')
					+ N'|' + isnull(convert(nvarchar, EmailOptout), N'N/A')
					+ N'|' + isnull(convert(nvarchar, DoNotCall), N'N/A')
					+ N'|' + isnull(convert(nvarchar, FaxOptOut), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailOptOut), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingStreet1), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingStreet2), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingStreet3), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingCity), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingState), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingPostalCode), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingCountry), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingCountryCode), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingCountryGroup), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingRegionPC), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingRegionGroup), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MailingGlobalRegion), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AlumniStateCode), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AlumniUniversity), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CEHours), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CertificationDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CertificationLocation), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ClinID), N'N/A')
					+ N'|' + isnull(convert(nvarchar, Gender), N'N/A')
					+ N'|' + isnull(convert(nvarchar, GraduationYear), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ReactivationDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ProductEligibility), N'N/A')
					+ N'|' + isnull(convert(nvarchar, TimeZone), N'N/A')
					+ N'|' + isnull(convert(nvarchar, CreatedDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ModifiedDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, TeenProviderFlag), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvCurrentAdvantageProgram), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvCurrentAdvantageLevel), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvCurrentAdvantagePoints), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvAdditionalPointsForNextLevel), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvRegistrationStatus), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AdvCumulativeTier), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ClincheckLab), N'N/A')
					+ N'|' + isnull(convert(nvarchar, IOScanEnabledDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, EPTOptIn), N'N/A')
					+ N'|' + isnull(convert(nvarchar, iTeroFusionContractDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, PrivatePracticeClinID), N'N/A')
					+ N'|' + isnull(convert(nvarchar, TPSTermsCondition), N'N/A')
					+ N'|' + isnull(convert(nvarchar, ProfileCreationDate), N'N/A')
					+ N'|' + isnull(convert(nvarchar, MATContactID), N'N/A')
					+ N'|' + isnull(convert(nvarchar, EMEASegmentation), N'N/A')
					+ N'|' + isnull(convert(nvarchar, DoctorSegment), N'N/A')
					+ N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
					+ N'|' + isnull(convert(nvarchar, AcceptedPrograms), N'N/A')
				)
			, 2)

	if not exists (select * from DW.DimContact where SKContact = -1)
	begin
		declare @Hash char(40) = ''
			,	@CurrentDate datetime2(7) = getdate()

		insert into DW.DimContact (
				SKContact
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyContact
			,	PrimarySKAccount
			,	PrimaryAccountID
			,	PrimaryAccountNumber
			,	ContactNumber
			,	OwnerID
			,	ContactName
			,	RecordType
			,	ContactType
			,	LineofBusiness
			,	Salutation
			,	ContactFirstName
			,	ContactLastName
			,	ProfessionalCategory
			,	Status
			,	StatusReason
			,	LeadSource
			,	Phone
			,	Mobile
			,	Fax
			,	OtherPhone
			,	Email
			,	EmailOptout
			,	DoNotCall
			,	FaxOptOut
			,	MailOptOut
			,	MailingStreet1
			,	MailingStreet2
			,	MailingStreet3
			,	MailingCity
			,	MailingState
			,	MailingPostalCode
			,	MailingCountry
			,	MailingCountryCode
			,	MailingCountryGroup
			,	MailingRegionPC
			,	MailingRegionGroup
			,	MailingGlobalRegion
			,	AlumniStateCode
			,	AlumniUniversity
			,	CEHours
			,	CertificationDate
			,	CertificationLocation
			,	ClinID
			,	Gender
			,	GraduationYear
			,	ReactivationDate
			,	ProductEligibility
			,	TimeZone
			,	CreatedDate
			,	ModifiedDate
			,	TeenProviderFlag
			,	AdvCurrentAdvantageProgram
			,	AdvCurrentAdvantageLevel
			,	AdvCurrentAdvantagePoints
			,	AdvAdditionalPointsForNextLevel
			,	AdvRegistrationStatus
			,	AdvCumulativeTier
			,	ClincheckLab
			,	IOScanEnabledDate
			,	EPTOptIn
			,	iTeroFusionContractDate
			,	PrivatePracticeClinID
			,	TPSTermsCondition
			,	ProfileCreationDate
			,	MATContactID
			,	EMEASegmentation
			,	DoctorSegment
			,	SecRegion
			,	AcceptedPrograms
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	null
			,	null
			,	null
			,	null
			,	N'N/A'
			,	N'N/A'
			,	null
			,	null
			,	null
			,	null
			,	null
			,	N'N/A'
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	@CurrentDate
			,	@CurrentDate
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
		)
	end

	update DW.DimContact
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	PrimarySKAccount = src.PrimarySKAccount
		,	PrimaryAccountID = src.PrimaryAccountID
		,	PrimaryAccountNumber = src.PrimaryAccountNumber
		,	ContactNumber = src.ContactNumber
		,	OwnerID = src.OwnerID
		,	ContactName = src.ContactName
		,	RecordType = src.RecordType
		,	ContactType = src.ContactType
		,	LineofBusiness = src.LineofBusiness
		,	Salutation = src.Salutation
		,	ContactFirstName = src.ContactFirstName
		,	ContactLastName = src.ContactLastName
		,	ProfessionalCategory = src.ProfessionalCategory
		,	Status = src.Status
		,	StatusReason = src.StatusReason
		,	LeadSource = src.LeadSource
		,	Phone = src.Phone
		,	Mobile = src.Mobile
		,	Fax = src.Fax
		,	OtherPhone = src.OtherPhone
		,	Email = src.Email
		,	EmailOptout = src.EmailOptout
		,	DoNotCall = src.DoNotCall
		,	FaxOptOut = src.FaxOptOut
		,	MailOptOut = src.MailOptOut
		,	MailingStreet1 = src.MailingStreet1
		,	MailingStreet2 = src.MailingStreet2
		,	MailingStreet3 = src.MailingStreet3
		,	MailingCity = src.MailingCity
		,	MailingState = src.MailingState
		,	MailingPostalCode = src.MailingPostalCode
		,	MailingCountry = src.MailingCountry
		,	MailingCountryCode = src.MailingCountryCode
		,	MailingCountryGroup = src.MailingCountryGroup
		,	MailingRegionPC = src.MailingRegionPC
		,	MailingRegionGroup = src.MailingRegionGroup
		,	MailingGlobalRegion = src.MailingGlobalRegion
		,	AlumniStateCode = src.AlumniStateCode
		,	AlumniUniversity = src.AlumniUniversity
		,	CEHours = src.CEHours
		,	CertificationDate = src.CertificationDate
		,	CertificationLocation = src.CertificationLocation
		,	ClinID = src.ClinID
		,	Gender = src.Gender
		,	GraduationYear = src.GraduationYear
		,	ReactivationDate = src.ReactivationDate
		,	ProductEligibility = src.ProductEligibility
		,	TimeZone = src.TimeZone
		,	CreatedDate = src.CreatedDate
		,	ModifiedDate = src.ModifiedDate
		,	TeenProviderFlag = src.TeenProviderFlag
		,	AdvCurrentAdvantageProgram = src.AdvCurrentAdvantageProgram
		,	AdvCurrentAdvantageLevel = src.AdvCurrentAdvantageLevel
		,	AdvCurrentAdvantagePoints = src.AdvCurrentAdvantagePoints
		,	AdvAdditionalPointsForNextLevel = src.AdvAdditionalPointsForNextLevel
		,	AdvRegistrationStatus = src.AdvRegistrationStatus
		,	AdvCumulativeTier = src.AdvCumulativeTier
		,	ClincheckLab = src.ClincheckLab
		,	IOScanEnabledDate = src.IOScanEnabledDate
		,	EPTOptIn = src.EPTOptIn
		,	iTeroFusionContractDate = src.iTeroFusionContractDate
		,	PrivatePracticeClinID = src.PrivatePracticeClinID
		,	TPSTermsCondition = src.TPSTermsCondition
		,	ProfileCreationDate = src.ProfileCreationDate
		,	MATContactID = src.MATContactID
		,	EMEASegmentation=src.EMEASegmentation
		,	DoctorSegment=src.DoctorSegment
		,	SecRegion=src.SecRegion
		,	AcceptedPrograms=src.AcceptedPrograms
	from #TempDimContact src
	where DW.DimContact.SKContact = src.SKContact
		and DW.DimContact.DWHash != src.DWHash
	option (label = 'DW.LoadDimContact_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimContact_Update', @rc = @RowsUpdated out

	insert into DW.DimContact (
			SKContact
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyContact
		,	PrimarySKAccount
		,	PrimaryAccountID
		,	PrimaryAccountNumber
		,	ContactNumber
		,	OwnerID
		,	ContactName
		,	RecordType
		,	ContactType
		,	LineofBusiness
		,	Salutation
		,	ContactFirstName
		,	ContactLastName
		,	ProfessionalCategory
		,	Status
		,	StatusReason
		,	LeadSource
		,	Phone
		,	Mobile
		,	Fax
		,	OtherPhone
		,	Email
		,	EmailOptout
		,	DoNotCall
		,	FaxOptOut
		,	MailOptOut
		,	MailingStreet1
		,	MailingStreet2
		,	MailingStreet3
		,	MailingCity
		,	MailingState
		,	MailingPostalCode
		,	MailingCountry
		,	MailingCountryCode
		,	MailingCountryGroup
		,	MailingRegionPC
		,	MailingRegionGroup
		,	MailingGlobalRegion
		,	AlumniStateCode
		,	AlumniUniversity
		,	CEHours
		,	CertificationDate
		,	CertificationLocation
		,	ClinID
		,	Gender
		,	GraduationYear
		,	ReactivationDate
		,	ProductEligibility
		,	TimeZone
		,	CreatedDate
		,	ModifiedDate
		,	TeenProviderFlag
		,	AdvCurrentAdvantageProgram
		,	AdvCurrentAdvantageLevel
		,	AdvCurrentAdvantagePoints
		,	AdvAdditionalPointsForNextLevel
		,	AdvRegistrationStatus
		,	AdvCumulativeTier
		,	ClincheckLab
		,	IOScanEnabledDate
		,	EPTOptIn
		,	iTeroFusionContractDate
		,	PrivatePracticeClinID
		,	TPSTermsCondition
		,	ProfileCreationDate
		,	MATContactID
		,	EMEASegmentation
		,	DoctorSegment
		,	SecRegion
		,	AcceptedPrograms
	)
	select	src.SKContact
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyContact
		,	src.PrimarySKAccount
		,	src.PrimaryAccountID
		,	src.PrimaryAccountNumber
		,	src.ContactNumber
		,	src.OwnerID
		,	src.ContactName
		,	src.RecordType
		,	src.ContactType
		,	src.LineofBusiness
		,	src.Salutation
		,	src.ContactFirstName
		,	src.ContactLastName
		,	src.ProfessionalCategory
		,	src.Status
		,	src.StatusReason
		,	src.LeadSource
		,	src.Phone
		,	src.Mobile
		,	src.Fax
		,	src.OtherPhone
		,	src.Email
		,	src.EmailOptout
		,	src.DoNotCall
		,	src.FaxOptOut
		,	src.MailOptOut
		,	src.MailingStreet1
		,	src.MailingStreet2
		,	src.MailingStreet3
		,	src.MailingCity
		,	src.MailingState
		,	src.MailingPostalCode
		,	src.MailingCountry
		,	src.MailingCountryCode
		,	src.MailingCountryGroup
		,	src.MailingRegionPC
		,	src.MailingRegionGroup
		,	src.MailingGlobalRegion
		,	src.AlumniStateCode
		,	src.AlumniUniversity
		,	src.CEHours
		,	src.CertificationDate
		,	src.CertificationLocation
		,	src.ClinID
		,	src.Gender
		,	src.GraduationYear
		,	src.ReactivationDate
		,	src.ProductEligibility
		,	src.TimeZone
		,	src.CreatedDate
		,	src.ModifiedDate
		,	src.TeenProviderFlag
		,	src.AdvCurrentAdvantageProgram
		,	src.AdvCurrentAdvantageLevel
		,	src.AdvCurrentAdvantagePoints
		,	src.AdvAdditionalPointsForNextLevel
		,	src.AdvRegistrationStatus
		,	src.AdvCumulativeTier
		,	src.ClincheckLab
		,	src.IOScanEnabledDate
		,	src.EPTOptIn
		,	src.iTeroFusionContractDate
		,	src.PrivatePracticeClinID
		,	src.TPSTermsCondition
		,	src.ProfileCreationDate
		,	src.MATContactID
		,	src.EMEASegmentation
		,	src.DoctorSegment
		,	src.SecRegion
		,	src.AcceptedPrograms
	from #TempDimContact src
	where not exists (select * from DW.DimContact dst where dst.SKContact = src.SKContact)
	option (label = 'DW.LoadDimContact_Insert');

	IF OBJECT_ID(N'tempdb..#SrcIDS_tblCnAccounts') IS NOT NULL DROP TABLE #SrcIDS_tblCnAccounts
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimContact_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
