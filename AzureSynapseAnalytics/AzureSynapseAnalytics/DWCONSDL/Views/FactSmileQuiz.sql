CREATE VIEW [DWCONSDL].[FactSmileQuiz]
AS SELECT  CONVERT(DATE,a.Created_at) as DateKey, 
       SUM(CASE
               WHEN Opt_In IS NULL
               THEN 0
               ELSE Opt_In
           END) AS "Value"
FROM SrcNASA.smile_quizzes a
WHERE a.created_at IS NOT NULL
      AND (a.source NOT IN('Parent Share Smile Quiz')
OR a.source IS NULL)
     AND a.Created_at BETWEEN '01-01-2017' AND(GETDATE() - 1)
GROUP BY CONVERT(DATE, a.Created_at);