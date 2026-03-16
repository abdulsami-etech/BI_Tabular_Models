CREATE PROC [DWSAP].[LoadChinaMarkup] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 

DECLARE  @lAStdatetime datetime
,@RowsInserted	int = 0
,@RowsUpdated	int = 0
,@IsFullLoad	bit = 0
IF (EXISTS (SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'DWSAP'
AND  TABLE_NAME = 'ChinaMarkup'))
BEGIN
SET @lAStdatetime = (SELECT ISNULL(MAX(CONVERT(datetime,ADLSTimestamp)) ,'1900-01-01 00:00:00') FROM DWSAP.ChinaMarkup)
END
ELSE
BEGIN
SET @lAStdatetime = '1900-01-01 00:00:00'
END


INSERT INTO DWSAP.ChinaMarkup 
SELECT 
LZBatchID,
ADLSBatchID,
ADLSTimestamp,
[SalesOrder] as [Sales Order], 
[ProdOrder] as [Production Order], 
[CompanyCode] as [Company Code], 
[Plant] as [Plant], 
[FiscalYear] as [Fiscal Year], 
[Period] as [Period], 
[GLAccount] as [GL Account], 
[Category] as [Category], 
[FIDocumentNo] as [FI Document No.], 
[FIDocLineItem] as [FI Doc. Line Item], 
--deriving the values of Amount in Document Currency based on Amount in DC column
CASE WHEN [AmountinDocumentCurrency] = '-' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([AmountinDocumentCurrency], ',','')) END AS [Amount in Document Currency], 
[DocumentCurrency] as [Document Currency], 
--deriving the values of Amount in Local Currency based on Amount in LC column
CASE WHEN [AmountinLocalCurrency] = '-' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([AmountinLocalCurrency], ',', '')) END AS [Amount in Local Currency], 
[LocalCurrency] as [Local Currency], 
--deriving the values of Amount in Local Currency2 based on Amount in LC2 column
CASE WHEN [AmountinLocalCurrency2] = '-' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([AmountinLocalCurrency2], ',', '')) END AS [Amount in Local Currency2], 
[LocalCurrency2] as [Local Currency2], 
[Material] as [Material], 
[Units] as [Units], 
[UoM] as [UoM], 
[ProfitCenter] as [Profit Center], 
[MaterialDocNo] as [Material Doc No], 
[StorageLocation] as [Storage Location], 
[MovementType] as [Movement Type], 
--deriving the values of Material in local curr based on Material in local curr column
CASE WHEN [Materialinlocalcurr] = '-' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([Materialinlocalcurr], ',', '')) END AS [Material in local curr], 
--deriving the values of Labor in local curr based on Labor in local curr column
CASE WHEN [Laborinlocalcurr] = ' -' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([Laborinlocalcurr], ',', '')) END AS [Labor in local curr], 
--deriving the values of Over Head in local curr based on Over Head in local curr column
CASE WHEN [OverHeadinlocalcurr] = ' -' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([OverHeadinlocalcurr], ',', '')) END AS [Over Head in local curr], 
--deriving the values of Freight in local curr based on Freight in local curr column
CASE WHEN [Freightinlocalcurr] = ' -' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([Freightinlocalcurr], ',', '')) END AS [Freight in local curr], 
--deriving the values of Base Cost in local curr based on Base Cost in local curr column
CASE WHEN [BaseCostinlocalcurr] = '-' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([BaseCostinlocalcurr], ',', '')) END AS [Base Cost in local curr], 
--deriving the values of Mark Up in local curr based on Mark Up in local curr column
CASE WHEN [MarkUpinlocalcurr] = ' -' THEN '0' ELSE CONVERT(Decimal(30, 3),REPLACE([MarkUpinlocalcurr], ',', '')) END AS [Mark Up in local curr], 
--deriving the values of Variance in local curr based on Variance column
CASE WHEN [VarianceinLC] = '-' THEN '0' ELSE CONVERT(INT,REPLACE([VarianceinLC], ',', '')) END AS [Variance in Local Currency], 
--deriving the values of Material in USD based on Material in USD column
CASE WHEN [MaterialinUSD] = '-' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([MaterialinUSD], ',', '')) END AS [Material in USD], 
--deriving the values of Labor in USD based on Labor in USD column
CASE WHEN [LaborinUSD] = ' -' THEN '0' ELSE CONVERT(Decimal(30, 3),REPLACE([LaborinUSD], ',', '')) END AS [Labor in USD], 
--deriving the values of Over Head in USD based on Over Head in USD column
CASE WHEN [OverHeadinUSD] = ' -' THEN '0' ELSE CONVERT(Decimal(30, 3),REPLACE([OverHeadinUSD], ',', '')) END AS [Over Head in USD], 
--deriving the values of Freight in USD based on Freight in USD column
CASE WHEN [FreightinUSD] = ' -' THEN '0' ELSE CONVERT(Decimal(30, 3),REPLACE([FreightinUSD], ',', '')) END AS[Freight in USD], 
--deriving the values of Base Cost in USD based on Base Cost in USD column
CASE WHEN [BaseCostinUSD] = '-' THEN '0' ELSE CONVERT(Decimal(15, 3),REPLACE([BaseCostinUSD], ',', '')) END AS [Base Cost in USD], 
--deriving the values of Mark Up in USD based on Mark Up in USD column
CASE WHEN [MarkupinUSD] = ' -' THEN '0' ELSE CONVERT(Decimal(30, 3),REPLACE([MarkupinUSD], ',', '')) END AS [Mark-up in USD], 
--deriving the values of Variance in USD based on Variance column
CASE WHEN [VarianceinUSD] = '-' THEN '0' ELSE CONVERT(INT,REPLACE([VarianceinUSD], ',', '')) END AS [Variance in USD], 
[COPAReportingChannel] as [COPA Reporting Channel], 
[COPAProfitcenter] as [COPA Profit center], 
[COPAProductHierarchy] as [COPA Product Hierarchy], 
[COPAItemCategory] as [COPA Item Category], 
CONVERT(Date,GETDATE()) as [Insert_Date]  
FROM 
SrcSAPFile.chinaMarkup
WHERE ADLSTimestamp>@lAStdatetime
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
-- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
SELECT @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated