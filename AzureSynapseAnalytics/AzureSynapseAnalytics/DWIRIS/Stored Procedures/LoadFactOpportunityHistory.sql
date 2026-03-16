CREATE PROC [DWIRIS].[LoadFactOpportunityHistory] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0
		,	@IsForceFullLoad bit = 0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if object_id('DWIRIS.Temp_FactOpportunityHistory','U') is not null
		drop table DWIRIS.Temp_FactOpportunityHistory

	CREATE TABLE [DWIRIS].[Temp_FactOpportunityHistory]
(
	[ADLSBatchID] [int] NOT NULL ,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NULL,
	[Id] [nchar](18) NOT NULL,
	[SourceSystem] [char](10) NOT NULL,
	[SKOpportunity] [int] NOT NULL,
	[KeyOpportunity] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[CreatedById] [nchar](18) NULL,
	[Field] [nvarchar](255) NOT NULL,
	[IsDeleted] [varchar](5) NOT NULL,
	[NewValue] [nvarchar](255) NULL,
	[OldValue] [nvarchar](255) NULL,
	[OpportunityId] [nchar](18) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
	
)
ALTER TABLE [DWIRIS].[Temp_FactOpportunityHistory] ADD CONSTRAINT PK_TempHubOpportunity PRIMARY KEY NONCLUSTERED ([ID] , [SourceSystem]  ) NOT ENFORCED

	insert into [DWIRIS].[Temp_FactOpportunityHistory]
	(
	    [ADLSBatchID],
		[ADLSTimestamp],
		[LZBatchID] ,
		[DWBatchID] ,
		[DWHash] ,
		[Id] ,
		[SourceSystem],
		[SKOpportunity] ,
		[KeyOpportunity] ,
		[CreatedDate],
		[CreatedById],
		[Field] ,
		[IsDeleted] ,
		[NewValue] ,
		[OldValue] ,
		[OpportunityId]
	  )

	select	
				o.ADLSBatchID						as ADLSBatchID
		  ,		o.ADLSTimestamp						as ADLSTimestamp
		  ,		o.LZBatchID							as LZBatchID
		  ,     @BatchID							as DWBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		o.[ID]								as ID
		  ,		'SFDC'								as SourceSystem
		  ,		isnull(ho.SKOpportunity,-1)			as SKOpportunity
		  ,     o.OpportunityId						as KeyOpportunity
		  ,     o.[CreatedDate]						as [CreatedDate]
		  ,     o.[CreatedById]						as [CreatedById]
		  ,     o.[Field]							as [Field]
		  ,     o.[IsDeleted]						as [IsDeleted]
		  ,     o.[NewValue]						as [NewValue]
		  ,     o.[OldValue]						as [OldValue]
		  ,     o.[OpportunityId]					as [OpportunityId]
	from SrcSFDC.[OpportunityFieldHistory] o
	inner join DWIRIS.HubOpportunity ho 
		on ho.KeyOpportunity = o.OpportunityId
	inner join SrcSFDC.Opportunity opp
		on opp.Id = ho.KeyOpportunity 
	where (o.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from [DWIRIS].[FactOpportunityHistory]) or @IsFullLoad = 1)
	and opp.RecordTypeId in ('012i00000019r6NAAQ','0120H000000yUddQAE','0120H000001J6QaQAK','0120H000001QT9eQAG','0120H000000u011QAA','0120H000001QTSDQA4')
	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update DWIRIS.Temp_FactOpportunityHistory set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					   ISNULL(convert(nvarchar,KeyOpportunity),'')
				  +'|'+ISNULL(convert(nvarchar,SKOpportunity),'')
				  +'|'+ISNULL(convert(nvarchar,CreatedDate),'')
				  +'|'+ISNULL(convert(nvarchar,CreatedById),'')
				  +'|'+ISNULL(convert(nvarchar,Field),'')
				  +'|'+ISNULL(convert(nvarchar,IsDeleted),'')
				  +'|'+ISNULL(convert(nvarchar,NewValue),'')
				  +'|'+ISNULL(convert(nvarchar,OldValue),'')
				  +'|'+ISNULL(convert(nvarchar,OpportunityId),'')
				)
			,2)

	if @IsFullLoad = 0
	begin
	update [DWIRIS].[FactOpportunityHistory]
		set	[ADLSBatchID] = src.[ADLSBatchID]
      ,[ADLSTimestamp] = src.[ADLSTimestamp]
      ,[LZBatchID]	= src.[ADLSBatchID]
      ,[DWBatchID]	= src.[DWBatchID]
      ,[DWHash]	= src.[DWHash]
      ,[SKOpportunity]	= src.[SKOpportunity]

      ,[KeyOpportunity]	= src.[KeyOpportunity]
      ,CreatedDate	= src.CreatedDate
      ,CreatedById	= src.CreatedById
      ,Field	= src.Field
      ,IsDeleted	= src.IsDeleted
      ,NewValue	= src.NewValue
      ,OldValue	= src.OldValue
	  ,OpportunityId	= src.OpportunityId
	  from DWIRIS.Temp_FactOpportunityHistory src
		where DWIRIS.FactOpportunityHistory.ID = src.ID and
		DWIRIS.FactOpportunityHistory.SourceSystem=src.SourceSystem
			and DWIRIS.FactOpportunityHistory.DWHash != src.DWHash
		option (label = 'DWIRIS.FactOpportunityHistory_Update');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.FactOpportunityHistory_Update', @rc = @RowsUpdated out

	insert into [DWIRIS].[FactOpportunityHistory] (

	    [ADLSBatchID],
		[ADLSTimestamp],
		[LZBatchID] ,
		[DWBatchID] ,
		[DWHash] ,
		[Id] ,
		[SourceSystem],
		[SKOpportunity] ,
		[KeyOpportunity] ,
		[CreatedDate],
		[CreatedById],
		[Field] ,
		[IsDeleted] ,
		[NewValue] ,
		[OldValue] ,
		[OpportunityId]
	  )	
	  
		select	 
	    [ADLSBatchID],
		[ADLSTimestamp],
		[LZBatchID] ,
		[DWBatchID] ,
		[DWHash] ,
		[Id] ,
		[SourceSystem],
		[SKOpportunity] ,
		[KeyOpportunity] ,
		[CreatedDate],
		[CreatedById],
		[Field] ,
		[IsDeleted] ,
		[NewValue] ,
		[OldValue] ,
		[OpportunityId]
	  
		from DWIRIS.Temp_FactOpportunityHistory src
		where not exists (select * from DWIRIS.FactOpportunityHistory dst where dst.ID = src.ID and dst.sourcesystem=src.sourcesystem)
		option (label = 'DWIRIS.FactOpportunityHistory_Insert');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadFactCaseDownload_Insert', @rc = @RowsInserted out

		if object_id ('DWIRIS.Temp_FactOpportunityHistory', 'U') is not null
		drop table DWIRIS.Temp_FactOpportunityHistory
	end
	else
	begin --full load
		if object_id ('DWIRIS.FactOpportunityHistoryPrevious', 'U') is not null
			drop table DWIRIS.FactOpportunityHistoryPrevious

		rename object DWIRIS.FactOpportunityHistory to FactOpportunityHistoryPrevious
		rename object DWIRIS.Temp_FactOpportunityHistory to FactOpportunityHistory

		if object_id ('DWIRIS.FactOpportunityHistoryPrevious', 'U') is not null
		drop table DWIRIS.FactOpportunityHistoryPrevious
		rename object DWIRIS.PK_TempHubOpportunity to PK_HubOpportunity
		
		select @RowsInserted = count(*)
		from DWIRIS.FactOpportunityHistory

	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end