CREATE VIEW DW.FactForecast AS
SELECT  TOP (1) WITH ties  
	  LoadDate
	 ,a.Scenario
	 ,a.CountryGroup
	 , CASE a.Measure WHEN 'ClinCheck Accepted' THEN 'CCA' ELSE a.Measure END AS Measure
	 ,a.PeriodDate
	 ,NULLIF(a.Channel,'_EMPTY_') Channel
	 ,NULLIF(a.TreatmentType,'_EMPTY_') TreatmentType
	 ,NULLIF(a.ProfitCenter,'_EMPTY_') ProfitCenter
	 ,a.Value 
	,sr.SecRegion
	FROM SrcFCST.AllForecast a
	INNER JOIN (SELECT DISTINCT CountryGroup, SecRegion FROM Custom.GeographyHierarchy) sr ON a.CountryGroup = sr.CountryGroup
	ORDER BY ROW_NUMBER() OVER (PARTITION BY a.Scenario,a.CountryGroup,a.Measure,a.PeriodDate,a.Channel,a.ProfitCenter,a.TreatmentType ORDER BY a.loaddate DESC)