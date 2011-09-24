package eu.heliovo.hps.server.processing.fast;

import eu.heliovo.hps.server.utilities.RandomUtilities;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class DummyScriptController extends Thread
{
	LogUtilities		logUtilities	=	new LogUtilities();
	RandomUtilities		rndUtilities	=	new RandomUtilities();
	
	
	@Override
	public void run() 
	{
		int		delay	=	rndUtilities.getRandomBetween(1000, 10000);
		
		logUtilities.printShortLogEntry("Thread.run() - Before waiting " + delay + " milliseconds...");		
		try 
		{
			Thread.sleep(delay);
		} 
		catch (InterruptedException e) 
		{
			e.printStackTrace();
		}		
		logUtilities.printShortLogEntry("Thread.run() - Ending...");
	}

	@Override
	public String toString() 
	{
		return getState().toString();
	}	
}
