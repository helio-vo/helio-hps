package eu.heliovo.hps.server;

import java.util.Collection;

import eu.heliovo.hps.server.application.AbstractApplicationDescription;
import eu.heliovo.hps.server.application.ApplicationEngine;
import eu.heliovo.hps.server.application.ApplicationRepository;
import eu.heliovo.hps.server.application.DummyApplicationEngine;
import eu.heliovo.hps.server.application.DummyApplicationRepository;
import eu.heliovo.hps.server.application.ProcessingEngineException;
import eu.heliovo.hps.server.application.SimpleApplicationEngine;
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
	/*
	 * The engine that executes the applications
	 */
	static	ApplicationEngine	appEngine		=	new SimpleApplicationEngine();
	
	@Override
	public String test(String arg) 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.test(...)");
		return arg;
	}

	@Override
	public Collection<AbstractApplicationDescription> getPresentApplications() 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.getPresentApplications()");
		return appRepository.getPresentApplications();
	}

	@Override
	public String executeApplication(
			AbstractApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs)
			throws HPSServiceException 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.executeApplication(...)");
		logUtilities.printLongLogEntry("Executing the following application : " + app.getFullDescription());
		
		logUtilities.printLongLogEntry(" xxx " + app.getParameters());
		
		try 
		{
			return appEngine.executeApplication(
					appRepository.getApplicationCompleteDescription(app.getId()), 
					fastExecution, 
					numParallelJobs);
		} 
		catch (ProcessingEngineException e) 
		{
			e.printStackTrace();
			throw new HPSServiceException("Execution of application failed !");
		}
	}

	@Override
	public String getStatusOfExecution(String exeId) 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.getStatusOfExecution(...)");
		return appEngine.getStatusOfExecution(exeId);
	}

	@Override
	public String getOutputOfExecution(String exeId) throws HPSServiceException 
	{
		logUtilities.printShortLogEntry("HPSServiceImpl.getOutputOfExecution(...)");
		return appEngine.getOutputOfExecution(exeId);
	}	
}
