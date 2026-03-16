CREATE PROC [DW].[LoadFactPipeline] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@RowsInsertedFromTemp	int = 0
		,	@RowsInsertedFromSelf	int = 0
		,	@beginDate date

	set @beginDate = '2016-01-01'

	DECLARE @CurrentDateTime DATETIME = GETUTCDATE();
	
	if object_id ('tempdb..#tmpOrdersToProcess') is not null
		drop table #tmpOrdersToProcess

	CREATE TABLE #tmpOrdersToProcess  WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
	
	SELECT DISTINCT SAPOrderNumber
	FROM DW.FactVolume
	WHERE DWBatchID > (SELECT ISNULL(MAX(BatchID),0) FROM DW.FactPipeline)
	
	if object_id('tempdb..#TempFactPipeline') is not null
		drop table #TempFactPipeline

	CREATE TABLE #TempFactPipeline  WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
	
	SELECT CONVERT(CHAR(40), '')	AS DWHashKey
		,	p.SAPOrderNumber
		,	d.DateKey
		,	p.StatusDate
		,	p.CalStatusDate
		,	p.SKOrderStatus
		--,	p.ProductKey
		,	p.SKContact
		,	p.SKOrder
		,	p.SecRegion
		,	p.SKAccountSoldTo
		,	p.TreatmentOption
		,	p.DeliverableType
		,	p.ProfitCenter
		,	NULL AS CCAAAging
		,	p.BatchID
		
	FROM (
		SELECT	t.SAPOrderNumber
			,	t.StatusDate
			,	LEAD(t.StatusDate, 1, DATEADD(dd, 1, ExpiryDate)) OVER (PARTITION BY t.SAPOrderNumber ORDER BY t.StatusDate) AS StatusDateEnd
			,	CASE WHEN SKOrderStatus = 90 AND (LAG(t.SKOrderStatus, 1, -1) OVER (PARTITION BY t.SAPOrderNumber ORDER BY t.StatusDate)) = 90 THEN LAG(t.StatusDate, 1, t.StatusDate) OVER (PARTITION BY t.SAPOrderNumber ORDER BY t.StatusDate) 
						WHEN SKOrderStatus = 90 THEN t.StatusDate ELSE NULL END AS CalStatusDate
			,	t.SKOrderStatus
			--,	t.ProductKey
			,	t.SKContact
			,	t.SKOrder
			,	t.SecRegion
			,	t.SKAccountSoldTo
			,	t.TreatmentOption
			,	t.DeliverableType
			,	t.ProfitCenter
			,	t.BatchID
		FROM (
			SELECT TOP (1) WITH ties
					f.SAPOrderNumber
				,	f.StatusDate
				,	CASE WHEN f.SKOrderStatus =82 THEN 85 ELSE f.SKOrderStatus END AS SKOrderStatus
				,	ISNULL(fe.ExpiryDate, CAST(GETDATE() AS DATE)) AS ExpiryDate
				--,	coalesce(o.CancellationDate, o.CCADate, o.ShipDate, tmp.ArchivedDate, getdate()) as ExpiryDate
				--,	f.ProductKey
				,	f.SKContact
				,	f.SKOrder
				,	f.SecRegion
				,	f.SKAccountSoldTo
				,	f.TreatmentOption
				,	f.DeliverableType
				,	f.ProfitCenter
				,	f.DWBatchID as BatchID
			FROM DW.FactVolume f
			LEFT JOIN (SELECT SAPOrderNumber, MIN(StatusDate) AS ExpiryDate FROM DW.FactVolume
			WHERE SKOrderStatus IN (108,110,118,120) 
			GROUP BY SAPOrderNumber) fe ON f.SAPOrderNumber = fe.SAPOrderNumber
			WHERE 
			(
					f.SAPOrderNumber IN (SELECT SAPOrderNumber FROM #tmpOrdersToProcess)
			) AND 
				f.TreatmentCategory = N'Primary'
				AND f.StatusDate >= @beginDate
				--and f.StatusDate >= convert(date, o.SubmitDate)
				AND f.SKOrderStatus NOT IN (50, 120, 109)
				
				ORDER BY ROW_NUMBER() OVER (		--keep only 1 row for order and date
				PARTITION BY f.SAPOrderNumber, f.StatusDate 
				ORDER BY f.StatusDate DESC, f.MinStatusDate DESC, f.SKOrderStatus DESC)
		) t
	) p
INNER JOIN DW.DimDateTime d ON d.DateKey >= p.StatusDate 
								AND d.DateKey < p.StatusDateEnd
								
	
	UPDATE #TempFactPipeline
	SET CCAAAging =  CASE WHEN SKOrderStatus != 90 THEN NULL		-- Not CCAA
			 ELSE DATEDIFF(day, CalStatusDate, DateKey)
			 END
		,	DWHashKey =
		convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, SAPOrderNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, DateKey), N'N/A')
				)
			, 2)

