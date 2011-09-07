package eu.heliovo.hps.client;

import java.util.Collection;

import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;

import eu.heliovo.hps.server.ApplicationDescription;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceException;
import eu.heliovo.hps.utilities.FileUtilities;

public class HpsClient implements HpsStub
{
//	private 	String				serviceAddress	=	"http://localhost:8080/helio-hps-server/exampleService";
	private 	String				serviceAddress	=	"http://cagnode58.cs.tcd.ie:8080/helio-hps-server/exampleService";
	private		Class<HPSService>	serviceClass	=	HPSService.class;
	private		HPSService 			remoteClient 	= 	null;
	private		FileUtilities		fileUtilities	=	new FileUtilities();	
	
	public HpsClient() 
	{
		super();		
	   	JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
    	factory.setServiceClass(serviceClass);
    	factory.setAddress(serviceAddress);
    	remoteClient = (HPSService) factory.create();
	}

	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#test(java.lang.String)
	 */
	@Override
	public String test(String parameter) throws Exception 
	{
    	return remoteClient.test(parameter);    
	}
	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getPresentApplications()
	 */
	@Override
	public Collection<ApplicationDescription> getPresentApplications() throws Exception 
	{
    	return remoteClient.getPresentApplications();     
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getStatusOfExecution(java.lang.String)
	 */
	@Override
	public String getStatusOfExecution(String exeId) throws Exception 
	{
    	return remoteClient.getStatusOfExecution(exeId);     
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#isRunning(java.lang.String)
	 */
	@Override
	public Boolean isRunning(String exeId) throws Exception 
	{
    	return remoteClient.isRunning(exeId);     
	}
	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getFile(java.lang.String, java.lang.String)
	 */
	@Override
	public void getFile(String remoteFile, String localFile) throws Exception 
	{
		fileUtilities.writeTo(localFile, remoteClient.getFile(remoteFile));
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#executeApplication(eu.heliovo.hps.server.ApplicationDescription, java.lang.Boolean, int)
	 */
	@Override
	public String executeApplication(
			ApplicationDescription app,
			Boolean fastExecution, 
			int numJobs) throws Exception 
	{
		return remoteClient.executeApplication(app, fastExecution, numJobs);
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.client.HpsStub#getOutputOfExecution(java.lang.String)
	 */
	@Override
	public String getOutputOfExecution(String selectedId) throws HPSServiceException 
	{
		return remoteClient.getOutputOfExecution(selectedId);
	}
}