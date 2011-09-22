package eu.heliovo.hps.server.application;

public interface ProcessingEngine 
{
	String executeApplication(ApplicationExecutionDescription exeDesc) throws ProcessingEngineException;
	String getExecutionStatus(String exeId);
}
