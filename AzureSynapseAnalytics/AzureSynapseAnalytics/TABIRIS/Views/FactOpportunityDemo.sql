CREATE VIEW [TABIRIS].[FactOpportunityDemo] AS 
Select
				do.KeyOpportunity, --OpportunityID
				da.KeyAccount, --AcoountID
				dt.KeyTask, --Task ID
				NULL as KeyEvent,
				du.[Key User] as KeyUser, --OwnerId
				dt.PrimaryFocus,
				dt.CallCounter as Activity, -- count() = ActivityCount
				Case When dt.PrimaryFocus LIKE '%Conducted a Demo%' Then 1 Else Null End as DemoConducted, -- count() = demos
				dt.CreatedDate as CreatedDate,
				dt.[Subject],
				dt.[Status],
				dt.RecordTypeName
			From TABIRIS.DimTask dt
			inner join TABIRIS.DimOpportunity as do 
				on dt.WhatId = do.KeyOpportunity
			left join DWC.DimAccount da
				on da.SKAccount = dt.SKAccount
			left join TABIRIS.DimUser du
				on du.[SK User] = dt.[SKUser]
			Where dt.PrimaryFocus LIKE '%Demo%' and isnull(dt.RecordTypeName,'') in ('Sales_Call_Activity','Scanner Activity')
			UNION 
			Select
				do.KeyOpportunity , --OpportunityID
				da.KeyAccount, --AcoountID
				null, --KeyTask
				dt.KeyEvent, --Event ID
				du.[Key User], --OwnerId
				dt.PrimaryFocus,
				dt.CallCounter as Activity, -- count() = ActivityCount
				Case When dt.PrimaryFocus LIKE '%Conducted a Demo%' Then 1 Else Null End as DemoConducted, -- count() = demos
				dt.CreatedDate as CreatedDate,
				dt.[Subject],
				dt.[Status],
				dt.RecordTypeName
			From TABIRIS.DimEvent dt
			inner join TABIRIS.DimOpportunity as do 
				on dt.WhatId = do.KeyOpportunity
			left join DWC.DimAccount da
				on da.SKAccount = dt.SKAccount
			left join TABIRIS.DimUser du
				on du.[SK User] = dt.[SKUser]
			Where dt.PrimaryFocus LIKE '%Demo%' and isnull(dt.RecordTypeName,'') in ('Sales_Call_Activity','Scanner Activity');
