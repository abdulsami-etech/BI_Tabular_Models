CREATE VIEW [TABSAP].[DimIncetiveCodeDesc]
AS select     top (1) with ties
        concat('00',oh.SAP_Order_ID__c)                                as SAPOrderNumber
    ,    convert(decimal(20, 5), opromo.Discount_Percent__c)                as DiscPercent
    ,   opromo.Apttus_Config2__IncentiveCode__c
    ,    Concat(ic.Name ,' ',opromo.Discount_Percent__c ,'%') as IncentiveName
from SrcSFDC.[Apttus_Config2__Order__c] oh with (nolock)
inner join SrcSFDC.Apttus_Config2__OrderLineItem__c olAl with (nolock) on oh.id = olAl.Apttus_Config2__OrderId__c
inner join SrcSFDC.Apttus_Config2__OrderAdjustmentLineItem__c opromo with (nolock) on olal.id = opromo.Apttus_Config2__LineItemId__c
inner join SrcSFDC.Apttus_Config2__Incentive__c ic with (nolock) on opromo.Apttus_Config2__IncentiveId__c = ic.Id
where oh.SAP_Order_ID__c not like '%[^0-9]%' --getting only ones which can be converted to bigint
order by row_number() over (
                    partition by    oh.SAP_Order_ID__c, opromo.Apttus_Config2__IncentiveCode__c
                    order by opromo.Discount_Percent__c desc);