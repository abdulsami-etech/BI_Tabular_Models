CREATE TABLE [DW].[DimScenario] (
	[SKScenario]    	 INT NOT NULL,
    [Scenario]    		 NVARCHAR (100) NOT NULL,
    [CreatedDate]        DATETIME       NULL,
    [ModifiedDate]       DATETIME       NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

