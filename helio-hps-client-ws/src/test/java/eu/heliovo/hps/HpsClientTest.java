package eu.heliovo.hps;

import static org.junit.Assert.assertTrue;

import javax.xml.ws.BindingProvider;

import org.junit.Test;

import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceException_Exception;
import eu.heliovo.hps.server.HPSServiceService;
import eu.heliovo.shared.common.LogUtils;

public class HpsClientTest 
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
	public HpsClientTest() 
	{
		super();
		LogUtils.printShortLogEntry("[HPS-CLIENT-TEST] - Invoking default constructor...");
		/*
		 * Creating stubs for the CIS Service
		 */
		LogUtils.printShortLogEntry("[HPS-CLIENT-TEST] - Creating stubs ...");
		hpsService	=	hpsSS.getHPSServicePort();			
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);
	}
	
	@Test
	public void testTest() 
	{
		LogUtils.printShortLogEntry("[HPS-CLIENT-TEST] - Invoking test for test...");
		try 
		{
			LogUtils.printShortLogEntry("[HPS-CLIENT-TEST] - "  + hpsService.test("test-param"));
			assertTrue(true);
			LogUtils.printShortLogEntry("[HPS-CLIENT-TEST] - ...done");	
		} 
		catch (HPSServiceException_Exception e) 
		{
			e.printStackTrace();
			assertTrue(false);
		}
	}
}
