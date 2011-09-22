package eu.heliovo.hps.server.utilities;

import eu.heliovo.shared.common.utilities.TimeUtilities;

public class ExecutionUtilities 
{
	RandomUtilities	randomUtilities		=	new RandomUtilities();
	TimeUtilities	timeUtilities		=	new TimeUtilities();
	
	public	String	getExecutionId()
	{		
		return timeUtilities.getCompactStamp() 
		+ "-" + 
		String.valueOf(randomUtilities.getRandomBetween(1, 100000));
	}
}
