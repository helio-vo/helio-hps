package eu.heliovo.hps.client;

import java.util.Collection;

import eu.heliovo.hps.server.ApplicationDescription;
import eu.heliovo.hps.server.HPSDummyService;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceException;
// import eu.heliovo.shared.common.utilities.FileUtilities;
import eu.heliovo.hps.utilities.FileUtilities;

public class HpsDummyClient implements HpsStub
{
	private		HPSService 			hps 			= 	new HPSDummyService();
	private		FileUtilities		fileUtilities	=	new FileUtilities();	
	
	public HpsDummyClient() 
	{
		super();		
	}
	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#test(java.lang.String)
	 */
	@Override
	public String test(String parameter) throws Exception 
	{
    	return hps.test(parameter);    
	}
	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getPresentApplications()
	 */
	@Override
	public Collection<ApplicationDescription> getPresentApplications() throws Exception 
	{
    	return hps.getPresentApplications();     
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getStatusOfExecution(java.lang.String)
	 */
	@Override
	public String getStatusOfExecution(String exeId) throws Exception 
	{
    	return hps.getStatusOfExecution(exeId);     
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#isRunning(java.lang.String)
	 */
	@Override
	public Boolean isRunning(String exeId) throws Exception 
	{
    	return hps.isRunning(exeId);     
	}
	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getFile(java.lang.String, java.lang.String)
	 */
	@Override
	public void getFile(String remoteFile, String localFile) throws Exception 
	{
		fileUtilities.writeTo(localFile, hps.getFile(remoteFile));
	}


	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getOutputOfExecution(java.lang.String)
	 */
	@Override
	public String getOutputOfExecution(String selectedId) throws HPSServiceException 
	{
		return hps.getOutputOfExecution(selectedId);
	}

	public String executeApplication
	(
			ApplicationDescription app,
			Boolean fastExecution, 
			int numJobs) throws Exception 
	{
		return hps.executeApplication(app, fastExecution, numJobs);	
	}
}