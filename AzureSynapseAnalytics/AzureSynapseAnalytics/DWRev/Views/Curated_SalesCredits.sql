CREATE VIEW [DWRev].[Curated_SalesCredits] AS with SalesCredits as (
select r.[Sales Order] CreditMemonumber
,try_convert(int, VBPA.AG) SoldTo, con.ClinId ClinId1, c2.ClinID ClinId2, c3.ClinID ClinId3
,r.[Posting Date] PostingDate
, r.[Period/Year] Period,r.[Reporting Channel] Channel,  r.[Country Key] CountryCode,r.[Company Code] CompanyCode, r.[Currency Key]  Currency
, Try_Convert(int,r.[Profit Center]) ProfitCenter, r.[Product Hierarchy] ProdH, r.[Cost Element] CostElement, r.[Sales Organisation] SalesOrg
, r.[Item Category] ItemCat,rvt.Valuetype, Try_Convert(int,r.[Material Number]) MaterialNumber, r.[Treatment Option] TreatmentOption
,r.[Deliverable Type] DeliverableType, r.[COPA Revenue], ce.[Level 6] CELvl6, ce.[Level 7] CELvl7
, gh.SecRegion
,oh.AUART DocType
--, oh.vkbur,oh.VGBEL,oh.xBLNR,oh.ZUONR,oh.KUNNR
,CASE when oh.VGBEL = '' then case when oh.xBLNR ='' then oh.ZUONR else oh.XBLNR end else oh.VGBEL end as ReferenceBillingDoc
,oh.ZZSFDC_ORD SFDCOrderName
from [TABSAP].[FactCOPARevenue_Performance] r left join  tabsap.dimcostelement ce on ce.[Cost Element] = r.[Cost Element]
join DWSAP.DimCOPARevenueValueType rvt on r.[Value Fields] = rvt.ValueField
join srcsap.vbak oh on r.[Sales Order] = oh.VBELN
join DWSAP.VBPA_Pivoted_v2 VBPA ON VBPA.VBELN = oh.VBELN
left join DW.DimAccount a on a.AccountNumber = convert(nvarchar(40), try_convert(int, VBPA.AG))
left join dw.DimAccount p on a.ParentAccountNumber    = p.AccountNumber
left join (
select	min(SKContact) as SKContact
,	ContactNumber
,   ClinID
from DW.DimContact
group by ContactNumber,   ClinID
) con on con.ContactNumber = VBPA.ZT
left join (select top (1) with ties SKContact,ContactType,PrimarysKAccount,ClinID from dw.DimContact
order by row_number() over (partition by PrimarySKAccount order by Case when Isnull(ContactType,'ZZZ' ) ='Doctor' then 1 else 2 end)
)c2 on c2.PrimarySKAccount = isnull(p.SKAccount,a.SKAccount)
left join SrcSFDC.Shared_Contact__C sc on  sc.account_number__C =convert(nvarchar(40), try_convert(int, VBPA.AG))
left join DW.DimContact c3 on c3.KeyContact = sc.Contact__C
left join custom.geographyhierarchy gh on r.[Country Key]=gh.countryCode
--left join srcsap.vbak soh on r.[Sales Order] =soh.VBELN
join dwglobal.GeographyRegion d on d.RegionGroup = gh.SecRegion and d.dataset='DWRev'
where r.[Currency Type] = 'B0' and r.[Business Segment]='CLEAR ALIGNER'
and rvt.ValueType2 in ('Sales Credits')
--and oh.AUART='Z08'
)
select top(1) with ties sc.CreditMemoNumber, sc.ReferenceBillingDoc,sc.SFDCOrderName,convert(bigint,vbrp.AuBEL) OriginalSO,sc.Soldto, Coalesce(sc.ClinId1,sc.ClinId2,sc.ClinId3,c.ClinId) ClinID
, sc.PostingDate, sc.Period, sc.Channel,sc.CountryCode, sc.CompanyCode, sc.ProfitCenter,sc.ProdH,sc.CostElement
, sc.ItemCat, sc.ValueType , sc.MaterialNumber, sc.CELvl6,sc.CELvl7, sc.[COPA Revenue], DocType
, sc.SecRegion
from SalesCredits sc left join SrcSAP.VBRP vbrp on sc.ReferenceBillingDoc = vbrp.VBELN and vbrp.PSTYV <> 'ZFUL'
left join DW.DimOrderSFDC osf on convert(bigint,vbrp.AuBEL)  = osf.KeyOrder
left join DW.DimContact c on osf.SKContact = c.SKContact
order by row_number() over (
partition by sc.CreditMemoNumber,sc.ReferenceBillingDoc
order by  vbrp.AuBEL desc
);