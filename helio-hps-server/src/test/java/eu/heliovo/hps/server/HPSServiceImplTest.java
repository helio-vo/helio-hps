package eu.heliovo.hps.server;

import static org.junit.Assert.*;

import org.junit.Test;

import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceImplTest 
{
	HPSService		hpsService		=	new HPSServiceImpl();
	LogUtilities	logUtilities	=	new LogUtilities();

	@Test
	public void testTest() 
	{
		String	arg	=	"Test Argument";
		
		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.test("+arg+")...");
		assertNotNull(hpsService.test(arg));
		logUtilities.printShortLogEntry("... done");
	}
}
