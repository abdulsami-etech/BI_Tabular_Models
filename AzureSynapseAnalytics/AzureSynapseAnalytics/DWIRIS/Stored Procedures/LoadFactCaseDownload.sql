create PROC [DWIRIS].[LoadFactCaseDownload] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0
		--,	@BatchID [int]	=0
		--,@LastSuccessfullDWTimestamp [datetime2](0)='01/01/2019',@IsForceFullLoad bit=1

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if object_id('DWIRIS.Temp_FactCaseDownload','U') is not null
		drop table DWIRIS.Temp_FactCaseDownload

	CREATE TABLE [DWIRIS].[Temp_FactCaseDownload]
(
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] char (40) NULL,
	[ID] [bigint] NOT NULL,
	[SourceSystem] [char](10) NOT NULL,
	[SKCase] [int] NOT NULL,
	[KeyCase] [bigint] NOT NULL,
	[ACSFileRevision] [varchar](50) NULL,
	[FileType] [int] NULL,
	[DownloadedByClientID] [int] NULL,
	[DownloadDate] [datetime] NULL,
	[DownloadCount] [int] NULL,
	[SKDateTime] [int]  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
	
)
ALTER TABLE [DWIRIS].[Temp_FactCaseDownload] ADD CONSTRAINT PK_TempHubCaseDownload PRIMARY KEY NONCLUSTERED ([ID] , [SourceSystem]  ) NOT ENFORCED

	insert into [DWIRIS].[Temp_FactCaseDownload]
	(
	   [ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
	  ,[DWHash]
      ,[ID]
      ,[SourceSystem]
      ,[SKCase]
      ,[KeyCase]
      ,[ACSFileRevision]
      ,[FileType]
      ,[DownloadedByClientID]
      ,[DownloadDate]
      ,[DownloadCount]
      ,[SKDateTime]	 
	  )

	select	
				a.ADLSBatchID						as ADLSBatchID
		  ,		a.ADLSTimestamp						as ADLSTimestamp
		  ,		a.LZBatchID							as LZBatchID
		  ,     @BatchID							as DWBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		a.[ID]								as ID
		  ,		'EUPRW'								as SourceSystem
		  ,		isnull(ca.SKCase,-1)			    as SKCase
		  ,     a.OrderId							as KeyCase
		  ,		a.ACSFileRevision					as ACSFileRevision
		  ,		a.FileType							as FileType
		  ,		a.DownloadedByClientID				as DownloadedByClientID
		  ,		a.DownloadDate						as DownloadDate
		  ,     1									as DownloadCount
		  ,		dt.SkDateTime						as SKDateTime

	from srcEUPRW.[CaseDownload] a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.DownloadDate as Date) 
	where (a.ADLSTimestamp >= @LastSuccessfullDWTimestamp or @IsFullLoad=1)
	
	union all
	select	
				a.ADLSBatchID						as ADLSBatchID
		  ,		a.ADLSTimestamp						as ADLSTimestamp
		  ,		a.LZBatchID							as LZBatchID
		  ,     @BatchID							as DWBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		a.[ID]								as ID
		  ,		'EUPRWEMEA'								as SourceSystem
		  ,		isnull(ca.SKCase,-1)			    as SKCase
		  ,     a.OrderId							as KeyCase
		  ,		a.ACSFileRevision					as ACSFileRevision
		  ,		a.FileType							as FileType
		  ,		a.DownloadedByClientID				as DownloadedByClientID
		  ,		a.DownloadDate						as DownloadDate
		  ,     1									as DownloadCount
		  ,		dt.SkDateTime						as SKDateTime
	from srcEUPRWEMEA.[CaseDownload] a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.DownloadDate as Date) 
	where (a.ADLSTimestamp >= @LastSuccessfullDWTimestamp or @IsFullLoad=1)
    union all
	select	
				a.ADLSBatchID						as ADLSBatchID
		  ,		a.ADLSTimestamp						as ADLSTimestamp
		  ,		a.LZBatchID							as LZBatchID
		  ,     @BatchID							as DWBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		a.[ID]								as ID
		  ,		'EUPRWAPAC'								as SourceSystem
		  ,		isnull(ca.SKCase,-1)			    as SKCase
		  ,     a.OrderId							as KeyCase
		  ,		a.ACSFileRevision					as ACSFileRevision
		  ,		a.FileType							as FileType
		  ,		a.DownloadedByClientID				as DownloadedByClientID
		  ,		a.DownloadDate						as DownloadDate
		  ,     1									as DownloadCount
		  ,		dt.SkDateTime						as SKDateTime
	from srcEUPRWAPAC.[CaseDownload] a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.DownloadDate as Date) 
	where (a.ADLSTimestamp >= @LastSuccessfullDWTimestamp or @IsFullLoad=1)

	  union all
	select	
				a.ADLSBatchID						as ADLSBatchID
		  ,		a.ADLSTimestamp						as ADLSTimestamp
		  ,		a.LZBatchID							as LZBatchID
		  ,     @BatchID							as DWBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		a.[ID]								as ID
		  ,		'EUPRWCHINA'								as SourceSystem
		  ,		isnull(ca.SKCase,-1)			    as SKCase
		  ,     a.OrderId							as KeyCase
		  ,		a.ACSFileRevision					as ACSFileRevision
		  ,		a.FileType							as FileType
		  ,		a.DownloadedByClientID				as DownloadedByClientID
		  ,		a.DownloadDate						as DownloadDate
		  ,     1									as DownloadCount
		  ,		dt.SkDateTime						as SKDateTime
	from srcEUPRWCHINA.[CaseDownload] a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.DownloadDate as Date) 
	where (a.ADLSTimestamp >= @LastSuccessfullDWTimestamp or @IsFullLoad=1)


	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update DWIRIS.Temp_FactCaseDownload set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					   convert(nvarchar,ISNULL(KeyCase,''))
				  +'|'+convert(nvarchar,ISNULL(SKCase,''))
				  +'|'+convert(nvarchar,ISNULL(ACSFileRevision,''))
				  +'|'+convert(nvarchar,ISNULL(FileType,''))
				  +'|'+convert(nvarchar,ISNULL(DownloadedByClientID,''))
				  +'|'+convert(nvarchar,ISNULL(DownloadDate,''))
				  +'|'+convert(nvarchar,ISNULL(DownloadCount,''))
				)
			,2)
	if @IsFullLoad = 0
	begin
	update DWIRIS.FactCaseDownload
		set	[ADLSBatchID] = src.[ADLSBatchID]
      ,[ADLSTimestamp] = src.[ADLSTimestamp]
      ,[LZBatchID]	= src.[ADLSBatchID]
      ,[DWBatchID]	= src.[DWBatchID]
      ,[DWHash]	= src.[DWHash]
      ,[SKCase]	= src.[SKCase]
      ,[KeyCase]	= src.[KeyCase]
      ,[ACSFileRevision]	= src.[ACSFileRevision]
      ,[FileType]	= src.[FileType]
      ,[DownloadedByClientID]	= src.[DownloadedByClientID]
      ,[DownloadDate]	= src.[DownloadDate]
      ,[DownloadCount]	= src.[DownloadCount]
      ,[SKDateTime]	= src.[SKDateTime]
	  from DWIRIS.Temp_FactCaseDownload src
		where DWIRIS.FactCaseDownload.ID = src.ID and
		DWIRIS.FactCaseDownload.SourceSystem=src.sourcesystem
			and DWIRIS.FactCaseDownload.DWHash != src.DWHash
		option (label = 'DWIRIS.LoadFactCaseDownload_Update');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadFactCaseDownload_Update', @rc = @RowsUpdated out

	insert into DWIRIS.FactCaseDownload (
[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[ID]
      ,[SourceSystem]
      ,[SKCase]
      ,[KeyCase]
      ,[ACSFileRevision]
      ,[FileType]
      ,[DownloadedByClientID]
      ,[DownloadDate]
      ,[DownloadCount]
      ,[SKDateTime]	
	  )
		select	 [ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[ID]
      ,[SourceSystem]
      ,[SKCase]
      ,[KeyCase]
      ,[ACSFileRevision]
      ,[FileType]
      ,[DownloadedByClientID]
      ,[DownloadDate]
      ,[DownloadCount]
      ,[SKDateTime]
		from DWIRIS.Temp_FactCaseDownload src
		where not exists (select * from DWIRIS.FactCaseDownload dst where dst.ID = src.ID and dst.sourcesystem=src.sourcesystem)
		option (label = 'DWIRIS.LoadFactCaseDownload_Insert');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadFactCaseDownload_Insert', @rc = @RowsInserted out

		if object_id ('DWIRIS.Temp_FactCaseDownload', 'U') is not null
		drop table DWIRIS.Temp_FactCaseDownload
	end
	else
	begin --full load
		if object_id ('DWIRIS.FactCaseDownloadPrevious', 'U') is not null
			drop table DWIRIS.FactCaseDownloadPrevious

		rename object DWIRIS.FactCaseDownload to FactCaseDownloadPrevious
		rename object DWIRIS.Temp_FactCaseDownload to FactCaseDownload

		if object_id ('DWIRIS.FactCaseDownloadPrevious', 'U') is not null
		drop table DWIRIS.FactCaseDownloadPrevious
		rename object DWIRIS.PK_TempHubCaseDownload to PK_HubCaseDownload
		
		select @RowsInserted = count(*)
		from DWIRIS.FactCaseDownload

	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end