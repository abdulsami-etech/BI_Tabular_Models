Create PROC [DWIRIS].[LoadFactScanReportSharing] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0
		--,	@BatchID [int]	=0
		--,@LastSuccessfullDWTimestamp [datetime2](0)='01/01/2019',@IsForceFullLoad bit=0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if object_id('DWIRIS.Temp_FactScanReportSharing','U') is not null
		drop table DWIRIS.Temp_FactScanReportSharing

	CREATE TABLE [DWIRIS].[Temp_FactScanReportSharing]
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
	[CompanyId] int NOT NULL,
	[DoctorId] int NOT NULL,
	[SharingType] int NOT NULL,
	[SharingDateTime] Datetime NOT NULL,
	[Platform] int NOT NULL,
	[ScanReportSharingImageId] int NOT Null,
	[ImageType] int Null,
	[ImageId] varchar(128) Null,
	[IsShared] int Null,
	[DownloadCount] [int] NULL,
	[SKDateTime] [int]  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
ALTER TABLE [DWIRIS].Temp_FactScanReportSharing ADD CONSTRAINT PK_TempFactScanReportSharing PRIMARY KEY NONCLUSTERED ([ID] ,[ScanReportSharingImageId], [SourceSystem]  ) NOT ENFORCED

	insert into [DWIRIS].[Temp_FactScanReportSharing]
	(
	   [ADLSBatchID] ,
		[ADLSTimestamp] ,
		[LZBatchID] ,
		[DWBatchID] ,
		[DWHash] ,
		[ID],
		[SourceSystem] ,
		[SKCase] ,
		[KeyCase] ,
		[CompanyId] ,
		[DoctorId],
		[SharingType],
		[SharingDateTime] ,
		[Platform],
		[ScanReportSharingImageId] ,
		[ImageType] ,
		[ImageId] ,
		[IsShared] ,
		[DownloadCount] ,
		[SKDateTime] 
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
		  ,		a.CompanyId
		  ,		a.DoctorId
		  ,		a.SharingType
		  ,		a.SharingDateTime
		  ,		a.[Platform]
		  ,		isnull(b.id,-1)  as [ScanReportSharingImageId]
		  ,		b.[ImageType] 
		  ,		b.[ImageId] 
		  ,		b.[IsShared] 
		  ,     1	as DownloadCount
		  ,		dt.SkDateTime	as SKDateTime
	from srcEUPRW.scanreportsharing a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.sharingdatetime as Date) 
	left join [SrcEUPRW].[scanreportsharingimage] b on a.id = b.[scanreportsharingid]
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
		  ,		a.CompanyId
		  ,		a.DoctorId
		  ,		a.SharingType
		  ,		a.SharingDateTime
		  ,		a.[Platform]
		  ,		isnull(b.id,-1)  as [ScanReportSharingImageId]
		  ,		b.[ImageType] 
		  ,		b.[ImageId] 
		  ,		b.[IsShared] 
		  ,     1									as DownloadCount
		  ,		dt.SkDateTime						as SKDateTime
	from srcEUPRWEMEA.scanreportsharing a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.sharingdatetime as Date) 
	left join [SrcEUPRWEMEA].[scanreportsharingimage] b on a.id = b.[scanreportsharingid]
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
		  ,		a.CompanyId
		  ,		a.DoctorId
		  ,		a.SharingType
		  ,		a.SharingDateTime
		  ,		a.[Platform]
		  ,		isnull(b.id,-1)  as [ScanReportSharingImageId]
		  ,		b.[ImageType] 
		  ,		b.[ImageId] 
		  ,		b.[IsShared] 
		  ,     1									as DownloadCount
		  ,		dt.SkDateTime						as SKDateTime
	from srcEUPRWAPAC.scanreportsharing a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.sharingdatetime as Date) 
	left join [SrcEUPRWAPAC].[scanreportsharingimage] b on a.id = b.[scanreportsharingid]
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
		  ,		a.CompanyId
		  ,		a.DoctorId
		  ,		a.SharingType
		  ,		a.SharingDateTime
		  ,		a.[Platform]
		  ,		isnull(b.id,-1)  as [ScanReportSharingImageId]
		  ,		b.[ImageType] 
		  ,		b.[ImageId] 
		  ,		b.[IsShared] 
		  ,     1									as DownloadCount
		  ,		dt.SkDateTime						as SKDateTime
	from srcEUPRWCHINA.scanreportsharing a
	Left join DWIRIS.HubCase Ca on Ca.KeyCase=cast(a.OrderID as nvarchar)
	left join  DWIRIS.DimDateTime dt on dt.KeyDateTime=cast(a.sharingdatetime as Date) 
	left join srcEUPRWCHINA.[scanreportsharingimage] b on a.id = b.[scanreportsharingid]
	where (a.ADLSTimestamp >= @LastSuccessfullDWTimestamp or @IsFullLoad=1)

	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update DWIRIS.Temp_FactScanReportSharing set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					   convert(nvarchar,ISNULL(KeyCase,''))
				  +'|'+convert(nvarchar,ISNULL(SKCase,''))
				  +'|'+convert(nvarchar,ISNULL(CompanyId,''))
				  +'|'+convert(nvarchar,ISNULL(DoctorId,''))
				  +'|'+convert(nvarchar,ISNULL(SharingType,''))
				  +'|'+convert(nvarchar,ISNULL(SharingDateTime,''))
				  +'|'+convert(nvarchar,ISNULL([Platform],''))
				  +'|'+convert(nvarchar,ISNULL([ImageType],''))
				  +'|'+convert(nvarchar,ISNULL([ImageId],''))
				  +'|'+convert(nvarchar,ISNULL([IsShared],''))
				)
			,2)
	if @IsFullLoad = 0
	begin
	update DWIRIS.FactScanReportSharing
		set	[ADLSBatchID] = src.[ADLSBatchID]
      ,[ADLSTimestamp] = src.[ADLSTimestamp]
      ,[LZBatchID]	= src.[ADLSBatchID]
      ,[DWBatchID]	= src.[DWBatchID]
      ,[DWHash]	= src.[DWHash]
      ,[SKCase]	= src.[SKCase]
      ,[KeyCase]	= src.[KeyCase]
      ,[CompanyId]	= src.[CompanyId]
      ,[DoctorId]	= src.[DoctorId]
      ,[SharingType]	= src.[SharingType]
      ,[SharingDateTime]	= src.[SharingDateTime]
      ,[ImageType]	= src.[ImageType]
      ,[ImageId]	= src.[ImageId]
	  ,[IsShared]	= src.[IsShared]
	  ,[SKDateTime]	= src.[SKDateTime]
	  from DWIRIS.Temp_FactScanReportSharing src
		where DWIRIS.FactScanReportSharing.ID = src.ID and
		DWIRIS.FactScanReportSharing.SourceSystem=src.sourcesystem and
		DWIRIS.FactScanReportSharing.[ScanReportSharingImageId] = src.[ScanReportSharingImageId] and
		DWIRIS.FactScanReportSharing.DWHash != src.DWHash
		option (label = 'DWIRIS.LoadFactScanReportSharing_Update');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadFactScanReportSharing_Update', @rc = @RowsUpdated out

	insert into DWIRIS.FactScanReportSharing (
         [ADLSBatchID] ,
		[ADLSTimestamp] ,
		[LZBatchID] ,
		[DWBatchID] ,
		[DWHash] ,
		[ID],
		[SourceSystem] ,
		[SKCase] ,
		[KeyCase] ,
		[CompanyId] ,
		[DoctorId],
		[SharingType],
		[SharingDateTime] ,
		[Platform],
		[ScanReportSharingImageId] ,
		[ImageType] ,
		[ImageId] ,
		[IsShared] ,
		[DownloadCount] ,
		[SKDateTime] 
	  )
		select	   [ADLSBatchID] ,
		[ADLSTimestamp] ,
		[LZBatchID] ,
		[DWBatchID] ,
		[DWHash] ,
		[ID],
		[SourceSystem] ,
		[SKCase] ,
		[KeyCase] ,
		[CompanyId] ,
		[DoctorId],
		[SharingType],
		[SharingDateTime] ,
		[Platform],
		[ScanReportSharingImageId] ,
		[ImageType] ,
		[ImageId] ,
		[IsShared] ,
		[DownloadCount] ,
		[SKDateTime] 
		from DWIRIS.Temp_FactScanReportSharing src
		where not exists (select * from DWIRIS.FactScanReportSharing dst where dst.ID = src.ID and dst.sourcesystem=src.sourcesystem)
		option (label = 'DWIRIS.LoadFactScanReportSharing_Insert');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadFactScanReportSharing_Insert', @rc = @RowsInserted out

		if object_id ('DWIRIS.Temp_FactScanReportSharing', 'U') is not null
		drop table DWIRIS.Temp_FactScanReportSharing
	end
	else
	begin --full load
		if object_id ('DWIRIS.FactScanReportSharingPrevious', 'U') is not null
			drop table DWIRIS.FactScanReportSharingPrevious

		rename object DWIRIS.FactScanReportSharing to FactScanReportSharingPrevious
		rename object DWIRIS.Temp_FactScanReportSharing to FactScanReportSharing

		if object_id ('DWIRIS.FactScanReportSharingPrevious', 'U') is not null
		drop table DWIRIS.FactScanReportSharingPrevious
		rename object DWIRIS.PK_TempFactScanReportSharing to PK_FactScanReportSharing
		
		select @RowsInserted = count(*)
		from DWIRIS.FactScanReportSharing

	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end