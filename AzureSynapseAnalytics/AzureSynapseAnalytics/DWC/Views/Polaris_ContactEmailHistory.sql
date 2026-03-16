CREATE VIEW DWC.Polaris_ContactEmailHistory AS
WITH ContactEmailHistory AS (
SELECT ch.ContactId, ch.NewValue,ch.OldValue, ch.CreatedByName, ch.CreatedDate 
FROM (
SELECT h.ContactId, h.NewValue,	h.OldValue, u.Name AS CreatedByName, h.CreatedDate
	, RANK() OVER( PARTITION BY h.ContactId ORDER BY h.CreatedDate DESC) AS Rnk
FROM [SrcSFDC].[ContactHistory] h
INNER JOIN [SrcSFDC].[User] u ON h.CreatedById = u.Id
WHERE h.Field = 'Email') ch WHERE ch.Rnk = 1
)
SELECT c.Clinician_ID__c, c.MailingCountry, c.MailingCountryCode, c.FirstName, c.LastName,	c.Doctor_License_Number__c
, c.Phone AS Contact_Phone, a.Phone AS Account_Phone,a.Invoice_Preference__c, ch.NewValue, ch.OldValue, ch.CreatedByName, ch.CreatedDate
FROM [SrcSFDC].[Contact] c
LEFT JOIN [SrcSFDC].[Account] a ON c.AccountId = a.Id
LEFT JOIN ContactEmailHistory ch ON c.Id = ch.ContactId;