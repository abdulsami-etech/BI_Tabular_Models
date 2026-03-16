CREATE PROC [DWIRIS].[LoadDimTeam] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	if object_id('tempdb..#TempDimTeam') is not null
		drop table #TempDimTeam

-- Get delta rows
	create table #TempDimTeam with (distribution = round_robin, heap) as 
	
	select	
			a.ADLSBatchID						as ADLSBatchID
		,	a.ADLSTimestamp						as ADLSTimestamp
		,	a.LZBatchID							as LZBatchID
		,	convert(char(40), '')				as DWHash
		
		,	hub.SKTeam							as SKTeam

		,	a.SourceSystem						as SourceSystem
		,	a.TeamName							as TeamName
		,	a.TeamMATID							as TeamMATID
	from (
		select	
				z.TeamName						as TeamName
			,	max(z.ADLSBatchID)				as ADLSBatchID
			,	max(z.ADLSTimestamp)			as ADLSTimestamp
			,	max(z.LZBatchID)				as LZBatchID
			,	min(SourceSystem)				as SourceSystem
			,	max(TeamMATID)					as TeamMATID
		from (
			select t.ContactTeamGenericDescription	as TeamName
				,	t.ADLSBatchID
				,	t.ADLSTimestamp
				,	t.LZBatchID
				,	'MAT'							as SourceSystem
				,	t.TeamID						as TeamMATID
			from SrcMAT.svc_Team t
			where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTeam where SourceSystem='MAT')
			and t.RowStatusID <> 5 -- added due to BI-8347
								   -- "Field Service EU" team has 2 rows:
								   -- one with TeamID = 41 (RowStatus = 1, active), but another row with TeamID = 43 has RowStatus = 5 (deleted)
								   -- due to current rule of max(TeamID) - applied RowStatus filter
			union

			select convert(nvarchar(255), c.Team_Function__c)	as TeamName
				,	c.ADLSBatchID
				,	c.ADLSTimestamp
				,	c.LZBatchID
				,	'SFDC'							as SourceSystem
				,	0								as TeamMATID
			from SrcSFDC.[Case] c
			where c.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimTeam where SourceSystem='SFDC')
		) z
		group by TeamName
	) a
	inner join DWIRIS.HubTeam hub 
		on hub.KeyTeam = a.TeamName


	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update #TempDimTeam set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					   convert(nvarchar,ISNULL(TeamName,''))
				  +'|'+convert(nvarchar,ISNULL(TeamMATID,''))
				  +'|'+convert(nvarchar,ISNULL(SourceSystem,''))
				)
			,2)


	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimTeam] where SKTeam = -1)
	begin
		declare @Hash char(40) = ''

		begin try
			insert into DWIRIS.DimTeam (
				[SKTeam]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]

				,[SourceSystem]
				,[TeamName]
				,[TeamMATID]

			)
			values (
					-1
				,	-1
				,	'19000101'
				,	-1
				,	@BatchID
				,	@Hash
				
				,	'N/A'
				,	'N/A'
				,	0
			)
		end try
		begin catch
			throw
		end catch
	end
	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimTeam]
		set
			 ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash

			,[SourceSystem]				=			src.[SourceSystem]
			,[TeamName]					=			src.[TeamName]
			,[TeamMATID]				=			src.[TeamMATID]
			
	from #TempDimTeam src
	where [DWIRIS].[DimTeam].SKTeam = src.SKTeam
	and [DWIRIS].[DimTeam].DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimTeam_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTeam_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimTeam] (
		   [SKTeam]
		  ,[ADLSBatchID]
		  ,[ADLSTimestamp]
		  ,[LZBatchID]
		  ,[DWBatchID]
		  ,[DWHash]

		  ,[SourceSystem]
		  ,[TeamName]
		  ,[TeamMATID]
		   )
	select 
		   [SKTeam]
		  ,[ADLSBatchID]
		  ,[ADLSTimestamp]
		  ,[LZBatchID]
		  ,@BatchID
		  ,[DWHash]

		  ,[SourceSystem]
		  ,[TeamName]
		  ,[TeamMATID]
	from #TempDimTeam src
	where not exists(select dst.SKTeam from DWIRIS.DimTeam dst where dst.SKTeam = src.SKTeam)
	option (label = 'DWIRIS.LoadDimTeam_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimTeam_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end