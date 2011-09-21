package eu.heliovo.hps.server.application;

import java.util.HashMap;

import eu.heliovo.hps.server.ApplicationExecutionStatus;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class SimpleApplicationEngine implements ApplicationEngine 
{
	LogUtilities	logUtilities	=	new LogUtilities();
	
	HashMap	runningApplications	=	new HashMap();
	
	@Override
	public String executeApplication(
			CompleteApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs) 
	{
		ApplicationExecutionDescription	appExeDesc	=	
			new ApplicationExecutionDescription(app,
					fastExecution,
					numParallelJobs);
		
		String	appExeId	=	 createApplicationExecutionId();
		
		runningApplications.put(appExeId, "test");
		logUtilities.printShortLogEntry(runningApplications.toString());
		return appExeId;
	}

	private String createApplicationExecutionId() 
	{
		return "executionId";	
	}

	@Override
	public String getStatusOfExecution(String exeId) 
	{
		return ApplicationExecutionStatus.Running;	
	}

	@Override
	public String getOutputOfExecution(String exeId) 
	{
		return "executionOutput";
	}
}
