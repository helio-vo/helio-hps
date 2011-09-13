package eu.heliovo.hps.server;

import java.util.Collection;

import eu.heliovo.hps.server.application.AbstractApplicationDescription;
import eu.heliovo.hps.server.application.ApplicationRepository;
import eu.heliovo.hps.server.application.DummyApplicationRepository;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceImpl implements HPSService 
{
	/*
	 * Various Utilities
	 */
	LogUtilities				logUtilities	=	new LogUtilities();
	/*
	 * The repository of the applications
	 */
	ApplicationRepository		appRepository	=	new DummyApplicationRepository();
	
	@Override
	public String test(String arg) 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.test("+arg+")");
		return arg;
	}

	@Override
	public Collection<AbstractApplicationDescription> getPresentApplications() 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.getPresentApplications()");
		return appRepository.getPresentApplications();
	}	
}
