CREATE VIEW [TABSAP].[Business Segment]
AS SELECT  DISTINCT [Business Segment] FROM [TABSAP].[FactCOPARevenue]
WHERE [Business Segment] IS NOT NULL;