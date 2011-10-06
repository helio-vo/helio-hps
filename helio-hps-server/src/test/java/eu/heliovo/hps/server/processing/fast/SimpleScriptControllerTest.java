package eu.heliovo.hps.server.processing.fast;

import static org.junit.Assert.fail;

import org.junit.Ignore;
import org.junit.Test;

import eu.heliovo.shared.common.utilities.LogUtilities;

public class SimpleScriptControllerTest 
{
	LogUtilities			logUtilities	=	new LogUtilities();
	
	SimpleScriptController	c	=	new SimpleScriptController();

	@Ignore @Test
	public void testStart() 
	{
		logUtilities.printShortLogEntry("Test - Before invoking c.start()...");
		logUtilities.printShortLogEntry("Test - Thread state : " + c.getState().toString());
		c.start();
		logUtilities.printShortLogEntry("Test - Thread state : " + c.getState().toString());
		logUtilities.printShortLogEntry("Test - After invoking c.start()...");
		logUtilities.printShortLogEntry("Test - Thread state : " + c.getState().toString());
	}

	@Ignore @Test
	public void testRun() 
	{
		System.out.println("Before invoking c.run()...");
		c.run();
		System.out.println("After invoking c.run()...");
	}

	@Ignore @Test
	public void testIsAlive() 
	{
		fail("Not yet implemented");
	}

	@Test
	public void testGetState() 
	{
		logUtilities.printShortLogEntry("Test.testGetState() - Before invoking c.start()...");
		c.start();
		logUtilities.printShortLogEntry("Test.testGetState() - After invoking c.start()...");
		
		while(!c.getState().equals(Thread.State.TERMINATED))
		{
			logUtilities.printShortLogEntry("Test.testGetState() - Thread state : " + c.getState().toString());
			try 
			{
				Thread.sleep(100);
			} 
			catch (InterruptedException e) 
			{
				e.printStackTrace();
			}
		}
	}
}
