CREATE VIEW [SrcSAP].[VBPA]
AS select
       [LZBatchID]
      ,[ADLSBatchID]
      ,[ADLSTimestamp]
      ,[MANDT]
      ,[VBELN]
      ,[PARVW]
      ,[KUNNR]
      ,[LIFNR]
      ,[ERDAT]
      ,[AEDAT]
from [SrcSAP].ZVOTC_VBPA1;