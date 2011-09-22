package eu.heliovo.hps.server.application;

public interface ProcessingBroker 
{
	ProcessingEngine match(ApplicationExecutionDescription exeDesc);
}
