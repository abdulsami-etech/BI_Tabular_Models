CREATE VIEW [SrcSFDC].[ContactHistoryWithPeriods]
AS with history as (
	select	ContactId
		,	Field
		,	CreatedDate
		,	NewValue
		,	OldValue
	from SrcSFDC.ContactHistory
	where Field in ('Professional_Category__c', 'MailingCountryCode')
), historyWithInitialValue as (
	select top (1) with ties
			ContactId
		,	Field
		,	'1900-01-01' as CreatedDate
		,	OldValue as NewValue
	from history
	order by row_number() over (partition by ContactId, Field order by CreatedDate)	

	union all

	select	ContactId
		,	Field
		,	CreatedDate
		,	NewValue
	from history
), historyByDates as (
	select top (1) with ties
			ContactId
		,	Field
		,	convert(date, CreatedDate) as CreatedDate
		,	NewValue
	from historyWithInitialValue
	order by row_number() over (partition by ContactId, Field, convert(date, CreatedDate) order by CreatedDate desc) 
), withPreviousValue as (
	select	ContactId
		,	Field
		,	CreatedDate
		,	NewValue
		,	isnull(lag(NewValue, 1, 'DEFAULT_VALUE') over (partition by ContactId, Field order by CreatedDate), 'NULL_VALUE') as PreviousValue
	from historyByDates
), withoutRedundancy as (
	select	ContactId
		,	Field
		,	CreatedDate
		,	NewValue
	from withPreviousValue
	where isnull(NewValue, 'NULL_VALUE') != PreviousValue --we are not intrested when the previous value is the same
		or PreviousValue = 'DEFAULT_VALUE' --initial
), withEndDate as (
	select	ContactId
		,	Field
		,	CreatedDate as StartDate
		,	lead(CreatedDate, 1, '2099-01-01') over (partition by ContactId, Field order by CreatedDate) as EndDate
		,	NewValue as Value
	from withoutRedundancy
), withMergedRanges_PC_Country as (
	select	isnull(a.ContactId, b.ContactId) as ContactId
		,	case when a.StartDate > b.StartDate then isnull(a.StartDate, b.StartDate) else isnull(b.StartDate, a.StartDate) end as StartDate
		,	case when a.EndDate < b.EndDate then isnull(a.EndDate, b.EndDate) else isnull(b.EndDate, a.EndDate) end as EndDate
		,	case when a.ContactId is not null then a.Value else 'NO_HISTORY' end as Professional_Category__c
		,	case when b.ContactId is not null then b.Value else 'NO_HISTORY' end as MailingCountryCode
	from (select * from withEndDate where Field = 'Professional_Category__c') a
	full join (select * from withEndDate where Field = 'MailingCountryCode') b on b.ContactId = a.ContactId
				and (
						(
							b.StartDate >= a.StartDate
							and b.StartDate < a.EndDate
						) or (
							b.EndDate > a.StartDate
							and b.EndDate <= a.EndDate
						) or (
							b.StartDate < a.StartDate
							and b.EndDate >= a.EndDate
						) 
				)
)
select  ContactId
    ,   StartDate
    ,   EndDate
    ,   Professional_Category__c
    ,   MailingCountryCode
from withMergedRanges_PC_Country;