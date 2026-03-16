CREATE PROC [DWIRIS].[LoadDimTicketComplaint] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimTicketComplaint') is not null
		drop table #TempDimTicketComplaint

-- Get delta rows
	create table #TempDimTicketComplaint with (distribution = round_robin, heap) as 
	select 
			ht.SKTicketComplaint					as SKTicketComplaint
		,	c.ADLSBatchID							as ADLSBatchID
		,	c.ADLSTimestamp							as ADLSTimestamp
		,	c.LZBatchID								as LZBatchID
		,	convert(char(40), '')					as DWHash,
			ht.KeyTicketComplaint					as KeyTicketComplaint,
		   hac.SKAccount							as SKAccount, -- lookup 
		   ha.SKAsset								as SKAsset, -- lookup in HubAsset
		   htp.SKTicket								as SKParentTicket,
		   hu.SKUser								as SKUser,
		   htm.SKTeam								as SKTeam,

		   convert(int, convert(varchar(8), c.CreatedDate, 112))		as CreatedDateKey,
		   c.CreatedDate							as CreatedDate,
		   convert(int, convert(varchar(8), c.ClosedDate, 112))			as ClosedDateKey,
		   c.ClosedDate								as ClosedDate,
		   convert(int, convert(varchar(8), c.ClosedDate, 112))			as ResolvedDateKey,
		   c.ClosedDate								as ResolvedDate,
		   convert(int, convert(varchar(8), c.Cancelled_Date__c, 112))	as CancelledDateKey,
		   c.Cancelled_Date__c						as CancelledDate,

		   con.[Name]								as ContactFullName,
		   c.Issue_Type__c							as IssueType,
		   c.Sub_Issue_Type__c						as SubIssueType,
		   NULL										as IssueAsset,
		   c.LastModifiedDate						as LastModifiedDate,
		   c.Origin									as Origin,
		   c.[Priority]								as [Priority],
		   c.[Status]								as [Status],
		   c.Ticket_Type__c							as TicketType,
		   c.CaseNumber								as TicketNumber,
		   rt.[Name]								as RecordType,
		   own.[Name]								as TicketAssignedTo,
		   u.[Name]									as TicketOpenedBy,

		   convert(nvarchar(4000),NULL) /*cc.CommentBody*/							as AdditionalCommentsOther,
		   convert(nvarchar(4000),NULL) /*c.Additional_Notes__c*/					as AdditionalInformation,
		   u.Username								as ComplaintHandlingAndAssessmentDoneBy,
		   c.[Status]								as ComplaintStatus,
		   substring(c.[Description],1,4000)							as CustomerIssueDescription,
		   NULL /*c.Investigation_Details__c*/		as CustomerServiceInitialInvestigation,
		   NULL										as DidEventResultIn, -- tables Case is mentioned, but no source field posted ?
		   cast(c.Duplicate__c as nvarchar(50))							as DuplicateOf,
		   NULL										as EvaluationImpactLevel,-- no field in source
		   NULL										as HazardSituation,
		   c.CAPA__c								as InvestigationCAPAReference,
		   c.Country_Shipto__c						as InWhatCountry,
		   case when isnull(c.Is_RMA_needed__c,'No') = 'Yes'
				then 1
				else 0
		   end										as IsFurtherInvestigationNeeded,
		   NULL /*c.Initial_Investigation_Roster__c*/	as IsRegulatoryNonConformance, -- no field in source
		   convert(varchar(5),NULL)					as IsReportable,
		   c.Product_Safety__c						as IsSafety, -- no field in source
		   NULL /*c.Initial_Investigation_Roster__c*/	as IsSafetyOrPotentially, -- no field in source
		   c.Is_Valid_Complaint__c /*c.Initial_Investigation_Roster__c*/	as IsValidComplaint,  -- no field in source
		   convert(nvarchar(4000),NULL)					as JustificationReportSummary,
		   c.Investigation_Details__c				as RationaleForFurtherInvestigationCAPANotRequired,
		   NULL										as RiskAnalysisDOC,
		   c.Root_Cause__c							as RootCause,
		   
   		   /* Facts */
		   1										as ComplaintCount,
		   c.Category__c							as Category,
		   c.Complaint_Type__c						as ComplaintType,
		   c.Complaint_Sub_Type__c					as ComplaintSubType,
		   case when gr.Id is not null then 1 else 0 end as [IsInvalid],
		   'SFDC'																as [SourceSystem]
 	from SrcSFDC.[Case] c
	join [DWIRIS].[HubTicketComplaint] ht
		on ht.KeyTicketComplaint = convert(nchar(18),c.Id)
	left join SrcSFDC.Asset ast
			on ast.Id = c.AssetId
	left join [DWIRIS].[HubAsset] ha
			on ha.KeyAsset = isnull(ast.SerialNumber,c.Serial_Number__c)
	/* Added SKTeam */
	left join [DWIRIS].[HubTeam] htm
		on htm.KeyTeam = c.Team_Function__c 
		--and htm.SourceSystemCode = 'SFDC'
	left join [SrcSFDC].[User] u
		on c.CreatedById = u.Id
	left join DW.HubAccount hac
		on hac.KeyAccount = c.AccountID
	left join SrcSFDC.Contact con
		on con.Id = c.ContactId
	left join SrcSFDC.RecordType rt
		on rt.Id = c.RecordTypeId
	left join SrcSFDC.Contact own
		on c.OwnerId = own.Id
	left join [DWIRIS].[HubUser] hu
		on hu.KeyUser = u.Id and hu.SourceSystemCode = 'SFDC'
	/* Parent Ticket */
	left join [DWIRIS].[HubTicket] htp
				on htp.KeyTicket = convert(nchar(18),c.ParentID)
	left join SrcSFDC.[Group] gr
				on gr.Id = c.OwnerID and gr.[Name] = 'Invalid Tickets'
	where rt.[Name] in ('iTero Complaint')
	and c.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTicketComplaint where SourceSystem = 'SFDC')
	
	UNION ALL

	select 
			ht.SKTicketComplaint					as SKTicketComplaint,
			tck.ADLSBatchID							as ADLSBatchID,
			tck.ADLSTimestamp						as ADLSTimestamp,
			tck.LZBatchID							as LZBatchID,
			convert(char(40), '')					as DWHash,
			ht.KeyTicketComplaint					as KeyTicketComplaint,
			hac.SKAccount												as SKAccount, -- lookup
			ha.SKAsset													as SKAsset, -- lookup in HubAsset
			NULL														as SKParentTicket,
			hu.SKUser													as SKUser,
			htm.SKTeam													as SKTeam,

			convert(int, convert(varchar(8), tck.DateCreated, 112))		as CreatedDateKey,
			tck.DateCreated												as CreatedDate,
			case when rs.RowStatusDescriptionGeneric = 'Closed'
				 then convert(int, convert(varchar(8), tck.DateUpdated, 112))
				 else -1
			end															as ClosedDateKey,
			CASE WHEN rs.RowStatusDescriptionGeneric = 'Closed'
			THEN tck.DateUpdated
			END															as ClosedDate,
			convert(int, convert(varchar(8), tck.DateResolved, 112))	as ResolvedDateKey,
			tck.DateResolved											as ResolvedDate,
			-1															as CancelledDateKey, 
			NULL														as CancelledDate, 

			c_init.ContactFullName										as ContactFullName,
			t.TicketIssueTypeGenericDescription							as IssueType,
			st.TicketIssueSubTypeGenericDescription						as SubIssueType,
			asset.TicketIssueAssetGenericDescription					as IssueAsset,
			tck.DateUpdated												as LastModifiedDate,
			NULL														as Origin,
			p.PriorityGenericDescription								as [Priority],
			NULL														as [Status],
			NULL														as TicketType,
			NULL														as TicketNumber,
			NULL														as RecordType,
			c_assign.ContactFullName									as TicketAssignedTo,
			c_creator.ContactFullName									as TicketOpenedBy,


			NULL														as AdditionalCommentsOther,
			NULL														as AdditionalInformation,
			tc.ComplaintHandlingAndAssessmentDoneBy						as ComplaintHandlingAndAssessmentDoneBy,
			rs1.RowStatusDescriptionGeneric								as ComplaintStatus,
			tc.CustomerIssueDescription									as CustomerIssueDescription,
			tc.CustomerServiceInitialInvestigation						as CustomerServiceInitialInvestigation,
			tc.DidEventResultIn											as DidEventResultIn,
			tc.DuplicateOf												as DuplicateOf,
			tc.EvaluationImpactLevel									as EvaluationImpactLevel,
			tc.HazardSituation											as HazardSituation,
			tc.InvestigationCAPAReference								as InvestigationCAPAReference,
			tc.InWhatCountry											as InWhatCountry,
			tc.IsFurtherInvestigationNeeded								as IsFurtherInvestigationNeeded,
			tc.IsRegulatoryNonConformance								as IsRegulatoryNonConformance, -- no field in source
			convert(varchar(5),tc.IsReportable)							as IsReportable,
			convert(varchar(5),tck.IsSafety)							as IsSafety, 
			convert(varchar(5),tc.IsSafetyOrPotentiallySafety)			as IsSafetyOrPotentially, 
			convert(varchar(5),tc.IsValidComplaint)						as IsValidComplaint, -- no field in source
			tc.JustificationReportSummary								as JustificationReportSummary,
			tc.RationaleForFurtherInvestigationCAPANotRequired			as RationaleForFurtherInvestigationCAPANotRequired,
			tc.RiskAnalysisDOC											as RiskAnalysisDOC,
			tc.RootCause												as RootCause,

			/* Facts */
			1															as ComplaintCount,
		    NULL														as Category,
		    NULL														as ComplaintType,
		    NULL														as ComplaintSubType,
			NULL														as IsInvalid,
		   'MAT'														as [SourceSystem]
	from SrcMAT.svc_Ticket tck
	join SrcMAT.TicketComplaint TC
		on TC.TicketID = tck.TicketID
	join [DWIRIS].[HubTicketComplaint] ht
		on ht.KeyTicketComplaint = convert(nchar(18),tck.TicketID)
	left join [SrcMAT].svc_Team team
		on team.TeamID = tck.TicketTeamID
	/* Added SKTeam */
	left join [DWIRIS].[HubTeam] htm
		on htm.KeyTeam = team.ContactTeamGenericDescription 
		--and htm.SourceSystemCode = 'MAT'
	left join SrcMAT.svc_EquipmentCard ec
		on ec.EquipmentCardID = tck.TicketIssueEntityID
	left join [DWIRIS].[HubAsset] ha
		on ha.KeyAsset = ec.SerialIdentifier
	left join SrcMAT.BusinessPartnerSalesforceLink BPlink 
		ON BPlink.BusinessPartnerID =  tck.TicketInitiatorBusinessPartnerID
		and BPlink.RowStatusID <> 5
	left join SrcSFDC.Account ac
		on ac.Account_Number__c = BPlink.SalesforceAccountNum
		and try_convert(int, ac.MAT_ID__c) = BPlink.BusinessPartnerID
	left join DW.HubAccount hac
		on hac.KeyAccount = ac.Id
	left join SrcMAT.RowStatus rs1 
		on TC.RowStatusID = rs1.RowStatusID
	/* Init Contact */
	left join SrcMat.Contact c_init
		on c_init.ContactID = tck.TicketInitiatorContactID
	/* Assign contact */
	left join SrcMat.Contact c_assign
		on c_assign.ContactID = tck.TicketAssignedToContactID
	left join SrcMAT.svc_TicketIssueType t 
		on t.TicketIssueTypeID = tck.TicketIssueTypeID
	left join SrcMAT.svc_TicketIssueSubType st 
		on st.TicketIssueSubTypeID = tck.TicketIssueSubTypeID
	left join SrcMAT.svc_TicketIssueAsset asset 
		on tck.TicketIssueAssetID = asset.TicketIssueAssetID
	left join SrcMAT.[Priority] p
		on p.PriorityID = tck.PriorityID
	/* Created by Contact */
	left join SrcMat.Contact c_creator
		on c_creator.ContactID = tck.CreatedByUserID
	/* Ticket Status */
	left join SrcMAT.RowStatus rs 
		on tck.RowStatusID = rs.RowStatusID
	/* Join For close date*/
	left join [DWIRIS].[HubUser] hu
		on hu.KeyUser = convert(varchar(64), tck.CreatedByUserID)
		and hu.SourceSystemCode = 'MAT'
	where tck.ADLSTimestamp >= (
		select isnull(max(ADLSTimestamp), '19000101') 
		from DWIRIS.DimTicketComplaint
		 where SourceSystem = 'MAT'
	)


