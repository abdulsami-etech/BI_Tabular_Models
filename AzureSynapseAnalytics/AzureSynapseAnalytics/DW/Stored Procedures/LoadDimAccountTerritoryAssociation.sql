CREATE PROC [DW].[LoadDimAccountTerritoryAssociation] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id ('DW.DimAccountTerritoryAssociationNew', 'U') is not null
		drop table DW.DimAccountTerritoryAssociationNew

	create table DW.DimAccountTerritoryAssociationNew (
		[SKAccount]                INT            NOT NULL,
		[SKTerritory]              INT            NOT NULL,
		[ADLSBatchID]              INT            NOT NULL,
		[ADLSTimestamp]            DATETIME2 (0)  NOT NULL,
		[LZBatchID]                INT            NOT NULL,
		[DWBatchID]                INT            NOT NULL,
		[Id]                       NCHAR(18)      NOT NULL,
		[KeyAccount]               NCHAR(18)      NOT NULL,
		[KeyTerritory]             NCHAR(18)      NOT NULL
	)-- with (clustered index([SKAccount]), distribution = replicate);
	with (heap, distribution = replicate);

	insert into DW.DimAccountTerritoryAssociationNew (
			[SKAccount]
		,	[SKTerritory]
		,	[ADLSBatchID]
		,	[ADLSTimestamp]
		,	[LZBatchID]
		,	[DWBatchID]
		,	[Id]  
		,	[KeyAccount]
		,	[KeyTerritory]
	)
	select top (1) with ties
			ha.SKAccount
		,	ht.SKTerritory
		,	ota.ADLSBatchID
		,	ota.ADLSTimestamp
		,	ota.LZBatchID
		,	@BatchID as DWBatchID
		,	ota.Id
		,	ha.KeyAccount
		,	ht.KeyTerritory
	from SrcSFDC.ObjectTerritory2Association ota
	inner join DW.HubAccount ha on ha.KeyAccount = ota.ObjectId
	inner join DW.HubTerritory ht on ht.KeyTerritory = ota.Territory2Id
	where ota.SobjectType = 'Account'
	order by row_number() over (partition by ha.SKAccount, ht.SKTerritory order by ota.LastModifiedDate desc, Id)

	if object_id ('DW.DimAccountTerritoryAssociation', 'U') is not null
	begin
		if object_id ('DW.DimAccountTerritoryAssociationPrevious', 'U') is not null
			drop table DW.DimAccountTerritoryAssociationPrevious

		rename object DW.DimAccountTerritoryAssociation to DimAccountTerritoryAssociationPrevious
		rename object DW.DimAccountTerritoryAssociationNew to DimAccountTerritoryAssociation
		drop table DW.DimAccountTerritoryAssociationPrevious
	end
	else
	begin
		rename object DW.DimAccountTerritoryAssociationNew to DimAccountTerritoryAssociation
	end

	alter table DW.DimAccountTerritoryAssociation add constraint PK_DimAccountTerritoryAssociation primary key nonclustered (SKAccount, SKTerritory) not enforced
	create clustered index IX_CL_DimAccountTerritoryAssociation on DW.DimAccountTerritoryAssociation (SKAccount)

	select @RowsInserted = count(*) 
	from DW.DimAccountTerritoryAssociation

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated


end
