package eu.heliovo.hps.server.application;

import static org.junit.Assert.*;

import org.junit.Test;

import eu.heliovo.shared.common.utilities.LogUtilities;

public class DummyApplicationRepositoryTest 
{
	LogUtilities				logUtilities	=	new LogUtilities();
	DummyApplicationRepository	appRepository	=	new DummyApplicationRepository();
	
	@Test
	public void testGetPresentApplications() 
	{
		logUtilities.printShortLogEntry("List applications present on the HPS...");
		logUtilities.printLongLogEntry(appRepository.getPresentApplications().toString());
	}

	@Test
	public void testGetApplication() 
	{
		String appId	=	"app_1";
		
		logUtilities.printShortLogEntry("Get the abstract description of " + appId);
		logUtilities.printLongLogEntry(appRepository.getApplication(appId).toString());
	}

	@Test
	public void testGetApplicationCompleteDescription() 
	{
		String appId	=	"app_1";
		
		logUtilities.printShortLogEntry("Get the complete description of " + appId);
		logUtilities.printLongLogEntry(appRepository.getApplicationCompleteDescription(appId).toString());
	}

}
