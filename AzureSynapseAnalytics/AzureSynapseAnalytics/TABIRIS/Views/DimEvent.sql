CREATE VIEW [TABIRIS].[DimEvent]
AS select 
				dt.[KeyEvent],
				dt.[SKUser],
				dt.[SKAccount],
				dt.[CreatedDate],
				dt.[WhatId],
				dt.[PrimaryFocus],
				dt.[Subject],
				dt.[Status],			
				dt.[CallCounter],
				dt.[RecordTypeName] ,
				dt.[IsDeleted]
from DWIRIS.DimEvent dt
inner join DWIRIS.HubEvent ht
	on ht.SKEvent = dt.SKEvent;