package eu.heliovo.hps.client;

import static org.junit.Assert.assertTrue;

import java.util.Vector;

import javax.xml.ws.BindingProvider;

import org.junit.Ignore;
import org.junit.Test;

import eu.heliovo.hps.server.AbstractApplicationDescription;
import eu.heliovo.hps.server.ApplicationParameter;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceService;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceImplTest 
{
	LogUtilities logUtilities = new LogUtilities();
	/*
	 * The Service Stubs
	 */
	HPSServiceService	hpsSS			=	new HPSServiceService();
//	String				serviceAddress	=	"http://localhost:8080/helio-hps-server/hpsService";
	String  			serviceAddress	=	"http://cagnode58.cs.tcd.ie:8080/helio-hps-server/hpsService";

//	@Ignore
//	@Test
//	public void testTest() 
//	{
//		HPSService	hpsService	=	hpsSS.getHPSServicePort();
//		((BindingProvider)hpsService).getRequestContext().put(
//				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
//				serviceAddress);
//
//
//		String arg = "Test Argument";
//
//		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.test(" + arg
//				+ ")...");
//		assertNotNull(hpsService.test(arg));
//		logUtilities.printShortLogEntry("... done");
//	}

//	@Ignore
//	@Test
//	public void testGetPresentApplications() 
//	{
//		HPSService	hpsService	=	hpsSS.getHPSServicePort();
//		((BindingProvider)hpsService).getRequestContext().put(
//				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
//				serviceAddress);
//
//
//		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.getPresentApplications(...)...");
//		assertNotNull(hpsService.getPresentApplications());
//		logUtilities.printShortLogEntry("... done");
//	}

//	@Ignore
//	@Test
//	public void testExecuteApplication() 
//	{
//		HPSService	hpsService	=	hpsSS.getHPSServicePort();
//		((BindingProvider)hpsService).getRequestContext().put(
//				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
//				serviceAddress);
//		
//		Vector<ApplicationParameter> params = new Vector<ApplicationParameter>();
//		ApplicationParameter	p	=	new ApplicationParameter();
//		p.setName("param_a");
//		p.setType("String");
//		p.setDef("UNDEFINED");
//		p.setValue("Gab");
//		params.add(p);
//		p	=	new ApplicationParameter();
//		p.setName("param_b");
//		p.setType("String");
//		p.setDef("UNDEFINED");
//		p.setValue("Nasik");
//		params.add(p);
//		p	=	new ApplicationParameter();
//		p.setName("param_");
//		p.setType("Float");
//		p.setDef("UNDEFINED");
//		p.setValue("7.12");
//		params.add(p);
//		
//		
//		AbstractApplicationDescription app = new AbstractApplicationDescription();
//
//		app.setName("Application_1");
//		app.setId("app_1");
//		app.setDescription("Description of application 1");
//		
////		AbstractApplicationDescription app = new AbstractApplicationDescription
////		(
////				"Application_1", "app_1", "Description of application 1",
////				params);
//
//		logUtilities
//				.printShortLogEntry("Invoking HPSServiceImpl.getPresentApplications(...)...");
//		try {
//			Object exeId = hpsService.executeApplication(app, true, 1);
//			assertNotNull(exeId);
//			assertTrue(exeId.getClass().equals(String.class));
//		} catch (Exception e) {
//			assertTrue(false);
//		}
//		logUtilities.printShortLogEntry("... done");
//	}
//
//	@Ignore
//	@Test
//	public void testGetStatusOfExecution() 
//	{
//		HPSService	hpsService	=	hpsSS.getHPSServicePort();
//		((BindingProvider)hpsService).getRequestContext().put(
//				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
//				serviceAddress);
//
//
//		Vector<ApplicationParameter> params = new Vector<ApplicationParameter>();
//		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED",
//				"Gab"));
//		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED",
//				"Nasik"));
//		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED",
//				"7.12"));
//		AbstractApplicationDescription app = new AbstractApplicationDescription(
//				"Application_1", "app_1", "Description of application 1",
//				params);
//
//		logUtilities
//				.printShortLogEntry("Invoking HPSServiceImpl.getStatusOfExecution(...)...");
//		try {
//			Object exeId = hpsService.executeApplication(app, true, 1);
//			assertNotNull(exeId);
//			assertTrue(exeId.getClass().equals(String.class));
//			assertTrue(hpsService.getStatusOfExecution((String) exeId).equals(
//					ApplicationExecutionStatus.Running));
//		} catch (Exception e) {
//			assertTrue(false);
//		}
//		logUtilities.printShortLogEntry("... done");
//	}
//
//	@Ignore
//	@Test
//	public void testGetOutputOfExecution() 
//	{
//		HPSService	hpsService	=	hpsSS.getHPSServicePort();
//		((BindingProvider)hpsService).getRequestContext().put(
//				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
//				serviceAddress);
//
//
//		
//		Vector<ApplicationParameter> params = new Vector<ApplicationParameter>();
//		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED",
//				"Gab"));
//		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED",
//				"Nasik"));
//		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED",
//				"7.12"));
//		AbstractApplicationDescription app = new AbstractApplicationDescription(
//				"Application_1", "app_1", "Description of application 1",
//				params);
//
//		logUtilities
//				.printShortLogEntry("Invoking HPSServiceImpl.getOutputOfExecution(...)...");
//		try {
//			Object exeId = hpsService.executeApplication(app, true, 1);
//			assertNotNull(exeId);
//			assertTrue(exeId.getClass().equals(String.class));
//			assertNotNull(hpsService.getOutputOfExecution((String) exeId));
//		} catch (HPSServiceException e) {
//			assertTrue(false);
//		}
//		logUtilities.printShortLogEntry("... done");
//	}

	@Ignore @Test
	public void testExecuteApplications() 
	{
		/*
		 * The service stub
		 */
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);


		/*
		 * The number of test applications
		 */
		int numOfApps = 1;
		/*
		 * The vector of running applications
		 */
		Vector<String> runningApps = new Vector<String>();
		/*
		 * Create description of application
		 */
		System.out.println("---------------------------------------------------------------------------------");

		logUtilities.printShortLogEntry("Creating a test application....");
		Vector<ApplicationParameter> params = new Vector<ApplicationParameter>();

		ApplicationParameter	p	=	new ApplicationParameter();
		p.setName("param_a");
		p.setType("String");
		p.setDef("UNDEFINED");
		p.setValue("Gab");
		params.add(p);
		p	=	new ApplicationParameter();
		p.setName("param_b");
		p.setType("String");
		p.setDef("UNDEFINED");
		p.setValue("Nasik");
		params.add(p);
		p	=	new ApplicationParameter();
		p.setName("param_");
		p.setType("Float");
		p.setDef("UNDEFINED");
		p.setValue("7.12");
		params.add(p);
	
		
		AbstractApplicationDescription app = new AbstractApplicationDescription();
		
		app.setDescription("Description of application 1");
		app.setId("app_1");
		app.setName("Application_1");
		app.setParameter(params);
		
//		AbstractApplicationDescription app = new AbstractApplicationDescription(
//				"Application_1", "app_1", "Description of application 1",
//				params);
		
		logUtilities.printShortLogEntry("Test application is : "
				+ app.getDescription());

		System.out.println("---------------------------------------------------------------------------------");

		logUtilities.printShortLogEntry("Submitting " + numOfApps
				+ " instances of " + app.getName());

		for (int n = 0; n < numOfApps; n++) {
			try {
				String exeId = hpsService.executeApplication(app, true, 1);
				logUtilities.printShortLogEntry(app.getDescription()
						+ " running on the HPS with execution id " + exeId);
				runningApps.add(exeId);
			} catch (Exception e) {
				logUtilities.printShortLogEntry(app.getDescription()
						+ " failed to be submitted on the HPS !!!");
				assertTrue(false);
			}
		}

		System.out.println("---------------------------------------------------------------------------------");

		while (runningApps.size() > 0) 
		{
			logUtilities.printShortLogEntry("Checking status and retrieving output of the running applications...");
			String 	exeId 					= 	null;
			String 	exeStatus 				= 	null;

			for (int n = 0; n < runningApps.size(); n++) 
			{
				try 
				{
					exeId = runningApps.get(n);
					exeStatus = hpsService.getStatusOfExecution(exeId);
					System.out.println(exeId + " --> " + exeStatus);
					/*
					 * If the application is completed, retrieve the output and
					 * remove from the list of running applications
					 */
					if (exeStatus.equals("Completed")) 
					{
						hpsService.getOutputOfExecution(exeId);
						runningApps.remove(n);
					}
				} 
				catch (Exception e) 
				{
					logUtilities.printShortLogEntry(" Failed to retrieve the output of " + exeId);
					assertTrue(false);
				}
				try 
				{
					Thread.sleep(1000);
				} 
				catch (InterruptedException e) 
				{
					e.printStackTrace();
				}			
			}
			System.out.println("---------------------------------------------------------------------------------");			
		}
	}
}
