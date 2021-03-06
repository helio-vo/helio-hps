package eu.heliovo.hps.server.application;

import java.util.HashMap;

import eu.heliovo.hps.server.processing.fast.SimpleScriptController;
import eu.heliovo.shared.common.utilities.LogUtilities;
import eu.heliovo.shared.common.utilities.SystemUtilities;
import eu.heliovo.shared.hps.ApplicationExecutionStatus;

public class FastEngine extends GenericProcessingEngine 
{
	/*
	 * Various Utilities
	 */
	LogUtilities	logUtilities	=	new LogUtilities();
	SystemUtilities	sysUtilities	=	new SystemUtilities();
	/*
	 * Map of the threads that control the execution of the scripts
	 */
	HashMap<String, SimpleScriptController>	runningScripts	=	new HashMap<String, SimpleScriptController>();
	
	@Override
	protected boolean execute(ApplicationExecutionDescription exeDesc) 
	{
//		logUtilities.printLongLogEntry(" xxx " + exeDesc.appDesc.getParameters());

//		logUtilities.printShortLogEntry("Running Scripts : " + runningScripts);
//		logUtilities.printShortLogEntry("ApplicationExecutionDescription : " + exeDesc);
		SimpleScriptController	controller	=	new SimpleScriptController();
		controller.setAppExeDesc(exeDesc);
		controller.start();
		runningScripts.put(exeDesc.appExeId, controller);
//		logUtilities.printShortLogEntry("Running Scripts : " + runningScripts);
//		logUtilities.printShortLogEntry("There are now " + runningScripts.keySet().size() + " running scripts");
		return true;	
	}

	@Override
	public String getExecutionStatus(String exeId) 
	{
		/*
		 * Get the script controller of the exeId...
		 */
		ApplicationExecutionDescription	appExeDesc	=	super.runningApplications.get(exeId);
		String	newStatus							=	null;
		/*
		 * Getting the status of the running script controller...
		 */
//		System.out.println(exeId);
//		logUtilities.printShortLogEntry("Running Scripts : " + runningScripts);		
		logUtilities.printShortLogEntry(exeId + ": " + runningScripts.get(exeId).getState());
		
		if(runningScripts.get(exeId).getState().equals(Thread.State.TERMINATED))
			newStatus	=	ApplicationExecutionStatus.Completed;
		else
			newStatus	=	ApplicationExecutionStatus.Running;
			
		appExeDesc.setStatus(newStatus);
		super.runningApplications.put(exeId, appExeDesc);
		return newStatus;
	}

	@Override
	public String toString() 
	{
		return "Fast Execution Engine";
	}		
}
