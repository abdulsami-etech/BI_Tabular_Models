CREATE PROC [DW].[LoadFactVolumePrimary] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
BEGIN
	set nocount on
	set xact_abort on

	DECLARE @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		
	exec DW.LoadFactVolume @BatchID = @BatchID,@LastSuccessfullDWTimestamp = @LastSuccessfullDWTimestamp,@IsForceFullLoad = @IsForceFullLoad,@TreatmentCategory = 'Primary',@RowsInserted = @RowsInserted out,@RowsUpdated = @RowsUpdated out
	
	SELECT @RowsInserted AS RowsInserted, @RowsUpdated AS RowsUpdated
	

END