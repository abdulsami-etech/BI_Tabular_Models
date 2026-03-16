CREATE PROC [DW].[LoadFactCCPosting] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Declare @CurrentDateTime datetime = GETUTCDATE();
	
	if object_id('tempdb..#TempFactCCPosting') is not null
		drop table #TempFactCCPosting

	create table #TempFactCCPosting with (distribution = round_robin, heap) as 
	

select CONVERT(CHAR(40), '') AS DWHashKey,fl.DgnWorkOrderNumber SAPOrderNumber, cst.SAPTreatmentOption, dc.CountryCode, csd.SAPDeliverableType, cst.ProductHierarchy
, saph.zzdeli_cate TreatmentCategory,dt.DateKey CCPostingDate
from dwTops.FactLotHistory fl 
inner join DWTops.DimOPeration dop on fl.SKOperation= dop.SKOperation
inner join dwtops.DimDoctor dd on fl.SKDoctor = dd.SKDoctor
inner join dw.DimCountry dc on dd.SKCountry = dc.SKCountry
inner join SrcSAP.VBAK saph on fl.DgnWorkOrderNumber = convert(bigint,saph.VBELN)
inner join SrcSAP.VBAP sapd on saph.VBELN = sapd.VBELN
inner join SrcSAPFile.TreatmentOption cst on cst.SAPTreatmentOption = sapd.zzTREAT_OPT
inner join SrcSAPFile.DeliverableType csd on csd.SAPDeliverableType = sapd.zzDELI_TYPE
inner join DW.DimDateTime dt on fl.SKStartDate = dt.SKDate
where dop.OperationName in ('ClinCheck','MTP') --and saph.zzdeli_cate='Primary'
and sapd.pstyv='Z000' and cst.ProductHierarchy is not null
and dt.DateKey  >= (SELECT ISNULL(DATEADD(dd,-1,MAX(CCPostingDate)), '1900-01-01') FROM [DW].[FactCCPosting])

update #TempFactCCPosting set DWHashKey=
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, SAPOrderNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SAPTreatmentOption), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CountryCode), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SAPDeliverableType), N'N/A')
				  + N'|' + isnull(convert(nvarchar, ProductHierarchy), N'N/A')
				  + N'|' + isnull(convert(nvarchar, CCPostingDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, TreatmentCategory), N'N/A')
				)
			, 2)


	insert into DW.FactCCPosting (
			DWBatchID
		,	DWHashKey
		,	SAPOrderNumber
		,	SAPTreatmentOption
		,	CountryCode
		,	SAPDeliverableType
		,	ProductHierarchy
		,	CCPostingDate
		,	TreatmentCategory
		,	CreatedDate
		,	ModifiedDate
	)
	select	@BatchID
		,	DWHashKey
		,	SAPOrderNumber
		,	SAPTreatmentOption
		,	CountryCode
		,	SAPDeliverableType
		,	ProductHierarchy
		,	CCPostingDate
		,	TreatmentCategory
		,	@CurrentDateTime
		,	@CurrentDateTime
	from #TempFactCCPosting src
	where not exists(select * from DW.FactCCPosting dst where dst.DWHashKey = src.DWHashKey)
	option (label = 'DW.LoadFactCCPosting_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadFactCCPosting_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end