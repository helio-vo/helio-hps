package eu.heliovo.hps;

import java.util.Collection;

import eu.heliovo.hps.client.HpsClient;
import eu.heliovo.hps.client.HpsDummyClient;
import eu.heliovo.hps.client.HpsStub;
import eu.heliovo.hps.server.ApplicationDescription;
import eu.heliovo.hps.server.HPSServiceException;

public class HpsLocalInterface 
{
	boolean		debug		=	false;
	HpsStub		localHps	=	new HpsDummyClient();
	HpsStub		remoteHps	=	new HpsClient();
	
	public HpsLocalInterface() 
	{
		debug	=	false;
	}

	public HpsLocalInterface(boolean debug) 
	{
		super();
		this.debug = debug;
	}

	/**
	 * @return the debug
	 */
	public boolean isDebug() 
	{
		return debug;
	}

	/**
	 * @param debug the debug to set
	 */
	public void setDebug(boolean debug) 
	{
		this.debug = debug;
	}
		
	public String test(String parameter) throws Exception 
	{
		if(debug)
			return localHps.test(parameter);
		else
			return remoteHps.test(parameter);
	}
	
	public Collection<ApplicationDescription> getPresentApplications() throws Exception 
	{
		if(debug)
			return localHps.getPresentApplications();
		else
			return remoteHps.getPresentApplications();
	}

	public String getStatusOfExecution(String exeId) throws Exception 
	{
		if(debug)
			return localHps.getStatusOfExecution(exeId);
		else
			return remoteHps.getStatusOfExecution(exeId);
	}

	public Boolean isRunning(String exeId) throws Exception 
	{
		throw new HpsLocalInterfaceException("Not Implemented Yet");
	}
	
	public void getFile(String remoteFile, String localFile) throws Exception 
	{
		throw new HpsLocalInterfaceException("Not Implemented Yet");
	}

	public String getOutputOfExecution(String selectedId) throws HpsLocalInterfaceException, HPSServiceException 
	{
		if(debug)
			return localHps.getOutputOfExecution(selectedId);
		else
			return remoteHps.getOutputOfExecution(selectedId);
	}

	public String executeApplication(
			ApplicationDescription app,
			Boolean fastExecution, 
			int numJobs) throws Exception 
	{
		if(debug)
			return localHps.executeApplication(app, fastExecution, numJobs);
		else
			return remoteHps.executeApplication(app, fastExecution, numJobs);
	}
}
