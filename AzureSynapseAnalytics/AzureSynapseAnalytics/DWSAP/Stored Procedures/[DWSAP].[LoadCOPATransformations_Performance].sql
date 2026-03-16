--BI-12996 New procedure
CREATE PROC [DWSAP].[LoadCOPATransformations_Performance] @BatchID [int], 
@LastSuccessfullDWTimestamp [datetime2](0) AS BEGIN DECLARE @lastdatetime AS datetime2, 
@RowsInserted int = 0, 
@RowsUpdated int = 0, 
@IsFullLoad bit = 0 
----Procedure for KONV Upsert 
EXEC [DWSAP].[KONVUPSERT_Performance] @DeltaFlag = 1 
-- This proc is responsible for the delta and various transformations that include transpose,Free Paid, 
-- Business Segment, some product hierarchy changes, Currency related transformations as well  
EXEC [DWSAP].[LoadDeltaCopaTransformations_Performance] @BatchID, @LastSuccessfullDWTimestamp 
-- This proc is responsible for loading the Cost Element in the Transpose Table
EXEC [DWSAP].[LoadCopaCostElement_Performance]
-- This proc is responsible for Product Hierarchy Related Changes that are based on Periods and Cost Element
EXEC [DWSAP].[LoadCopaProdh_Performance] 
select 
  @RowsInserted - @RowsUpdated as RowsInserted, 
  @RowsUpdated as RowsUpdated;
END
