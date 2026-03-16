CREATE VIEW [DWRev].[Curated_CVRevenue] AS 
select  r.[Sales Order] SAPOrderNumber, sh.[Sales Document Type] SalesDocType, sh.[Sales Document Category] as SalesDocCat,r.[Posting Date] PostingDate
, r.[Period/Year] Period, sh.ClinId,r.[Reporting Channel] Channel,  r.[Country Key] CountryCode,r.[Company Code] CompanyCode, r.[Currency Key]  Currency
, Try_Convert(int,r.[Profit Center]) ProfitCenter, r.[Product Hierarchy] ProdH, r.[Cost Element] CostElement, r.[Sales Organisation] SalesOrg
, r.[Item Category] ItemCat,rvt.Valuetype, Try_Convert(int,r.[Material Number]) MaterialNumber, r.[Treatment Option] TreatmentOption
,r.[Deliverable Type] DeliverableType, r.[COPA Revenue], ce.[Level 6] CELvl6, gh.SecRegion
from [TABSAP].[FactCOPARevenue_Performance] r left join  tabsap.dimcostelement ce on ce.[Cost Element] = r.[Cost Element]
join DWSAP.DimCOPARevenueValueType rvt on r.[Value Fields] = rvt.ValueField
left join tabsap.[DimSales Document Header] sh on r.[Sales Order] = sh.[Sales Document] and  sh.[Sales Document] NOT LIKE '%[^0-9]%'
left join custom.geographyhierarchy gh on r.[Country Key]=gh.countryCode
join dwglobal.GeographyRegion d on d.RegionGroup = gh.SecRegion and d.dataset='DWRev'
where r.[Currency Type] = 'B0' and r.[Business Segment]='CLEAR ALIGNER'
and rvt.ValueType2 in ('Gross Revenue','Discount','Sales Credits')
and r.[Sales Order] > 0;