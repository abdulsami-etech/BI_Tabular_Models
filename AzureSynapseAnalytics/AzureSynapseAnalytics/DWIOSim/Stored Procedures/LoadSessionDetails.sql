CREATE PROC [DWIOSIM].[LoadSessionDetails] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN

	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	declare @max_action_id bigint;
	Select @max_action_id=COALESCE(MAX(max_actionid),30413771485) from DWIOSim.[Session]

	if object_id('tempdb..#Action') is not null
	drop table #Action
			
	CREATE TABLE #Action with (distribution = round_robin, heap) as 
	Select 
		session_id,
		action_datetime,
		action_id,
		type,
		name,
		state
	from SrcInst.Action
	where action_id>@max_action_id

	if object_id('tempdb..#SessionAction') is not null
	drop table #SessionAction

	CREATE TABLE #SessionAction with (distribution = round_robin, heap) as 
	Select
		s.auto_session_id,
		max(action_id) as max_actionid,
		sum(case when Act.Name like 'MainWindow.centralwidget.generalContent.sceneCont.Document.sceneCont.ccViewer%.graphicsView.PAButtons.stackedWidget.progressAssessmentFaccPage.progressAssessmentButton' then 1 end)
			as ProgressAssessmentActions,
		sum(case when Act.Name like '%createSimulation%' then 1 else 0 end) as CreateSimulationActions,
		sum(case when Act.Type in ( 'MoveToothByArrows', 'MoveToothByWidget' )  then 1 else 0 end ) as WidgetActions,
		sum(case when Act.Name like 'MainWindow.centralwidget.%scrollAreaWidgetContents.updateSimulation' then 1 else 0 end) as TreatmentGoals,
		sum(case when Act.Name = 'MainWindow.centralwidget.sceneCont.viewer01.graphicsView.ClinicalAdjustment.frame.stackedWidget.checksPage.scrollArea.qt_scrollarea_viewport.scrollAreaWidgetContents.modifiers.enableIPR' 
							and Act.State = 'pressed'
							and Act.Type = 'QCheckBox'	 
							then 1
						when Act.Name = 'MainWindow.centralwidget.sceneCont.Document.splitter.sceneCont.ccViewer01.graphicsView.ClinicalAdjustmentDialog.scrollArea.qt_scrollarea_viewport.scrollAreaWidgetContents.modifiers.enableIPR' then 1
						else 0 end			
					) as AllowIPRActions,
		sum(case when Act.Name =  'MainWindow.centralwidget.sceneCont.viewer01.graphicsView.ClinicalAdjustment.frame.stackedWidget.checksPage.scrollArea.qt_scrollarea_viewport.scrollAreaWidgetContents.modifiers.extractionsCheck' 			
							and Act.State = 'pressed'
							and Act.Type = 'QRadioButton'	  then 1
						when Act.Name like 'MainWindow.centralwidget.sceneCont.Document.splitter.sceneCont.ccViewer01.graphicsView.ClinicalAdjustmentDialog.scrollArea.qt_scrollarea_viewport.scrollAreaWidgetContents.extractionsPanel.extractions.widget%.ContextMenu.(Extracted)' then 1
						else 0 end			
					) as ExtractionActions,
		sum( case when Act.Name  = 'MainWindow.centralwidget.sceneCont.viewer01.graphicsView.ClinicalAdjustment.frame.stackedWidget.checksPage.scrollArea.qt_scrollarea_viewport.scrollAreaWidgetContents.modifiers.Ap' 								
							and Act.State = 'pressed'
							and Act.Type = 'QRadioButton' 
							then 1
						when Act.Name = 'MainWindow.centralwidget.sceneCont.Document.splitter.sceneCont.ccViewer01.graphicsView.ClinicalAdjustmentDialog.scrollArea.qt_scrollarea_viewport.scrollAreaWidgetContents.modifiers.Ap' then 1
						else 0	end			
					) as APCorrectionActions,
		sum(case when Act.Name like 'MainWindow.centralwidget.sceneCont.Document.splitter.sceneCont.ccViewer01.graphicsView.ClinicalAdjustmentDialog.scrollArea.qt_scrollarea_viewport.scrollAreaWidgetContents.extractionsPanel.extractions.widget%.ContextMenu.(Unmovable)' then 1				
						else 0	end			
					) as Unmovable,	
		sum(case when Act.Name like 'MainWindow.centralwidget.sceneCont.Document.splitter.sceneCont.ccViewer01.graphicsView.PAButtons.stackedWidget.currentDentionPage.stageButton' then 1				
				else 0	end			
			) as Compare_with_Original,
		sum(case when Act.Name like N'MainWindow.centralwidget.generalContent.sceneCont.Document.sceneCont.ccViewer%.graphicsView.SendSimulationDialog.processButton' then 1				
						else 0	end			
					) as Direct_Submission,
		sum(case when Act.Type = 'ShareSimulationDialog_Success'	then 1 else 0 end) as ShareSimulation
	from #Action act 
	join DWIOSIM.Session s on s.session_id=act.session_id
	group by s.auto_session_id

	UPDATE DWIOSIM.Session
	set 
		max_actionid = sa.max_actionid,
		CreateSimulationActions= COALESCE(Session.CreateSimulationActions,0) + COALESCE(sa.CreateSimulationActions,0),
        ProgressAssessment = COALESCE(Session.ProgressAssessment,0) + COALESCE(sa.ProgressAssessmentActions,0),
		WidgetActions = COALESCE(Session.WidgetActions,0) + COALESCE(sa.WidgetActions,0),
		TreatmentGoals = COALESCE(Session.TreatmentGoals,0) + COALESCE(sa.TreatmentGoals,0),
		AllowIPRActions = COALESCE(Session.AllowIPRActions,0) + COALESCE(sa.AllowIPRActions,0),
		ExtractionActions = COALESCE(Session.ExtractionActions,0) + COALESCE(sa.ExtractionActions,0),
		APCorrectionActions = COALESCE(Session.APCorrectionActions,0) + COALESCE(sa.APCorrectionActions,0),
		Unmovable = COALESCE(Session.Unmovable,0) + COALESCE(sa.Unmovable,0),
		Compare_with_Original = COALESCE(Session.Compare_with_Original,0) + COALESCE(sa.Compare_with_Original,0),
		Direct_Submission = COALESCE(Session.Direct_Submission,0) + COALESCE(sa.Direct_Submission,0),
		ShareSimulation=COALESCE(Session.ShareSimulation,0) + COALESCE(sa.ShareSimulation,0)
	from #SessionAction sa
	where session.auto_session_id = sa.auto_session_id 
	and coalesce(session.max_actionid,0)<sa.max_actionid
    option (label = 'DWIOSIM.LoadSessionDetails');

	exec CTRL.GetLastRowCount @Label = 'DWIOSIM.LoadSessionDetails', @rc = @RowsUpdated out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END

