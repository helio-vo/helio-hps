package eu.heliovo.hps.server.application;

import eu.heliovo.hps.server.ApplicationExecutionStatus;

public class DummyApplicationEngine implements ApplicationEngine 
{
	@Override
	public String executeApplication(
			CompleteApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs) 
	{
		return createApplicationExecutionId();
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
