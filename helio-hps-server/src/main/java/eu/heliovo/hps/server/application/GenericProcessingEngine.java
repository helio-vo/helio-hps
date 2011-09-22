package eu.heliovo.hps.server.application;

import java.util.HashMap;

import eu.heliovo.hps.server.utilities.DummyUtilities;
import eu.heliovo.hps.server.utilities.ExecutionUtilities;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class GenericProcessingEngine implements ProcessingEngine 
{
	/*
	 * This is the map with all the applications running here
	 */
	HashMap<String, ApplicationExecutionDescription>	runningApplications	=	new HashMap<String, ApplicationExecutionDescription>();

	ExecutionUtilities	exeUtilities		=	new ExecutionUtilities();
	LogUtilities		logUtilities		=	new LogUtilities();	
	DummyUtilities		tmpUtilities		=	new DummyUtilities();
	
	@Override
	public String executeApplication(ApplicationExecutionDescription exeDesc) throws ProcessingEngineException 
	{
		String appExeId	=	exeUtilities.getExecutionId();			
		/*
		 * Add the execution id to the running applications
		 */
		exeDesc.setAppExeId(appExeId);

		if(execute(exeDesc))
		{
			/*
			 * If the submission was successfull, add it to the running applications
			 */
			runningApplications.put(appExeId, exeDesc);
			logUtilities.printShortLogEntry(runningApplications.toString());
			return	appExeId;
		}
		else
			throw new ProcessingEngineException("Unable to submit application");
	}

	protected boolean execute(ApplicationExecutionDescription exeDesc) 
	{
		return false;
	}

	@Override
	public String getExecutionStatus(String exeId)
	{
		/*
		 * This is a hack for dummy status, change it with the real stata.
		 */
		ApplicationExecutionDescription	exeDesc	=	((ApplicationExecutionDescription)runningApplications.get(exeId));
		String	oldStatus	=	exeDesc.getStatus();
		String	newStatus	=	tmpUtilities.getNextStatus(oldStatus);
		exeDesc.setStatus(newStatus);
		runningApplications.put(exeId, exeDesc);
		return newStatus;
	}

	@Override
	public String toString() 
	{
		return "Generic Execution Engine";
	}		
}
