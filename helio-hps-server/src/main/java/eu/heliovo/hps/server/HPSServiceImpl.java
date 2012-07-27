package eu.heliovo.hps.server;

import java.util.Collection;

import eu.heliovo.hps.server.application.AbstractApplicationDescription;
import eu.heliovo.hps.server.application.ApplicationEngine;
import eu.heliovo.hps.server.application.ApplicationRepository;
import eu.heliovo.hps.server.application.DummyApplicationRepository;
import eu.heliovo.hps.server.application.ProcessingEngineException;
import eu.heliovo.hps.server.application.SimpleApplicationEngine;
import eu.heliovo.shared.common.LogUtils;
import eu.heliovo.shared.util.ServiceStatus;

public class HPSServiceImpl implements HPSService 
{
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
		LogUtils.printShortLogEntry("HPSServiceImpl.test(...)");
		return arg;
	}

	
	@Override
	public String getStatus() throws HPSServiceException 
	{
		LogUtils.printShortLogEntry("[HPS-SERVER] - Executing getStatus()...");		
		return ServiceStatus.OK;        
	}

	@Override
	public Collection<AbstractApplicationDescription> getPresentApplications() 
	{
		LogUtils.printShortLogEntry("HPSServiceImpl.getPresentApplications()");
		return appRepository.getPresentApplications();
	}

	@Override
	public String executeApplication(
			AbstractApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs)
			throws HPSServiceException 
	{
		/*
		 * TODO : Remove comments...
		 */
		LogUtils.printShortLogEntry("HPSServiceImpl.executeApplication(...)");
//		logUtilities.printLongLogEntry("Executing the following application : " + app.getFullDescription());		
//		logUtilities.printLongLogEntry(" xxx " + app.getParameters());
		
		try 
		{
			return appEngine.executeApplication(
					appRepository.getApplicationCompleteDescription(app), 
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
		LogUtils.printShortLogEntry("HPSServiceImpl.getStatusOfExecution(...)");
		return appEngine.getStatusOfExecution(exeId);
	}

	@Override
	public String getOutputOfExecution(String exeId) throws HPSServiceException 
	{
		LogUtils.printShortLogEntry("HPSServiceImpl.getOutputOfExecution(...)");
		return "http://cagnode58.cs.tcd.ie/output_dir/"+exeId;
		// return appEngine.getOutputOfExecution(exeId);
	}	
}
