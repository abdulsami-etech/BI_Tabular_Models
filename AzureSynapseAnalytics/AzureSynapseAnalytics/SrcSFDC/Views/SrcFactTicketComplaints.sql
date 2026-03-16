CREATE VIEW [SrcSFDC].[SrcFactTicketComplaints]
AS SELECT 
     a.ADLSBatchID                                                            as ADLSBatchID
    ,a.ADLSTimestamp                                                        as ADLSTimestamp
    ,a.LZBatchID                                                            as LZBatchID
    ,a.CaseNumber                                                           as DgnCaseNumber
    ,a.[Status]							                                    as DgnStatus
    ,a.CreatedDate                                                          as DgnCreatedDate
    ,a.Complaint_Type__c				                                    as DgnComplaintType
    ,a.Complaint_Sub_Type__c                                                as DgnComplaintSubType
    ,a.Manufacturing_Site__c                                                as DgnManufacturingSite 
    ,c.Region__c                                                            as DgnRegion

 

    ,C.Account_Number__c                                                    as KeyDoctor
      ,convert(date, a.CreatedDate)                                            as KeyCreatedDate
    ,convert(time(0), a.CreatedDate)                                        as KeyCreatedTime
    ,A.TX_Service_Center_Aligner__c                                         as KeyPlantOriginal
 	,CAST(Case when a.Manufacturing_Site__c  ='SG' then 2109
          when a.Manufacturing_Site__c  ='CR' then 2803
          when a.Manufacturing_Site__c  ='Cologne' then 2818
          when a.Manufacturing_Site__c  ='AMS' then 2812
          when a.Manufacturing_Site__c  ='Yokohama' then 2821
          when a.Manufacturing_Site__c  ='Spain' then 2819
          when a.Manufacturing_Site__c  ='Poland' then 2820
          when a.Manufacturing_Site__c  ='Chengdu' then 2815
          when a.Manufacturing_Site__c  ='MX1' then 2801 
          when a.Manufacturing_Site__c  ='MX2' then 2802 
          when a.Manufacturing_Site__c  ='AMS' then 2812
          when a.Manufacturing_Site__c = 'ZY'  then 3801 else a.TX_Service_Center_Aligner__c end as nvarchar(20)) as  KeyPlantActual

 

    ,CASE WHEN a.Complaint_Sub_Type__c in ('ClinCheck Doesn’t Follow Protocol','ClinCheck Doesn''t Follow Prescription','Design Execution','Record Analysis Issues',NULL)
     Then 1 else 0 End                                                      as IsDesignExecution
    ,CASE WHEN a.Complaint_Sub_Type__c in ('Disagreement with Align Policies','Product Envelope')
     Then 1 else 0 End                                                      as IsProductEnvelope
    ,CASE WHEN a.Complaint_Sub_Type__c in ('System or Software')
     Then 1 else 0 End                                                      as IsSystemORSoftware
    ,CASE WHEN a.Complaint_Sub_Type__c in ('Dr''s goal not achieved/not satisfied with CC','Deficient Instructions','Unspecified Expectation')
     Then 1 else 0 End                                                      as IsUnspecifiedExpectation
    ,CASE WHEN a.[Complaint_Type__c]   in ('Broken aligner/retainer','Aligner/retainer Forming Issues',
                                'Aligner/retainer Quantity and Packaging Issues','Aligner/retainer Trimming and Polishing Issues',
                                'Aligner/Retainer - Other Issues','Aligner/retainer Fit Issues',
                                'Aligner Color or Clarity Issue','Aligner Feature Complaint')
     Then 1 else 0 End                                                      as IsAlignerManufacturing
	, CASE WHEN ISNULL(a.[Product_Type__c],'')  in ('Vivera Retainers','Vivera/Retainer','Invisalign Retainer')
	 Then 1 else 0 End                                                      as  IsViveraRetainer 
    , CASE WHEN a.[Complaint_Type__c] in ('Non Valid') then 1 else 0 end		as	IsNonValid
 

          
 FROM  SrcSFDC.[Case] a 
 inner join SrcSFDC.Account c on c.Id = a.AccountId 
 inner join SrcSFDC.RecordType d on d.Id = A.RecordTypeId

 

WHERE 
  a.[CreatedDate] BETWEEN DATEADD(YEAR,-2,getutcdate())  AND getutcdate() 
  AND   
  a.[Complaint_Type__c] in ('Treatment Complaints','Treatment Plan Feedback','Non Valid'
   ,'Broken aligner/retainer','Aligner/retainer Forming Issues',
    'Aligner/retainer Quantity and Packaging Issues','Aligner/retainer Trimming and Polishing Issues',
    'Aligner/Retainer - Other Issues','Aligner/retainer Fit Issues',
    'Aligner Color or Clarity Issue','Aligner Feature Complaint') 
  AND 
  d.Name like '%Complaint%';