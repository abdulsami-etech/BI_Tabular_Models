CREATE VIEW [TABIRIS].[DimTask]
AS select 
				dt.[KeyTask],
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
from DWIRIS.DimTask dt
inner join DWIRIS.HubTask ht
	on ht.SKTask = dt.SKTask;