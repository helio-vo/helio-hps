package eu.heliovo.hps.server;

import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceImpl implements HPSService 
{
	LogUtilities	logUtilities	=	new LogUtilities();
	
	@Override
	public String test(String arg) 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.test("+arg+") ==> " + arg);
		return arg;
	}	
}
