CREATE VIEW DWC.polaris_data_cleansing AS
SELECT p.clinid, a.shippingcountrycode, rc.country_name,
       p.form_submitted, p.display_counter, c.firstname, c.lastname,
       c.email, 
	   c.doctor_license_number__c,
	   c.mobilephone, a.phone, 
	   a.invoice_preference__c, 
	   p.modified_at
FROM SrcIDS.polaris_data_cleansing p
         join [SrcIDS].[tblCnAccounts] ac ON ac.user_name = p.clinid
         JOIN SrcSFDC.contact c ON ac.contact_sfid = c.id
         JOIN SrcSFDC.account a ON a.id = c.accountid
         JOIN [SrcIDS].[tblPuRegionCountryMap] rc ON rc.country_code = a.shippingcountrycode
WHERE p.display_counter > 0