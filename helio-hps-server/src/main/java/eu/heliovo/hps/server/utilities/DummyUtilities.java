package eu.heliovo.hps.server.utilities;

import eu.heliovo.hps.server.ApplicationExecutionStatus;

public class DummyUtilities 
{
	RandomUtilities	rndUtilities	=	new RandomUtilities();
	
	public	String	getNextStatus(String oldStatus)
	{
		String	newStatus	=	oldStatus;
		
		if(rndUtilities.getRandomBetween(0, 100) > 50)
		{		
			if(oldStatus == ApplicationExecutionStatus.Running)
				newStatus	=	ApplicationExecutionStatus.Completed;
		}
		return newStatus;
	}
}
