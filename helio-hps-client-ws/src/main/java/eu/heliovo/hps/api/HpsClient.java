package eu.heliovo.hps.api;

import java.util.Collection;

import javax.xml.ws.BindingProvider;

import eu.heliovo.hps.server.AbstractApplicationDescription;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceException_Exception;
import eu.heliovo.hps.server.HPSServiceService;
import eu.heliovo.shared.common.LogUtils;

public class HpsClient 
{
	/*
	 * The Service Stubs
	 */
	HPSServiceService	hpsSS			=	new HPSServiceService();
	HPSService			hpsService		=	null;
	/*
	 * Local instance of the HPS
	 */
//	String				serviceAddress	=	"http://localhost:8080/helio-cis-server-ws/cisService";
	/*
	 * Remote instance of the HPS
	 */
	String  			serviceAddress	=	"http://cagnode58.cs.tcd.ie:8080/helio-hps-server-ws/hpsService";
	/*
	 * Default Constructor, also adds user_a and user_b if not already present in the CIS
	 */
	public HpsClient() 
	{
		LogUtils.printShortLogEntry("[HPS-CLIENT-WS] - Invoking default constructor...");
		/*
		 * Creating stubs for the CIS Service
		 */
		LogUtils.printShortLogEntry("[HPS-CLIENT-WS] - Creating stubs ...");
		hpsService	=	hpsSS.getHPSServicePort();			
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);
	}
	
	public boolean test() 
	{
		LogUtils.printShortLogEntry("[HPS-CLIENT-WS] - Invoking test on the HPS...");
		try 
		{
			LogUtils.printShortLogEntry("[HPS-CLIENT-WS] - "  + hpsService.test("test-param"));
			LogUtils.printShortLogEntry("[HPS-CLIENT-WS] - ...done");	
			return true;
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
			return false;
		}
	}

	public void putFile(String hit, String fileName, String fileContent) 
	{
		LogUtils.printShortLogEntry("[HPS-CLIENT-WS] - Putting "+fileContent.length() +" on "+fileName+"...");
		try 
		{
			hpsService.putFile(hit, fileName, fileContent);
			LogUtils.printShortLogEntry("[HPS-CLIENT-WS] - ...done");	
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
		}
	}

	public String executeUserDefinedApplication(
			String hit,
			String jobFileName, 
			boolean fastExecution) 
	{
		try 
		{
			return hpsService.executeUserDefinedApplication(hit, jobFileName, fastExecution);
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
			return null;
		}
	}

	
	public String getStatusOfExecution(String jobId) 
	{
		try 
		{
			return hpsService.getStatusOfExecution(jobId);
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
			return null;
		}
	}

	public String getOutputOfExecution(String jobId) 
	{
		try 
		{
			return hpsService.getOutputOfExecution(jobId);
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
			return null;
		}
	}
	
	public Collection<AbstractApplicationDescription> getPresentApplications() 
	{
		try 
		{
			return hpsService.getPresentApplications();
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
			return null;
		}
	}

	public String executeApplication(
			AbstractApplicationDescription app,
			Boolean fastExecution, int numJobs) 
	{
		try 
		{
			return hpsService.executeApplication(app, fastExecution, numJobs);
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
			return null;
		}
	}
}
