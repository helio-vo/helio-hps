package eu.heliovo.hps.server.application;

public interface ApplicationEngine 
{
	String executeApplication(
			CompleteApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs) throws ProcessingEngineException;
	
	String getStatusOfExecution(String exeId);
	String getOutputOfExecution(String exeId);
}
