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
	 * @param a generic string parameter for the test, it is just returned as it is.
	 */
	@WebMethod
	@WebResult(name="testResult")
	public	String	test(@WebParam(name="testParameter") String testParemeter);	
	/**
	 * getStatus
	 *
	 * @throws HPSServiceException 
	 */
	@WebMethod
	@WebResult(name="getStatusResult")
	String getStatus() throws HPSServiceException;
	/**
	 * getPresentApplications
	 * 
	 * @return Returns a collection that contains all the applications present in the HPS
	 */
	@WebMethod
	@WebResult(name="presentApplications")
	public	Collection<AbstractApplicationDescription> getPresentApplications();
	/**
	 * executeApplication
	 * 
	 * @return Submits the defined application to the HPS
	 */
	@WebMethod
	@WebResult(name="executionId")
	public String executeApplication(
			@WebParam(name="selectedApplication") AbstractApplicationDescription app,
			@WebParam(name="fastExecution") Boolean fastExecution, 
			@WebParam(name="numOfParallelJobs") int numParallelJobs) throws HPSServiceException;

	@WebMethod
	@WebResult(name="executionStatus")
	public String getStatusOfExecution(
			@WebParam(name="executionId") String exeId);

	@WebMethod
	@WebResult(name="outputLocation")
	public String getOutputOfExecution(
			@WebParam(name="executionId") String exeId) throws HPSServiceException;

//	@WebMethod
//	public Boolean isRunning(String exeId);
//
//	@WebMethod
//	public void putFile(String fileLocation, String fileContent) throws HPSServiceException;
//
//	@WebMethod
//	public String getFile(String fileLocation) throws HPSServiceException;

//	@WebMethod
//	public String executeApplication(
//			ApplicationDescription app,
//			Boolean fastExecution, 
//			int numParallelJobs) throws ApplicationEngineException;
}
