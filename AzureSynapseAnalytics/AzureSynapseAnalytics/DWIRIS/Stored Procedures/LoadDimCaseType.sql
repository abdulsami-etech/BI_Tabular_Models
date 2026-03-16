CREATE PROC [DWIRIS].[LoadDimCaseType] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimCaseType') is not null
		drop table #TempDimCaseType

	create table #TempDimCaseType with (distribution = round_robin, heap) as 
	select	h.SKCaseType							as SKCaseType
		,	t.ADLSBatchID							as ADLSBatchID
		,	t.ADLSTimestamp							as ADLSTimestamp
		,	t.LZBatchID								as LZBatchID
		,	convert(char(40), 
				hashbytes('SHA1', 
							 convert(nvarchar,isnull(t.CaseTypeGenericDescription, ''))
					+ N'|' + convert(nvarchar, isnull(t.CaseTypeGroupID, ''))
					+ N'|' + convert(nvarchar,isnull(t.DisplayOrder, ''))
					+ N'|' + CASE WHEN t.CaseTypeId IN ('1','2','4','6','20','21','22','23','24','31','35','40','42','44','50') THEN 'Restorative'
									 WHEN t.CaseTypeId IN ('5','13','41') THEN 'OrthoCAD'
									 WHEN t.CaseTypeId IN ('30','32','33','34','36','43') THEN 'Invisalign'
									 ELSE 'Other' END 

				)
			, 2)									as DWHash
		,	convert(varchar(64), t.CaseTypeID)		as KeyCaseType
		,   'MAT' as SourceSystem
		,	convert(varchar(255), t.CaseTypeGenericDescription)	as CaseTypeGenericDescription
		,	t.CaseTypeGroupID		as CaseTypeGroupID
		,	t.DisplayOrder		    as CaseTypeDisplayOrder
		,	CASE WHEN t.CaseTypeId IN ('1','2','4','6','20','21','22','23','24','31','35','40','42','44','50') THEN 'Restorative'
									 WHEN t.CaseTypeId IN ('5','13','41') THEN 'OrthoCAD'
									 WHEN t.CaseTypeId IN ('30','32','33','34','36','43') THEN 'Invisalign'
									 ELSE 'Other' END 
			as CaseTypeCategory
	from SrcMAT.Case_CaseTypes t
	inner join DWIRIS.hubCaseType h on h.keyCaseType=t.caseTypeId
	and h.SourceSystemCode='MAT'
	where t.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DWIRIS.DimCaseType)

	if not exists (select * from DWIRIS.DimCaseType where SKCaseType = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWIRIS.DimCaseType (
				SKCaseType
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,   [SourceSystem]
			,	KeyCaseType
			,	[CaseTypeGenericDescription]
			,   [CaseTypeCategory]
			,   [CaseTypeGroupID]
			,   [CaseTypeDisplayOrder]
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,   'N/A'
			,	'0000'
			,	'N/A'
			,	'N/A'
			,   -1
			,   -1
		)
	end

	update DWIRIS.DimCaseType
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchId
		,	DWHash = src.DWHash
		,	CaseTypeGenericDescription = src.CaseTypeGenericDescription
		,   CaseTypeCategory=src.CaseTypeCategory
		,	CaseTypeGroupID=src.CaseTypeGroupID
		,   CaseTypeDisplayOrder=src.CaseTypeDisplayOrder
	from #TempDimCaseType src
	where DWIRIS.DimCaseType.SKCaseType = src.SKCaseType
		and DWIRIS.DimCaseType.DWHash != src.DWHash
	option (label = 'DWIRIS.LoadDimCaseType_Update');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimCaseType_Update', @rc = @RowsUpdated out

	insert into DWIRIS.DimCaseType (
			SKCaseType
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyCaseType
		,   SourceSystem
		,	CaseTypeGenericDescription
		,	CaseTypeCategory
		,   CaseTypeGroupID
		,   CaseTypeDisplayOrder
	)
	select	src.SKCaseType
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyCaseType
		,   Src.SourceSystem
		,	src.CaseTypeGenericDescription
		,	src.CaseTypeCategory
	    ,	src.CaseTypeGroupID
		,	src.CaseTypeDisplayOrder
	from #TempDimCaseType src
	where not exists(select * from DWIRIS.DimCaseType dst where dst.SKCaseType = src.SKCaseType)
	option (label = 'DWIRIS.LoadDimCaseType_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimCaseType_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end