package eu.heliovo.hps.server; 

import java.util.Collection;

import javax.jws.WebMethod;
import javax.jws.WebService;


@WebService
public interface HPSService 
{
	/**
	 * Test
	 *
	 * @param a string parameter
	 */
	@WebMethod
	public	String	test(String arg);

	/**
	 * getPresentApplications
	 * @throws HPSServiceException 
	 */
	@WebMethod
	public	Collection<ApplicationDescription> getPresentApplications() throws HPSServiceException;
	
	@WebMethod
	public String getStatusOfExecution(String exeId);

	@WebMethod
	public Boolean isRunning(String exeId);

	@WebMethod
	public void putFile(String fileLocation, String fileContent) throws HPSServiceException;

	@WebMethod
	public String getFile(String fileLocation) throws HPSServiceException;

	@WebMethod
	public String executeApplication(
			ApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs) throws ApplicationEngineException;

	@WebMethod
	public String getOutputOfExecution(String exeId) throws HPSServiceException;
}
