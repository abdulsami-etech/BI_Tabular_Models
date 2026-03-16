CREATE VIEW [DWC].[FactTrainingEvents] AS
SELECT 		te.Id 				
		,	te.EventID  				
		,	te.EventName  			
		,	te.EventCity  			
		,	te.EventState  			
		,	te.EventCountry  			
		,	te.SKTrainingEventType  
		,	te.SKAccount
		,	te.SKContact
		,	te.EventDate  			
		,	te.EventLocationID  		
		,	te.SpeakerName  			
		,	te.CEHours  				
		,	te.EventLocationName  	
		,	te.TuitionFee  			
		,	te.IsPointsAccrued  		
		,	te.IsPromotionEligible  	
		,	te.IsAttended  			
		,	te.LastModifiedDate  		
		,	te.StudyClubCode
		,	a.SecRegion
  FROM [DW].[FactTrainingEvents] te
  INNER JOIN [DW].[DimAccount] a ON te.SKAccount = a.SKAccount
  INNER JOIN dwglobal.GeographyRegion d on d.RegionGroup = a.SecRegion and d.dataset='DWC';


