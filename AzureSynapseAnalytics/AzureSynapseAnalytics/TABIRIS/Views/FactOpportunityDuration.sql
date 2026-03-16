CREATE VIEW [TABIRIS].[FactOpportunityDuration] 
AS 
select 
	OpportunityID as KeyOpportunity,
	NewValue as StageName,
	CreatedDate as StageCreatedDate,
	CASE
		WHEN LEAD(CreatedDate) OVER (PARTITION BY OpportunityID ORDER BY CreatedDate ASC) IS NULL
		THEN 'Active'
		ELSE 
		'Completed'
	END as StageStatus,
	CASE
		WHEN LEAD(CreatedDate) OVER (PARTITION BY OpportunityID ORDER BY CreatedDate ASC) IS NULL
		THEN datediff(ss,CreatedDate,getdate())
		ELSE 
		datediff(ss,CreatedDate, LEAD(CreatedDate) OVER (PARTITION BY OpportunityID ORDER BY CreatedDate ASC))
	END as StageDuration
from (

select 
	fact.OpportunityID,
	fact.CreatedDate,
	NULL as OldValue,
	old.OldValue as NewValue
from (
select 
	OpportunityID,
	CreatedDate,
	NULL as OldValue,
	ROW_NUMBER() OVER(PARTITION BY OpportunityID ORDER BY CreatedDate ASC) as rnum
from DWIRIS.FactOpportunityHistory  f
where Field = 'created'
) fact
left join (
		select OpportunityID, 
			   OldValue from 
				(select 
					OpportunityID,
					CreatedDate,
					OldValue,
					NewValue,
					ROW_NUMBER() OVER(PARTITION BY OpportunityID ORDER BY CreatedDate ASC) as rn
				from DWIRIS.FactOpportunityHistory
				where  Field = 'StageName'
			  ) e
		 where rn = 1
) old
	on old.OpportunityID = fact.OpportunityID
where fact.rnum = 1
UNION ALL
select 
	OpportunityID,
	CreatedDate,
	OldValue,
	NewValue
from DWIRIS.FactOpportunityHistory
where  Field = 'StageName'
) b;
