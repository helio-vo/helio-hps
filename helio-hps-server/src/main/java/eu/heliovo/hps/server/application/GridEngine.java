package eu.heliovo.hps.server.application;


public class GridEngine extends GenericProcessingEngine 
{
	@Override
	protected boolean execute(ApplicationExecutionDescription exeDesc) 
	{
		return true;
	}

	@Override
	public String toString() 
	{
		return "Grid Execution Engine";
	}		
}
