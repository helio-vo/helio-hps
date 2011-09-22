package eu.heliovo.hps.server.application;

public class DummyProcessingBroker implements ProcessingBroker 
{
	static	ProcessingEngine	fastEngine	=	new FastEngine();
	static 	ProcessingEngine	gridEngine	=	new GridEngine();
	
	@Override
	public ProcessingEngine match(ApplicationExecutionDescription exeDesc) 
	{
		if(exeDesc.fastExecution)
			return 	fastEngine;
		else
			return	gridEngine;
	}
}