DELETE FROM DW.FactPipeline  WHERE SAPOrderNumber IN (SELECT SAPOrderNumber FROM #tmpOrdersToProcess)

INSERT INTO DW.FactPipeline (
		DWBatchID
		,	DWHashKey
		,	SAPOrderNumber
		,	DateKey
		,	StatusDate
		,	SKOrderStatus
		--,	ProductKey
		,	SKContact
		,	SKOrder
		,	SecRegion
		,	SKAccountSoldTo
		,	TreatmentOption
		,	DeliverableType
		,	ProfitCenter
		,	CCAAAging
		,	BatchID
		,	CreatedDate
		,	ModifiedDate
		)
		SELECT	@BatchID
		,	DWHashKey
		,	SAPOrderNumber
		,	DateKey
		,	StatusDate
		,	SKOrderStatus
		--,	ProductKey
		,	SKContact
		,	SKOrder
		,	SecRegion
		,	SKAccountSoldTo
		,	TreatmentOption
		,	DeliverableType
		,	ProfitCenter
		,	CCAAAging
		,	BatchID
		,	@CurrentDateTime
		,	@CurrentDateTime
		FROM #TempFactPipeline src
		WHERE NOT EXISTS(select * from DW.FactPipeline dst WHERE dst.DWHashKey = src.DWHashKey)
		OPTION (LABEL = 'DW.LoadFactPipeline_InsertFromTemp');
		
	exec CTRL.GetLastRowCount @Label = 'DW.LoadFactPipeline_InsertFromTemp', @rc = @RowsInsertedFromTemp out



	
INSERT INTO DW.FactPipeline (
		DWBatchID
		,	DWHashKey
		,	SAPOrderNumber
		,	DateKey
		,	StatusDate
		,	SKOrderStatus
		--,	ProductKey
		,	SKContact
		,	SKOrder
		,	SecRegion
		,	SKAccountSoldTo
		,	TreatmentOption
		,	DeliverableType
		,	ProfitCenter
		,	CCAAAging
		,	BatchID
		,	CreatedDate
		,	ModifiedDate
)
SELECT	@BatchID
		,	convert(char(40),
			hashbytes('SHA1',isnull(convert(nvarchar, SAPOrderNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, DateKey), N'N/A')
				)
			, 2) AS DWHashKey
		,	p.SAPOrderNumber
		,	d.DateKey
		,	p.StatusDate
		,	p.SKOrderStatus
			--,	p.ProductKey
		,	p.SKContact
		,	p.SKOrder
		,	p.SecRegion
		,	p.SKAccountSoldTo
		,	p.TreatmentOption
		,	p.DeliverableType
		,	p.ProfitCenter
		,	CASE WHEN p.SKOrderStatus = 90 --CCAA
					THEN p.CCAAAging + ROW_NUMBER() OVER (PARTITION BY p.SAPOrderNumber ORDER BY d.DateKey)
					ELSE NULL
				END AS CCAAAging
		,	p.BatchID
		,	@CurrentDateTime
		,	@CurrentDateTime
		FROM (
			SELECT	fp.SAPOrderNumber
				,	fp.DateKey as DateFrom
				,	fp.StatusDate
				,	fp.SKOrderStatus
				--,	fp.ProductKey
				,	fp.SKContact
				,	fp.SKOrder
				,	fp.SecRegion
				,	fp.SKAccountSoldTo
				,	fp.TreatmentOption
				,	fp.DeliverableType
				,	fp.ProfitCenter
				,	fp.CCAAAging
				,	fp.BatchID
				--,	convert(date, coalesce(o.CancellationDate, o.CCADate, o.ShipDate, getdate())) as DateTo
				,	ISNULL(fe.DateTo, CAST(GETDATE() AS DATE)) AS DateTo
			FROM (
				SELECT	p.SAPOrderNumber
					,	MAX(p.DateKey) AS LastDate
				FROM DW.FactPipeline p
				GROUP BY p.SAPOrderNumber
			) p
			INNER JOIN DW.FactPipeline fp ON fp.SAPOrderNumber = p.SAPOrderNumber
										and fp.DateKey = p.LastDate
			LEFT JOIN (SELECT SAPOrderNumber, MIN(StatusDate) AS DateTo FROM DW.FactVolume
			WHERE SKOrderStatus IN (108,110,118,120)
			GROUP BY SAPOrderNumber) fe ON fp.SAPOrderNumber = fe.SAPOrderNumber
			WHERE p.LastDate < ISNULL(fe.DateTo, CAST(GETDATE() AS DATE)) --intrested only in actual rows
			--p.LastDate < CONVERT(DATE, coalesce(o.CancellationDate, o.CCADate, o.ShipDate, tmp.ArchivedDate, getdate())) --intrested only in actual rows
		) p
		INNER JOIN DW.DimDateTime d ON d.DateKey > p.DateFrom --next day
									AND d.DateKey <= p.DateTo
		OPTION (LABEL = 'DW.LoadFactPipeline_InsertFromSelf');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadFactPipeline_InsertFromSelf', @rc = @RowsInsertedFromSelf out

	SET @RowsInserted = @RowsInsertedFromTemp + @RowsInsertedFromSelf

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end