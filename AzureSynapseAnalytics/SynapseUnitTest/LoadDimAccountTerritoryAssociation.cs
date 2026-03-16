using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Text;
using Microsoft.Data.Tools.Schema.Sql.UnitTesting;
using Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SynapseUnitTest
{
    [TestClass()]
    public class LoadDimAccountTerritoryAssociation : SqlDatabaseTestClass
    {

        public LoadDimAccountTerritoryAssociation()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction DW_LoadDimAccountTerritoryAssociationTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition ScalarRowCountCheck;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction DW_LoadDimAccountTerritoryAssociationTest_PretestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(LoadDimAccountTerritoryAssociation));
            this.DW_LoadDimAccountTerritoryAssociationTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            DW_LoadDimAccountTerritoryAssociationTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            ScalarRowCountCheck = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            DW_LoadDimAccountTerritoryAssociationTest_PretestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            // 
            // DW_LoadDimAccountTerritoryAssociationTestData
            // 
            this.DW_LoadDimAccountTerritoryAssociationTestData.PosttestAction = null;
            this.DW_LoadDimAccountTerritoryAssociationTestData.PretestAction = DW_LoadDimAccountTerritoryAssociationTest_PretestAction;
            this.DW_LoadDimAccountTerritoryAssociationTestData.TestAction = DW_LoadDimAccountTerritoryAssociationTest_TestAction;
            // 
            // DW_LoadDimAccountTerritoryAssociationTest_TestAction
            // 
            DW_LoadDimAccountTerritoryAssociationTest_TestAction.Conditions.Add(ScalarRowCountCheck);
            resources.ApplyResources(DW_LoadDimAccountTerritoryAssociationTest_TestAction, "DW_LoadDimAccountTerritoryAssociationTest_TestAction");
            // 
            // ScalarRowCountCheck
            // 
            ScalarRowCountCheck.ColumnNumber = 1;
            ScalarRowCountCheck.Enabled = true;
            ScalarRowCountCheck.ExpectedValue = "Test passed";
            ScalarRowCountCheck.Name = "ScalarRowCountCheck";
            ScalarRowCountCheck.NullExpected = false;
            ScalarRowCountCheck.ResultSet = 2;
            ScalarRowCountCheck.RowNumber = 1;
            // 
            // DW_LoadDimAccountTerritoryAssociationTest_PretestAction
            // 
            resources.ApplyResources(DW_LoadDimAccountTerritoryAssociationTest_PretestAction, "DW_LoadDimAccountTerritoryAssociationTest_PretestAction");
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
        public void DW_LoadDimAccountTerritoryAssociationTest()
        {
            SqlDatabaseTestActions testActions = this.DW_LoadDimAccountTerritoryAssociationTestData;
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
        private SqlDatabaseTestActions DW_LoadDimAccountTerritoryAssociationTestData;
    }
}
