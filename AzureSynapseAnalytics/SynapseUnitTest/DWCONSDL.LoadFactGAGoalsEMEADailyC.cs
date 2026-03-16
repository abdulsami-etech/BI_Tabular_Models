using Microsoft.Data.Tools.Schema.Sql.UnitTesting;
using Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Text;

namespace SynapseUnitTest
{
    [TestClass()]
    public class DWCONSDL_LoadFactGAGoalsEMEADailyC : SqlDatabaseTestClass
    {

        public DWCONSDL_LoadFactGAGoalsEMEADailyC()
        {
            InitializeComponent();
        }

        [TestInitialize()]
        public void TestInitialize()
        {
            base.InitializeTest();
        }
        [TestCleanup()]
        public void TestCleanup()
        {
            base.CleanupTest();
        }

        #region Designer support code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction DWCONSDL_LoadFactGAGoalsEMEADailyCTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DWCONSDL_LoadFactGAGoalsEMEADailyC));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition rowCountCondition1;
            this.DWCONSDL_LoadFactGAGoalsEMEADailyCTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            DWCONSDL_LoadFactGAGoalsEMEADailyCTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            rowCountCondition1 = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // DWCONSDL_LoadFactGAGoalsEMEADailyCTest_TestAction
            // 
            DWCONSDL_LoadFactGAGoalsEMEADailyCTest_TestAction.Conditions.Add(rowCountCondition1);
            resources.ApplyResources(DWCONSDL_LoadFactGAGoalsEMEADailyCTest_TestAction, "DWCONSDL_LoadFactGAGoalsEMEADailyCTest_TestAction");
            // 
            // DWCONSDL_LoadFactGAGoalsEMEADailyCTestData
            // 
            this.DWCONSDL_LoadFactGAGoalsEMEADailyCTestData.PosttestAction = null;
            this.DWCONSDL_LoadFactGAGoalsEMEADailyCTestData.PretestAction = null;
            this.DWCONSDL_LoadFactGAGoalsEMEADailyCTestData.TestAction = DWCONSDL_LoadFactGAGoalsEMEADailyCTest_TestAction;
            // 
            // rowCountCondition1
            // 
            rowCountCondition1.Enabled = true;
            rowCountCondition1.Name = "rowCountCondition1";
            rowCountCondition1.ResultSet = 1;
            rowCountCondition1.RowCount = 1;
        }

        #endregion


        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        #endregion

        [TestMethod()]
        public void DWCONSDL_LoadFactGAGoalsEMEADailyCTest()
        {
            SqlDatabaseTestActions testActions = this.DWCONSDL_LoadFactGAGoalsEMEADailyCTestData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }
        private SqlDatabaseTestActions DWCONSDL_LoadFactGAGoalsEMEADailyCTestData;
    }
}
