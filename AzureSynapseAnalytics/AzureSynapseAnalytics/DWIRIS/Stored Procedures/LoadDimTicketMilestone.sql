CREATE PROC [DWIRIS].[LoadDimTicketMilestone] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@dt datetime=getdate()

	if object_id('tempdb..#TempDimTicketMilestone') is not null
		drop table #TempDimTicketMilestone

	-- Get delta rows
	create table #TempDimTicketMilestone with (distribution = round_robin, heap) as 
	select	
			hm.SKTicketMilestone												as SKTicketMilestone
		,	m.ADLSBatchID														as ADLSBatchID
		,	m.ADLSTimestamp														as ADLSTimestamp
		,	m.LZBatchID															as LZBatchID
		,	convert(char(40), '')												as DWHash

		,	ht.SKTicket															as SKTicket

		,	m.BusinessHoursId													as BusinessHoursId
		,	m.Id																as TicketMilestoneId
		,	m.IsCompleted														as IsCompleted
		,	m.IsDeleted															as IsDeleted
		,	m.IsViolated														as IsViolated
		,	m.TargetResponseInDays												as TargetResponseInDays
		,	m.TargetResponseInHrs												as TargetResponseInHrs
		,	m.TargetResponseInMins												as TargetResponseInMins
		,	m.CaseId															as CaseId
		,	m.CompletionDate													as CompletionDate
		,	m.ElapsedTimeInMins													as ElapsedTimeInMins
		,	m.ElapsedTimeInDays													as ElapsedTimeInDays
		,	m.ElapsedTimeInHrs													as ElapsedTimeInHrs
		,	m.StartDate															as StartDate
		,	m.TargetDate														as TargetDate
		,	mt.[Name]															as MilestoneName
		,	mt.[Description]													as MilestoneDescription
		,	datediff(hh,m.StartDate, isnull(m.CompletionDate,getdate()))		as MileStoneNetHours
		,	CASE
				WHEN m.IsCompleted = 0 THEN datediff(mi,m.CreatedDate,getdate())
				ELSE m.ElapsedTimeInMins
			end																	as MilestoneAging
		,	1																	as MilestonesCount
	from [SrcSFDC].[CaseMilestone] m
	left join [SrcSFDC].[MilestoneType] mt
		on m.MilestoneTypeId = mt.Id

	join [DWIRIS].[HubTicketMilestone] hm
		on m.Id = hm.KeyTicketMilestone
	join [DWIRIS].[HubTicket] ht
		on m.CaseId = ht.KeyTicket

	where m.Id is not null
	and m.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTicketMilestone)


	--update HASH
	update #TempDimTicketMilestone 
	set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         convert(nvarchar,ISNULL(BusinessHoursId,''))
					+'|'+convert(nvarchar,ISNULL(TicketMilestoneId,''))
					+'|'+convert(nvarchar,ISNULL(IsCompleted,''))
					+'|'+convert(nvarchar,ISNULL(IsDeleted,''))
					+'|'+convert(nvarchar,ISNULL(IsViolated,''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),TargetResponseInDays),''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),TargetResponseInHrs),''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),TargetResponseInMins),''))
					+'|'+convert(nvarchar,ISNULL(CaseId,''))
					+'|'+convert(nvarchar,ISNULL(CompletionDate,''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),ElapsedTimeInMins),''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),ElapsedTimeInDays),''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),ElapsedTimeInHrs),''))
					+'|'+convert(nvarchar,ISNULL(StartDate,''))
					+'|'+convert(nvarchar,ISNULL(TargetDate,''))
					+'|'+convert(nvarchar,ISNULL(MilestoneName,''))
					+'|'+convert(nvarchar,ISNULL(MilestoneDescription,''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),MileStoneNetHours),''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),MilestoneAging),''))
					+'|'+convert(nvarchar,ISNULL(convert(nvarchar(50),MilestonesCount),''))
				)
			, 2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTicketMilestone] where SKTicketMilestone = -1)
	begin
		declare @Hash char(40) = ''

		insert into DWIRIS.DimTicketMilestone (
				[SKTicketMilestone]
			,	[ADLSBatchID]
			,	[ADLSTimestamp]
			,	[LZBatchID]
			,	[DWBatchID]
			,	[DWHash]
			,	[SKTicket]

			,	[BusinessHoursId]
			,	[TicketMilestoneId]
			,	[IsCompleted]
			,	[IsDeleted]
			,	[IsViolated]
			,	[TargetResponseInDays]
			,	[TargetResponseInHrs]
			,	[TargetResponseInMins]
			,	[CaseId]
			,	[CompletionDate]
			,	[ElapsedTimeInMins]
			,	[ElapsedTimeInDays]
			,	[ElapsedTimeInHrs]
			,	[StartDate]
			,	[TargetDate]
			,	[MilestoneName]
			,	[MileStoneDescription]
			,	[MileStoneNetHours]
			,	[MilestoneAging]
			,	[MilestonesCount]

		)
		values (
				-1					-- SKTicketMilestone
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
			,	-1
			,	N'N/A'				-- BusinessHoursId
			,	N'N/A'				-- TicketMilestoneId
			,	N'N/A'				-- IsCompleted
			,	N'N/A'				-- IsDeleted
			,	N'N/A'				-- IsViolated
			,	0					-- TargetResponseInDays
			,	0					-- TargetResponseInHrs
			,	0					-- TargetResponseInMins
			,	N'N/A'				-- CaseId
			,	'19000101'			-- CompletionDate
			,	0					-- ElapsedTimeInMins
			,	0					-- ElapsedTimeInDays
			,	0					-- ElapsedTimeInHrs
			,	'19000101'			-- StartDate
			,	'19000101'			-- TargetDate
			,	N'N/A'				-- MilestoneName
			,	N'N/A'				-- MilestoneDescription
			,	0					-- MileStoneNetHours
			,	0					-- MilestoneAging
			,	0					-- MilestonesCount
		)
	end
	--  End  createing unknown element

	-- insert new keys into Ticket hub
	insert into DWIRIS.HubTicket (
		[KeyTicket]
		, [DWBatchID]
		, [InsertDateTime]
		, [SourceSystemCode]
	)
	select distinct
		
		CaseId
		, @BatchID as [DWBatchID]
		, @dt as [InsertDateTime]
		, 'SFDC'
	from #TempDimTicketMilestone
	where CaseId not in (
		select KeyTicket
		from DWIRIS.HubTicket
	)
	option (label = 'DWIRIS.LoadHubTicketMilestone_HubTicket');


	-- update new Ticket keys in temp table
	update #TempDimTicketMilestone
	set SKTicket = ht.SKTicket
	from [DWIRIS].[HubTicket] ht
	where #TempDimTicketMilestone.CaseId = ht.KeyTicket
	and #TempDimTicketMilestone.SKTicket is null


	



	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTicketMilestone]
		set
		     ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash
			,[BusinessHoursId]			=		src.[BusinessHoursId]
			,[TicketMilestoneId]		=		src.[TicketMilestoneId]
			,[IsCompleted]				=		src.[IsCompleted]
			,[IsDeleted]				=		src.[IsDeleted]
			,[IsViolated]				=		src.[IsViolated]
			,[TargetResponseInMins]		=		src.[TargetResponseInMins]
			,[TargetResponseInDays]		=		src.[TargetResponseInDays]
			,[TargetResponseInHrs]		=		src.[TargetResponseInHrs]
			,[CaseId]					=		src.[CaseId]
			,[CompletionDate]			=		src.[CompletionDate]
			,[ElapsedTimeInMins]		=		src.[ElapsedTimeInMins]
			,[ElapsedTimeInDays]		=		src.[ElapsedTimeInDays]
			,[ElapsedTimeInHrs]			=		src.[ElapsedTimeInHrs]
			,[StartDate]				=		src.[StartDate]
			,[TargetDate]				=		src.[TargetDate]
			,[MilestoneName]			=		src.[MilestoneName]
			,[MilestoneDescription]		=		src.[MilestoneDescription]
			,[MileStoneNetHours]		=		src.[MileStoneNetHours]
			,[MilestoneAging]			=		src.[MilestoneAging]
			,[MilestonesCount]			=		src.[MilestonesCount]


	from #TempDimTicketMilestone src
	where [DWIRIS].[DimTicketMilestone].SKTicketMilestone	= src.SKTicketMilestone
	and [DWIRIS].[DimTicketMilestone].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTicketMilestone_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketMilestone_Update', @rc = @RowsUpdated out

	--INSERT new rows
	insert into [DWIRIS].[DimTicketMilestone] (
			[SKTicketMilestone]
		,	[ADLSBatchID]
        ,	[ADLSTimestamp]
        ,	[LZBatchID]
        ,	[DWBatchID]
        ,	[DWHash]
		,	[SKTicket]
		,	[BusinessHoursId]
		,	[TicketMilestoneId]
		,	[IsCompleted]
		,	[IsDeleted]
		,	[IsViolated]
		,	[TargetResponseInDays]
		,	[TargetResponseInHrs]
		,	[TargetResponseInMins]
		,	[CaseId]
		,	[CompletionDate]
		,	[ElapsedTimeInMins]
		,	[ElapsedTimeInDays]
		,	[ElapsedTimeInHrs]
		,	[StartDate]
		,	[TargetDate]
		,	[MilestoneName]
		,	[MileStoneDescription]
		,	[MileStoneNetHours]
		,	[MilestoneAging]
		,	[MilestonesCount]
	)
	select 
			[SKTicketMilestone]
		,	[ADLSBatchID]
        ,	[ADLSTimestamp]
        ,	[LZBatchID]
        ,	@BatchID
        ,	[DWHash]
		,	[SKTicket]
		,	[BusinessHoursId]
		,	[TicketMilestoneId]
		,	[IsCompleted]
		,	[IsDeleted]
		,	[IsViolated]
		,	[TargetResponseInDays]
		,	[TargetResponseInHrs]
		,	[TargetResponseInMins]
		,	[CaseId]
		,	[CompletionDate]
		,	[ElapsedTimeInMins]
		,	[ElapsedTimeInDays]
		,	[ElapsedTimeInHrs]
		,	[StartDate]
		,	[TargetDate]
		,	[MilestoneName]
		,	[MileStoneDescription]
		,	[MileStoneNetHours]
		,	[MilestoneAging]
		,	[MilestonesCount]
	from #TempDimTicketMilestone src
	where not exists(select dst.SKTicketMilestone from DWIRIS.DimTicketMilestone dst where dst.SKTicketMilestone = src.SKTicketMilestone)
	option (label = 'DWIRIS.LoadDimTicketMilestone_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTicketMilestone_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure

