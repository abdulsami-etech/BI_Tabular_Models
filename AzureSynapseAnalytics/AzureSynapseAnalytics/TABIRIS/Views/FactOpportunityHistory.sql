CREATE VIEW TABIRIS.FactOpportunityHistory as 
select 
		fo.[KeyOpportunity] ,
		fo.[CreatedDate],
		fo.[CreatedById],
		fo.[Field] ,
		fo.[IsDeleted] ,
		fo.[NewValue] ,
		fo.[OldValue] ,
		fo.[OpportunityId]
from DWIRIS.FactOpportunityHistory  fo
inner join DWIRIS.HubOpportunity ho
on ho.SKOpportunity = fo.SKOpportunity;