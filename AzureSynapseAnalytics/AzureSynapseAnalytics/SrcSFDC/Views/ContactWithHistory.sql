CREATE VIEW [SrcSFDC].[ContactWithHistory]
AS select  c.Id
    ,   isnull(h.StartDate, '1900-01-01') as StartDate
    ,   isnull(h.EndDate, '2099-01-01') as EndDate
    ,   c.Contact_ID__c
    ,   c.Account_Number__c
    ,   c.AccountId
    ,   c.Active__c
    ,   c.Contact_Type__c
    ,   c.Clinician_ID__c
    ,   case when h.ContactId is null or h.Professional_Category__c = 'NO_HISTORY'
            then c.Professional_Category__c
            else h.Professional_Category__c
        end as Professional_Category__c
    ,   case when h.ContactId is null or h.MailingCountryCode = 'NO_HISTORY'
            then c.MailingCountryCode
            else h.MailingCountryCode
        end as MailingCountryCode
    ,   c.SystemModStamp
    ,   c.LastModifiedDate
    ,   c.Lending_point_enrollment_date__C
    ,   c.Name
from SrcSFDC.Contact c
left join SrcSFDC.ContactHistoryWithPeriods h on h.ContactId = c.Id;