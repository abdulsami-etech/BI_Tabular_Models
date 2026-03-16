CREATE VIEW [TABSAP].[DimOrderAttributes] AS select oh.ID 
               ,oh.SAP_Order_ID__C as OrderNumber, oh.Treatment_Category__c as TreatmentCategory 
	 		  ,CASE WHEN oh.Patient_Age_Year__c > 80 THEN -1
		        WHEN oh.Patient_Age_Year__c IS NULL  THEN -1 
		        WHEN oh.Patient_Age_Year__c < -1 THEN -1 
		        ELSE oh.Patient_Age_Year__c END AS AgeTierCode 
	 , oh.Max_Stages__c OrderStages
, case when oh.Max_Stages__c between 1 and 14 then '01-14' when  oh.Max_Stages__c between 15 and 26 then '15-26' when oh.Max_Stages__c between 27 and 50 then '27-50' 
	when  oh.Max_Stages__c between 51 and 100000 then '51+'  else '0' end as Stagesbucket 
, case when oh.Patient_Age_Year__c > 19 then 'Adult' when  oh.Patient_Age_Year__c >= 0 then 'Non-Adult' else 'Adult' end as PatientType
, oh.Product_type__C   ProductType, oh.Treatment_Location_Number__c TreatmentLocation, oh.ClinId__C as ClinID, oh.Contact_Id__C as TreatingDoctor
, oh.Ship_to_Account_Number__c as ShipTo, Sold_To_Account_Number__C as SoldTo, oh.Payer__C as Payer, oh.Bill_to_Account_Number__C as BillTo 
, case when  ga.Type is null then a.Account_Sub_Type__c else ga.Account_Sub_Type__c  end as CustomerGroupType 
, case when  ga.Type is null then 'No' when ga.Type like 'Group%' then 'Yes' else 'No' end as IsDSOOrder
,ga.Type
, convert(date,oh.Receipt_Date1__C) as AMRDate, convert(date, oh.CCA_Date1__C) as CCADate, convert(date, oh.Shipped_Date1__C) as ShipDate
, Case  When Isnull(oh. Scan_Type__C, 'NOSCAN') IN ('NOSCAN', 'PVS_IMPRESSIONS') then 'No' else 'Yes' End as ISIOScan
, convert(int,oh.Upper_Quantity__C) as UpperAlignerQty
, convert(int,oh.Lower_Quantity__C) as LowerAlignerQty
, case when oh.Upper_Quantity__C is not null then 1 end as UpperAlignerStartstage
, case when oh.Upper_Quantity__C is not null then convert(int,oh.Upper_Quantity__C) end as UpperAlignerEndStage
, case when oh.Lower_Quantity__C is not null then 1 end as LowerAlignerStartstage
, case when oh.Lower_Quantity__C is not null then convert(int,oh.Lower_Quantity__C) end as LowerAlignerEndStage
, cscd.ProfessionalCategory 
, Isnull(cscd.AdvCurrentAdvantageLevel,'Not in Program') as AdvantageTier
, Isnull(cscd.AdvCurrentAdvantageProgram,'Not in Program')  as AdvantageProgramName
, Case oh.MAF__c when 0 then 'No' when 1 then 'Yes' else 'Unknown' end AS MAF
,c.ContactName
from [SrcSFDC].[Apttus_Config2__Order__c] oh with (nolock) left join SrcSFDC.Account ga with (nolock) on oh.Sold_To_Account_Number__c  = ga.Account_number__C
inner join SrcSFDC.Account a with (nolock) on a.id = oh.Treatment_Location__C 
left join DW.DimContact c with (nolock) on oh.Apttus_Config2__PrimaryContactId__c = c.KeyContact 
left join DW.DimContactSCD cscd with (nolock) on cscd.SKContact = c.SKContact and  convert(date, IsNull(oh.Shipped_Date1__c,oh.CreatedDate)) >= cscd.StartDateSCD and convert(date, IsNull(oh.Shipped_Date1__c,oh.CreatedDate))  < cscd.EndDateSCD
--left join SrcSFDC.Account blt on blt.id = oh.Apttus_Config2__BillToAccountId__c
--left join SrcSFDC.Account sld on sld.id = oh.Apttus_Config2__SoldToAccountId__c
where  oh.SAP_Order_ID__C is not null AND ISNUMERIC(oh.SAP_Order_ID__C) = 1;