package eu.heliovo.hps.server;

import static org.junit.Assert.*;

import java.util.Collection;
import java.util.Vector;

import org.junit.Ignore;
import org.junit.Test;

import eu.heliovo.hps.server.application.AbstractApplicationDescription;
import eu.heliovo.hps.server.application.ApplicationParameter;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceImplTest {
	HPSService hpsService = new HPSServiceImpl();
	LogUtilities logUtilities = new LogUtilities();

	@Ignore
	@Test
	public void testTest() {
		String arg = "Test Argument";

		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.test(" + arg
				+ ")...");
		assertNotNull(hpsService.test(arg));
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore
	@Test
	public void testGetPresentApplications() {
		logUtilities
				.printShortLogEntry("Invoking HPSServiceImpl.getPresentApplications(...)...");
		assertNotNull(hpsService.getPresentApplications());
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore
	@Test
	public void testExecuteApplication() {
		Vector<ApplicationParameter> params = new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED",
				"Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED",
				"Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED",
				"7.12"));
		AbstractApplicationDescription app = new AbstractApplicationDescription(
				"Application_1", "app_1", "Description of application 1",
				params);

		logUtilities
				.printShortLogEntry("Invoking HPSServiceImpl.getPresentApplications(...)...");
		try {
			Object exeId = hpsService.executeApplication(app, true, 1);
			assertNotNull(exeId);
			assertTrue(exeId.getClass().equals(String.class));
		} catch (HPSServiceException e) {
			assertTrue(false);
		}
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore
	@Test
	public void testGetStatusOfExecution() {
		Vector<ApplicationParameter> params = new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED",
				"Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED",
				"Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED",
				"7.12"));
		AbstractApplicationDescription app = new AbstractApplicationDescription(
				"Application_1", "app_1", "Description of application 1",
				params);

		logUtilities
				.printShortLogEntry("Invoking HPSServiceImpl.getStatusOfExecution(...)...");
		try {
			Object exeId = hpsService.executeApplication(app, true, 1);
			assertNotNull(exeId);
			assertTrue(exeId.getClass().equals(String.class));
			assertTrue(hpsService.getStatusOfExecution((String) exeId).equals(
					ApplicationExecutionStatus.Running));
		} catch (HPSServiceException e) {
			assertTrue(false);
		}
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore
	@Test
	public void testGetOutputOfExecution() {
		Vector<ApplicationParameter> params = new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED",
				"Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED",
				"Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED",
				"7.12"));
		AbstractApplicationDescription app = new AbstractApplicationDescription(
				"Application_1", "app_1", "Description of application 1",
				params);

		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.getOutputOfExecution(...)...");

		try 
		{
			Object exeId = hpsService.executeApplication(app, true, 1);
			assertNotNull(exeId);
			assertTrue(exeId.getClass().equals(String.class));
			assertNotNull(hpsService.getOutputOfExecution((String) exeId));
		} catch (HPSServiceException e) {
			assertTrue(false);
		}
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore
	@Test
	public void testExecuteApplications() {
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
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED",
				"Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED",
				"Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED",
				"7.12"));
		AbstractApplicationDescription app = new AbstractApplicationDescription(
				"Application_1", "app_1", "Description of application 1",
				params);
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
			} catch (HPSServiceException e) {
				logUtilities.printShortLogEntry(app.getDescription()
						+ " failed to be submitted on the HPS !!!");
				assertTrue(false);
			}
		}

		System.out.println("---------------------------------------------------------------------------------");

		while (runningApps.size() > 0) 
		{
			logUtilities.printShortLogEntry("Checking status of the running applications...");
			String 	exeId 					= 	null;
			String 	exeStatus 				= 	null;

			for (int n = 0; n < runningApps.size(); n++) 
			{
				try 
				{
					exeId = runningApps.get(n);
					exeStatus = hpsService.getStatusOfExecution(exeId);
//					System.out.println(exeId + " --> " + exeStatus);
					/*
					 * If the application is completed, retrieve the output and
					 * remove from the list of running applications
					 */
//					System.out.println(runningApps);
					if (exeStatus.equals(ApplicationExecutionStatus.Completed)) 
					{
						hpsService.getOutputOfExecution(exeId);
						runningApps.remove(n);
					}
//					System.out.println(runningApps);
				} 
				catch (HPSServiceException e) 
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
