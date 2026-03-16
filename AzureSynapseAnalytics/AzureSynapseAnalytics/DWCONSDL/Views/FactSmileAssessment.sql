CREATE VIEW [DWCONSDL].[FactSmileAssessment]
AS SELECT a.DateKey, 
       a.CountryCode, 
       c.AudienceSegment AS Age_Segment, 
       a.SALeadSource, 
       SUM(CASE
               WHEN IsOptIn = 'Yes'
               THEN 1
               ELSE 0
           END) AS Value
FROM DWCONSDL.FactAlignSAWebsite2 a
     INNER JOIN DWCONSDL.DimAudienceSegment c  ON a.AudienceSegmentKey = c.AudienceSegmentKey
WHERE a.DateKey BETWEEN '01-01-2017' AND(GETDATE() - 1)
GROUP BY a.DateKey, 
         a.CountryCode, 
         c.AudienceSegment, 
         a.SALeadSource;