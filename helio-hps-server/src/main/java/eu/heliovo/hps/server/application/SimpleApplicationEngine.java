package eu.heliovo.hps.server.application;

import java.util.HashMap;

import eu.heliovo.hps.server.utilities.DummyUtilities;
import eu.heliovo.hps.server.utilities.ExecutionUtilities;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class SimpleApplicationEngine implements ApplicationEngine 
{
	/*
	 * The broker that finds the right job execution engine
	 */
	ProcessingBroker	prBroker			=	new DummyProcessingBroker();	
	/*
	 * Various Utilitites
	 */
	LogUtilities		logUtilities		=	new LogUtilities();	
	ExecutionUtilities	exeUtilities		=	new ExecutionUtilities();
	DummyUtilities		tmpUtilities		=	new DummyUtilities();
	/*
	 * The map with the running applications
	 */
	HashMap<String, ProcessingEngine>					processingResources	=	new HashMap<String, ProcessingEngine>();
	
	@Override
	public String executeApplication(
			CompleteApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs) throws ProcessingEngineException 
	{	
		/*
		 * Create the execution description for the applications
		 */
		ApplicationExecutionDescription	exeDesc	=	new ApplicationExecutionDescription(
				app,
				fastExecution,
				numParallelJobs);
		System.out.println("SimpleApplicationEngine.executeApplication - exedesc is " + exeDesc.appDesc.toString());
		System.out.println("SimpleApplicationEngine.executeApplication - params are " + exeDesc.appDesc.parameters);
		logUtilities.printLongLogEntry(" xxx " + app.getParameters());

		/*
		 * Find the best job execution engine to run this application
		 */
		ProcessingEngine	jobExecutor		=	prBroker.match(exeDesc);
		/*
		 * Submit the application to the engine and return the id
		 */
		String	appExeId	=	 jobExecutor.executeApplication(exeDesc);
		exeDesc.setAppExeId(appExeId);
		/*
		 * Add the processing engine to the processing engines map
		 */
		processingResources.put(appExeId, jobExecutor);
		logUtilities.printShortLogEntry(processingResources.toString());
		return appExeId;
	}

	@Override
	public String getStatusOfExecution(String exeId) 
	{
		return ((ProcessingEngine)processingResources.get(exeId)).getExecutionStatus(exeId);
	}

	@Override
	public String getOutputOfExecution(String exeId) 
	{
		return "executionOutput";
	}
}
