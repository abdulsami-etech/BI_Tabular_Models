CREATE PROC [DWIRIS].[LoadDimEntitlement] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0
		--,	@BatchID [int]	=0
		--,@LastSuccessfullDWTimestamp [datetime2](0)='01/01/2019',@IsForceFullLoad bit=1

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if object_id('DWIRIS.Temp_DimEntitlement','U') is not null
		drop table DWIRIS.Temp_DimEntitlement

	CREATE TABLE [DWIRIS].[Temp_DimEntitlement]
	(
	[SKEntitlement] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NOT NULL,
	KeyEntitlement [char](40) NOT NULL,
	SourceSystem [char](40) NOT NULL,
	[AccountID] [nchar](50) NULL,
	[SKAccount] [int] NOT NULL,
	[AssetID] [nchar](50) NULL,
	[SKASset] [int] NOT NULL,
	[ContractLineItemID] [nchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[CreatedByID] [nchar](50) NULL,
	[SKUserCreatedBy] [int] NULL,
	[EndDate] [datetime2](7) NULL,
	[LastModifiedDate] [datetime2](7) NULL,
	[LastModifiedByID] [nchar](50) NULL,
	[SKUserLastModifiedBy] [int] NULL,
	[Name] [nvarchar] (300) NULL,
	[ServiceContractID] [nchar](50) NULL,
	[StartDate] [datetime2](7) NULL,
	[Status] [nchar](300) NULL,
	[Type] [nchar](300) NULL
	)
	WITH
	(
		DISTRIBUTION = REPLICATE,
		CLUSTERED INDEX
		(
			[SKEntitlement] ASC
		)
	)

	insert into [DWIRIS].[Temp_DimEntitlement]
	([SKEntitlement]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[DWHash]
      ,[KeyEntitlement]
      ,[SourceSystem]
      ,[AccountID]
      ,[SKAccount]
      ,[AssetID]
      ,[SKASset]
      ,[ContractLineItemID]
      ,[CreatedDate]
      ,[CreatedByID]
      ,[SKUserCreatedBy]
      ,[EndDate]
      ,[LastModifiedDate]
      ,[LastModifiedByID]
      ,[SKUserLastModifiedBy]
      ,[Name]
      ,[ServiceContractID]
      ,[StartDate]
      ,[Status]
      ,[Type]
	  )



	select	
				hub.SKEntitlement					as SKEntitlement
		  ,	    a.ADLSBatchID						as ADLSBatchID
		  ,		a.ADLSTimestamp						as ADLSTimestamp
		  ,		a.LZBatchID							as LZBatchID
		  ,     @BatchID							as DWBatchID
		  ,		convert(char(40), '')				as DWHash
		  ,		a.[ID]								as KeyEntitlement
		  ,		'SFDC'								as SourceSystem
		  ,     a.AccountID							as AccountID
		  ,		isnull(acc.SKAccount,-1)			as SKAccount
		  ,		a.AssetID							as AssetID
		  ,		isnull(ast.SKAsset,-1)				as SKAsset
		  ,		a.ContractLineItemID				as ContractLineItemID
		  ,		a.CreatedDate						as CreatedDate
		  ,		a.CreatedByID						as CreatedByID
		  ,     isnull(cr.SKUser,-1)				as SKUserCreatedBy
		  ,		a.EndDate							as EndDate
		  ,		a.[LastModifiedDate]				as [LastModifiedDate]
		  ,		a.[LastModifiedByID]				as [LastModifiedByID]
		  ,		isnull(up.SKUser,-1)				as [SKUserLastModifiedBy]
		  ,		a.[Name]							as [Name]
		  ,     a.[ServiceContractID]				as ServiceContractID
		  ,		a.StartDate							as StartDate
		  ,     a.[Status]							as [Status]
	      ,		a.[Type]							as [Type]
	from [SrcSFDC].[Entitlement] a
	inner join DWIRIS.HubEntitlement hub on hub.KeyEntitlement=a.ID and hub.SourceSystemCode='SFDC'
		left join  DW.HubAccount acc on acc.KeyAccount=a.accountid and acc.SourceSystemCode='SFDC'
		left join  DWIRIS.HubAsset Ast on Ast.KeyAsset= a.assetid 
		left join  DWIRIS.HubUser  cr on cr.keyuser = a.LastModifiedbyid and cr.SourceSystemCode='SFDC'
		left join  DWIRIS.HubUser  up on up.keyuser = a.createdbyid and up.SourceSystemCode='SFDC'
	where a.ID is not null
		and (a.ADLSTimestamp >= @LastSuccessfullDWTimestamp or @IsFullLoad=1)
		union all




	select	  '-1'              as SKEntitlement
	    ,   -1				as ADLSBatchID
		,	'19000101'		as ADLSTimestamp
		,	-1				as LZBatchID
		,	@BatchID		as DWBatchID
		,	''				as DWHash
		,	'-1'			as KeyEntitlement
		,   'N/A'           as SourceSystem
		,   '-1'              as AccountID
		,   -1              as SKAccount
		,   '-1'            as AssetID
		,   -1              as SKAsset
		,   '-1'            as ContractLineItemID
		,   '19000101'      as CreatedDate
		,   '-1'            as CreatedByID
		,   -1              as SKUserCreatedBy
		,   '19000101'      as EndDate
		,   '19000101'      as [LastModifiedDate]
	    ,	'-1'			as [LastModifiedByID]
		,	'-1'			as [SKUserLastModifiedBy]
		,	'N/A'			as [Name]
		,   '-1'			as ServiceContractID
		,	'19000101'		as StartDate
		,   'N/A'			as [Status]
	    ,	'N/A'			as [Type]
	


	--update HASH  (HASH DOES NOT INCLUDE BUSINESS KEY AND ETL FIELDS!!! )
	update DWIRIS.Temp_DimEntitlement set DWHash=
		convert(char(40),
			hashbytes('SHA1',
					   convert(nvarchar,ISNULL(KeyEntitlement,''))
				  +'|'+convert(nvarchar,ISNULL(SourceSystem,''))
				  +'|'+convert(nvarchar,ISNULL(AccountID,''))
				  +'|'+convert(nvarchar,ISNULL(SKAccount,''))
				  +'|'+convert(nvarchar,ISNULL(AssetID,''))
				  +'|'+convert(nvarchar,ISNULL(SKAsset,''))
				  +'|'+convert(nvarchar,ISNULL(ContractLineItemID,''))
				  +'|'+convert(nvarchar,ISNULL(CreatedDate,''))
				  +'|'+convert(nvarchar,ISNULL(CreatedByID,''))
				  +'|'+convert(nvarchar,ISNULL(SKUserCreatedBy,''))
				  +'|'+convert(nvarchar,ISNULL(EndDate,''))
				  +'|'+convert(nvarchar,ISNULL([LastModifiedDate],''))
				  +'|'+convert(nvarchar,ISNULL([LastModifiedByID],''))
				  +'|'+convert(nvarchar,ISNULL([SKUserLastModifiedBy],''))
				  +'|'+convert(nvarchar,ISNULL([Name],''))
				  +'|'+convert(nvarchar,ISNULL(ServiceContractID,''))
				  +'|'+convert(nvarchar,ISNULL(StartDate,''))
				  +'|'+convert(nvarchar,ISNULL([Status],''))
				  +'|'+convert(nvarchar,ISNULL([Type],''))
				)
			,2)
			where SKEntitlement != -1
	if @IsFullLoad = 0
	begin
		update DWIRIS.DimEntitlement
		set	[ADLSBatchID] = src.[ADLSBatchID]
      ,[ADLSTimestamp] = src.[ADLSTimestamp]
      ,[LZBatchID]	= src.[ADLSBatchID]
      ,[DWBatchID]	= src.[DWBatchID]
      ,[DWHash]	= src.[DWHash]
      ,[KeyEntitlement]	= src.[KeyEntitlement]
      ,[SourceSystem]	= src.[SourceSystem]
      ,[AccountID]	= src.[AccountID]
      ,[SKAccount]	= src.[SKAccount]
      ,[AssetID]	= src.[AssetID]
      ,[SKASset]	= src.[SKASset]
      ,[ContractLineItemID]	= src.[ContractLineItemID]
      ,[CreatedDate]	= src.[CreatedDate]
      ,[CreatedByID]	= src.[CreatedByID]
      ,[SKUserCreatedBy]	= src.[SKUserCreatedBy]
      ,[EndDate]	= src.[EndDate]
      ,[LastModifiedDate]	= src.[LastModifiedDate]
      ,[LastModifiedByID]	= src.[LastModifiedByID]
      ,[SKUserLastModifiedBy]	= src.[SKUserLastModifiedBy]
      ,[Name]	= src.[Name]	
	  ,[ServiceContractID]	= src.[ServiceContractID]
      ,[StartDate]	= src.[StartDate]
      ,[Status]	= src.[Status]
      ,[Type]	= src.[Type]
	  from DWIRIS.Temp_DimEntitlement src
		where DWIRIS.DimEntitlement.SKEntitlement = src.SKEntitlement
			and DWIRIS.DimEntitlement.DWHash != src.DWHash
		option (label = 'DWIRIS.LoadDimEntitlement_Update');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimEntitlement_Update', @rc = @RowsUpdated out

	insert into DWIRIS.DimEntitlement (
	 [SKEntitlement]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[DWHash]
      ,[KeyEntitlement]
      ,[SourceSystem]
      ,[AccountID]
      ,[SKAccount]
      ,[AssetID]
      ,[SKASset]
      ,[ContractLineItemID]
      ,[CreatedDate]
      ,[CreatedByID]
      ,[SKUserCreatedBy]
      ,[EndDate]
      ,[LastModifiedDate]
      ,[LastModifiedByID]
      ,[SKUserLastModifiedBy]
      ,[Name]
      ,[ServiceContractID]
      ,[StartDate]
      ,[Status]
      ,[Type]
	  )
		select	 [SKEntitlement]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
      ,[DWHash]
      ,[KeyEntitlement]
      ,[SourceSystem]
      ,[AccountID]
      ,[SKAccount]
      ,[AssetID]
      ,[SKASset]
      ,[ContractLineItemID]
      ,[CreatedDate]
      ,[CreatedByID]
      ,[SKUserCreatedBy]
      ,[EndDate]
      ,[LastModifiedDate]
      ,[LastModifiedByID]
      ,[SKUserLastModifiedBy]
      ,[Name]
      ,[ServiceContractID]
      ,[StartDate]
      ,[Status]
      ,[Type]
		from DWIRIS.Temp_DimEntitlement src
		where not exists (select * from DWIRIS.DimEntitlement dst where dst.SKEntitlement = src.SKEntitlement)
		option (label = 'DWIRIS.LoadDimEntitlement_Insert');

		exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimEntitlement_Insert', @rc = @RowsInserted out

		if object_id ('DWIRIS.Temp_DimEntitlement', 'U') is not null
		drop table DWIRIS.Temp_DimEntitlement
	end
	else
	begin --full load
		if object_id ('DWIRIS.DimEntitlementPrevious', 'U') is not null
			drop table DWIRIS.DimEntitlementPrevious

		rename object DWIRIS.DimEntitlement to DimEntitlementPrevious
		rename object DWIRIS.Temp_DimEntitlement to DimEntitlement
		
		if object_id ('DWIRIS.DimEntitlementPrevious', 'U') is not null
		drop table DWIRIS.DimEntitlementPrevious

		select @RowsInserted = count(*)
		from DWIRIS.DimEntitlement

	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end


