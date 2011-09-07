package eu.heliovo.hps.client;

import java.util.Collection;

import eu.heliovo.hps.server.ApplicationDescription;
import eu.heliovo.hps.server.HPSServiceException;

public interface HpsStub 
{
	public abstract String test(String parameter) throws Exception;

	public abstract Collection<ApplicationDescription> getPresentApplications()
			throws Exception;

	public abstract String getStatusOfExecution(String exeId) throws Exception;

	public abstract Boolean isRunning(String exeId) throws Exception;

	public abstract void getFile(String remoteFile, String localFile)
			throws Exception;

	public abstract String executeApplication(ApplicationDescription app,
			Boolean fastExecution, int numJobs) throws Exception;

	public abstract String getOutputOfExecution(String selectedId)
			throws HPSServiceException;

}