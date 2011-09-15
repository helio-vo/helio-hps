package eu.heliovo.hps.server; 

import java.util.Collection;
import java.util.Vector;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;

import eu.heliovo.hps.server.application.AbstractApplicationDescription;

@WebService
public interface HPSService 
{
	/**
	 * Test
	 *
	 * @param a string parameter
	 */
	@WebMethod
	@WebResult(name="testResult")
	public	String	test(@WebParam(name="testParameter") String testParemeter);
	
	/**
	 * getPresentApplications
	 */
	@WebMethod
	@WebResult(name="presentApplications")
	public	Collection<AbstractApplicationDescription> getPresentApplications();

	
//	@WebMethod
//	public String getStatusOfExecution(String exeId);
//
//	@WebMethod
//	public Boolean isRunning(String exeId);
//
//	@WebMethod
//	public void putFile(String fileLocation, String fileContent) throws HPSServiceException;
//
//	@WebMethod
//	public String getFile(String fileLocation) throws HPSServiceException;
//
//	@WebMethod
//	public String executeApplication(
//			ApplicationDescription app,
//			Boolean fastExecution, 
//			int numParallelJobs) throws ApplicationEngineException;
//
//	@WebMethod
//	public String getOutputOfExecution(String exeId) throws HPSServiceException;

}