--	update HASH
	update #TempDimTicketComplaint set DWHash=
		convert(char(40),
			hashbytes('SHA1',
								 ISNULL(convert(nvarchar(255),[SKAccount]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKAsset]),'')

							+'|'+ISNULL(convert(nvarchar(255),[SKUser]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKTeam]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SKParentTicket]),'')
							+'|'+ISNULL(convert(nvarchar(255),[CreatedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ClosedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ResolvedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[CancelledDate]),'')
							
							+'|'+ISNULL(convert(nvarchar(600),[ContactFullName]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IssueType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[SubIssueType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IssueAsset]),'')
							+'|'+ISNULL(convert(nvarchar(255),[LastModifiedDate]),'')
							+'|'+ISNULL(convert(nvarchar(255),[Origin]),'')
							+'|'+ISNULL(convert(nvarchar(255),[Priority]),'')
							+'|'+ISNULL(convert(nvarchar(255),[Status]),'')
							+'|'+ISNULL(convert(nvarchar(512),[TicketType]),'')
							+'|'+ISNULL(convert(nvarchar(255),[TicketNumber]),'')
							+'|'+ISNULL(convert(nvarchar(255),[RecordType]),'')
							+'|'+ISNULL(convert(nvarchar(600),[TicketAssignedTo]),'')
							+'|'+ISNULL(convert(nvarchar(600),[TicketOpenedBy]),'')


	
							+'|'+ISNULL(convert(nvarchar(4000),[AdditionalCommentsOther]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[AdditionalInformation]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[ComplaintHandlingAndAssessmentDoneBy]),'')
							+'|'+ISNULL(convert(nvarchar(255),[ComplaintStatus]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[CustomerIssueDescription]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[CustomerServiceInitialInvestigation]),'')
							+'|'+ISNULL(convert(nvarchar(255),[DidEventResultIn]),'')
							+'|'+ISNULL(convert(nvarchar(255),[DuplicateOf]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[EvaluationImpactLevel]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[HazardSituation]),'')
							+'|'+ISNULL(convert(nvarchar(255),[InvestigationCAPAReference]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[InWhatCountry]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsFurtherInvestigationNeeded]),'')
							+'|'+ISNULL(convert(nvarchar(255),[IsRegulatoryNonConformance]),'')

							+'|'+ISNULL(convert(nvarchar(255),[IsReportable]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[IsSafety]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[IsSafetyOrPotentially]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[IsValidComplaint]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[JustificationReportSummary]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[RationaleForFurtherInvestigationCAPANotRequired]),'')
							+'|'+ISNULL(convert(nvarchar(255),[RiskAnalysisDOC]),'')
							+'|'+ISNULL(convert(nvarchar(4000),[RootCause]),'')

							+'|'+ISNULL(convert(nvarchar(512),[Category]),'')
							+'|'+ISNULL(convert(nvarchar(512),[ComplaintType]),'')
							+'|'+ISNULL(convert(nvarchar(512),[ComplaintSubType]),'')
							+'|'+ISNULL(convert(nvarchar(512),[IsInvalid]),'')
							+'|'+ISNULL(convert(nvarchar(512),[SourceSystem]),'')

				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTicketComplaint] where SKTicketComplaint = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWIRIS.DimTicketComplaint (
			[SKTicketComplaint]
			,[ADLSBatchID]
			,[ADLSTimestamp]
			,[LZBatchID]
			,[DWBatchID]
			,[DWHash]
			,KeyTicketComplaint
			,SKAccount
			,SKAsset
			,SKParentTicket
			,SKUser
			,SKTeam
			,CreatedDateKey
			,CreatedDate
			,ClosedDateKey
			,ClosedDate
			,ResolvedDateKey
			,ResolvedDate
			,CancelledDateKey
			,CancelledDate
			,ContactFullName
			,IssueType
			,SubIssueType
			,IssueAsset
			,LastModifiedDate
			,Origin
			,[Priority]
			,[Status]
			,TicketType
			,TicketNumber
			,RecordType
			,TicketAssignedTo
			,TicketOpenedBy
			,AdditionalCommentsOther
			,AdditionalInformation
			,ComplaintHandlingAndAssessmentDoneBy
			,ComplaintStatus
			,CustomerIssueDescription
			,CustomerServiceInitialInvestigation
			,DidEventResultIn
			,DuplicateOf
			,EvaluationImpactLevel
			,HazardSituation
			,InvestigationCAPAReference
			,InWhatCountry
			,IsFurtherInvestigationNeeded
			,IsRegulatoryNonConformance
			,IsReportable
			,IsSafety
			,IsSafetyOrPotentially
			,IsValidComplaint
			,JustificationReportSummary
			,RationaleForFurtherInvestigationCAPANotRequired
			,RiskAnalysisDOC
			,RootCause
			--,[Subject]
			,ComplaintCount
			,Category
			,ComplaintType
			,ComplaintSubType
			,IsInvalid
			,[SourceSystem]
		)
		values (
				-1					-- SKTicketComplaint
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash

			,	''					--[KeyTicketComplaint]
			,	-1					--[SKAccount]
			,	-1					--[SKAsset]
			,	-1					--[SKParentTicket]
			,	-1					--[SKUser]
			,	-1					--[SKTeam]

			,	19000101			--[CreatedDateKey]
			,	'19000101'			--[CreatedDate]
			,	19000101			--[ClosedDateKey]
			,	'19000101'			--[ClosedDate]
			,	19000101			--[ResolvedDateKey]
			,	'19000101'			--[ResolvedDate]
			,	19000101			--[CancelledDateKey]
			,	'19000101'			--[CancelledDate]

			,	'N/A'				--[ContactFullName]
			,	'N/A'				--[IssueType]
			,	'N/A'				--[SubIssueType]
			,	'N/A'				--[IssueAsset]
			,	'19000101'			--[LastModifiedDate]
			,	'N/A'				--[Origin]
			,	'N/A'				--[Priority]
			,	'N/A'				--[Status]
			,	'N/A'				--[TicketType]
			,	'N/A'				--[TicketNumber]
			,	'N/A'				--[RecordType]
			,	'N/A'				--[TicketAssignedTo]
			,	'N/A'				--[TicketOpenedBy]

			,	'N/A'				--[AdditionalCommentsOther]
			,	'N/A'				--[AdditionalInformation]
			,	'N/A'				--[ComplaintHandlingAndAssessmentDoneBy]
			,	'N/A'				--[ComplaintStatus]
			,	'N/A'				--[CustomerIssueDescription]
			,	'N/A'				--[CustomerServiceInitialInvestigation]
			,	-1					--[DidEventResultIn]
			,	'N/A'				--[DuplicateOf]
			,	'N/A'				--[EvaluationImpactLevel]
			,	'N/A'				--[HazardSituation]
			,	'N/A'				--[InvestigationCAPAReference]
			,	'N/A'				--[InWhatCountry]
			,	-1					--[IsFurtherInvestigationNeeded]
			,	-1					--[IsRegulatoryNonConformance]
			,	-1					--[IsReportable]
			,	-1					--[IsSafety]
			,	-1					--[IsSafetyOrPotentially]
			,	-1					--[IsValidComplaint]
			,	'N/A'				--[JustificationReportSummary]
			,	'N/A'				--[RationaleForFurtherInvestigationCAPANotRequired]
			,	'N/A'				--[RiskAnalysisDOC]
			,	'N/A'				--[RootCause]
			--,						[Subject]

			,	0					--[Complaints Count]
			,	'N/A'				--[Category]
			,	'N/A'				--[ComplaintType]
			,	'N/A'				--[ComplaintSubType]
			,	0					--[IsInvalid]
			,	'N/A'				--[SourceSystem]
		)
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTicketComplaint]
		set
		     ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash
			,SKAccount = src.SKAccount
			,SKAsset = src.SKAsset
			,SKParentTicket = src.SKParentTicket
			,SKUser = src.SKUser
			,SKTeam = src.SKTeam
			,CreatedDateKey = src.CreatedDateKey
			,CreatedDate = src.CreatedDate
			,ClosedDateKey = src.ClosedDateKey
			,ClosedDate = src.ClosedDate
			,ResolvedDateKey = src.ResolvedDateKey
			,ResolvedDate = src.ResolvedDate
			,CancelledDateKey = src.CancelledDateKey
			,CancelledDate = src.CancelledDate
			,ContactFullName = src.ContactFullName
			,IssueType = src.IssueType
			,SubIssueType = src.SubIssueType
			,IssueAsset = src.IssueAsset
			,LastModifiedDate = src.LastModifiedDate
			,Origin = src.Origin
			,[Priority] = src.[Priority]
			,[Status] = src.[Status]
			,TicketType = src.TicketType
			,TicketNumber = src.TicketNumber
			,RecordType = src.RecordType
			,TicketAssignedTo = src.TicketAssignedTo
			,TicketOpenedBy = src.TicketOpenedBy
			,AdditionalCommentsOther = src.AdditionalCommentsOther
			,AdditionalInformation = src.AdditionalInformation
			,ComplaintHandlingAndAssessmentDoneBy = src.ComplaintHandlingAndAssessmentDoneBy
			,ComplaintStatus = src.ComplaintStatus
			,CustomerIssueDescription = src.CustomerIssueDescription
			,CustomerServiceInitialInvestigation = src.CustomerServiceInitialInvestigation
			,DidEventResultIn = src.DidEventResultIn
			,DuplicateOf = src.DuplicateOf
			,EvaluationImpactLevel = src.EvaluationImpactLevel
			,HazardSituation = src.HazardSituation
			,InvestigationCAPAReference = src.InvestigationCAPAReference
			,InWhatCountry = src.InWhatCountry
			,IsFurtherInvestigationNeeded = src.IsFurtherInvestigationNeeded
			,IsRegulatoryNonConformance = src.IsRegulatoryNonConformance
			,IsReportable = src.IsReportable
			,IsSafety = src.IsSafety
			,IsSafetyOrPotentially = src.IsSafetyOrPotentially
			,IsValidComplaint = src.IsValidComplaint
			,JustificationReportSummary = src.JustificationReportSummary
			,RationaleForFurtherInvestigationCAPANotRequired = src.RationaleForFurtherInvestigationCAPANotRequired
			,RiskAnalysisDOC = src.RiskAnalysisDOC
			,RootCause = src.RootCause
			--,[Subject] = src.[Subject]
			,ComplaintCount = src.ComplaintCount
			,Category = src.Category
			,ComplaintType = src.ComplaintType
			,ComplaintSubType = src.ComplaintSubType
			,IsInvalid = src.IsInvalid
			,[SourceSystem] = src.[SourceSystem]

	from #TempDimTicketComplaint src
	where [DWIRIS].[DimTicketComplaint].SKTicketComplaint	=	src.SKTicketComplaint
		and [DWIRIS].[DimTicketComplaint].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTicketComplaint_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketComplaint_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTicketComplaint] (
			[SKTicketComplaint]
			,[ADLSBatchID]
			,[ADLSTimestamp]
			,[LZBatchID]
			,[DWBatchID]
			,[DWHash]

			,KeyTicketComplaint
			,SKAccount
			,SKAsset
			,SKParentTicket
			,SKUser
			,SKTeam
			,CreatedDateKey
			,CreatedDate
			,ClosedDateKey
			,ClosedDate
			,ResolvedDateKey
			,ResolvedDate
			,CancelledDateKey
			,CancelledDate
			,ContactFullName
			,IssueType
			,SubIssueType
			,IssueAsset
			,LastModifiedDate
			,Origin
			,[Priority]
			,[Status]
			,TicketType
			,TicketNumber
			,RecordType
			,TicketAssignedTo
			,TicketOpenedBy
			,AdditionalCommentsOther
			,AdditionalInformation
			,ComplaintHandlingAndAssessmentDoneBy
			,ComplaintStatus
			,CustomerIssueDescription
			,CustomerServiceInitialInvestigation
			,DidEventResultIn
			,DuplicateOf
			,EvaluationImpactLevel
			,HazardSituation
			,InvestigationCAPAReference
			,InWhatCountry
			,IsFurtherInvestigationNeeded
			,IsRegulatoryNonConformance
			,IsReportable
			,IsSafety
			,IsSafetyOrPotentially
			,IsValidComplaint
			,JustificationReportSummary
			,RationaleForFurtherInvestigationCAPANotRequired
			,RiskAnalysisDOC
			,RootCause
			--,[Subject]
			,ComplaintCount
			,Category 
			,ComplaintType 
			,ComplaintSubType 
			,IsInvalid
			,[SourceSystem]
	)
	select 
			[SKTicketComplaint]
			,[ADLSBatchID]
			,[ADLSTimestamp]
			,[LZBatchID]
			,@BatchID
			,[DWHash]

			,KeyTicketComplaint
			,SKAccount
			,SKAsset
			,SKParentTicket
			,SKUser
			,SKTeam
			,CreatedDateKey
			,CreatedDate
			,ClosedDateKey
			,ClosedDate
			,ResolvedDateKey
			,ResolvedDate
			,CancelledDateKey
			,CancelledDate
			,ContactFullName
			,IssueType
			,SubIssueType
			,IssueAsset
			,LastModifiedDate
			,Origin
			,[Priority]
			,[Status]
			,TicketType
			,TicketNumber
			,RecordType
			,TicketAssignedTo
			,TicketOpenedBy
			,AdditionalCommentsOther
			,AdditionalInformation
			,ComplaintHandlingAndAssessmentDoneBy
			,ComplaintStatus
			,CustomerIssueDescription
			,CustomerServiceInitialInvestigation
			,DidEventResultIn
			,DuplicateOf
			,EvaluationImpactLevel
			,HazardSituation
			,InvestigationCAPAReference
			,InWhatCountry
			,IsFurtherInvestigationNeeded
			,IsRegulatoryNonConformance
			,IsReportable
			,IsSafety
			,IsSafetyOrPotentially
			,IsValidComplaint
			,JustificationReportSummary
			,RationaleForFurtherInvestigationCAPANotRequired
			,RiskAnalysisDOC
			,RootCause
			--,[Subject]
			,ComplaintCount
			,Category 
			,ComplaintType
			,ComplaintSubType 
			,IsInvalid
			,[SourceSystem]
	from #TempDimTicketComplaint src
	where not exists(
		select dst.SKTicketComplaint
		from DWIRIS.DimTicketComplaint dst 
		where dst.SKTicketComplaint = src.SKTicketComplaint
	)
	option (label = 'DWIRIS.LoadDimTicketComplaint_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketComplaint_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure