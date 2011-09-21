package eu.heliovo.hps.server;

import static org.junit.Assert.*;

import java.util.Collection;
import java.util.Vector;

import org.junit.Ignore;
import org.junit.Test;

import eu.heliovo.hps.server.application.AbstractApplicationDescription;
import eu.heliovo.hps.server.application.ApplicationParameter;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceImplTest 
{
	HPSService		hpsService		=	new HPSServiceImpl();
	LogUtilities	logUtilities	=	new LogUtilities();

	@Ignore @Test
	public void testTest() 
	{
		String	arg	=	"Test Argument";
		
		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.test("+arg+")...");
		assertNotNull(hpsService.test(arg));
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore @Test
	public void testGetPresentApplications() 
	{
		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.getPresentApplications(...)...");
		assertNotNull(hpsService.getPresentApplications());
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore @Test
	public void testExecuteApplication() 
	{
		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED", "Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED", "Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED", "7.12"));
		AbstractApplicationDescription app =	new	AbstractApplicationDescription(
				"Application_1", 
				"app_1",
				"Description of application 1",
				params);
		
		
		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.getPresentApplications(...)...");
		try 
		{
			Object	exeId	=	hpsService.executeApplication(app, true, 1);
			assertNotNull(exeId);
			assertTrue(exeId.getClass().equals(String.class));
		} 
		catch (HPSServiceException e) 
		{
			assertTrue(false);
		}
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore @Test
	public void testGetStatusOfExecution() 
	{
		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED", "Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED", "Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED", "7.12"));
		AbstractApplicationDescription app =	new	AbstractApplicationDescription(
				"Application_1", 
				"app_1",
				"Description of application 1",
				params);
				
		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.getStatusOfExecution(...)...");
		try 
		{
			Object	exeId	=	hpsService.executeApplication(app, true, 1);
			assertNotNull(exeId);
			assertTrue(exeId.getClass().equals(String.class));
			assertTrue(hpsService.getStatusOfExecution((String)exeId).equals(ApplicationExecutionStatus.Running));
		} 
		catch (HPSServiceException e) 
		{
			assertTrue(false);
		}
		logUtilities.printShortLogEntry("... done");
	}

	@Ignore @Test
	public void testGetOutputOfExecution() 
	{
		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED", "Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED", "Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED", "7.12"));
		AbstractApplicationDescription app =	new	AbstractApplicationDescription(
				"Application_1", 
				"app_1",
				"Description of application 1",
				params);
				
		logUtilities.printShortLogEntry("Invoking HPSServiceImpl.getOutputOfExecution(...)...");
		try 
		{
			Object	exeId	=	hpsService.executeApplication(app, true, 1);
			assertNotNull(exeId);
			assertTrue(exeId.getClass().equals(String.class));
			assertNotNull(hpsService.getOutputOfExecution((String)exeId));
		} 
		catch (HPSServiceException e) 
		{
			assertTrue(false);
		}
		logUtilities.printShortLogEntry("... done");
	}

	@Test
	public void testExecuteApplications() 
	{
		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED", "Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED", "Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED", "7.12"));
		AbstractApplicationDescription app =	new	AbstractApplicationDescription(
				"Application_1", 
				"app_1",
				"Description of application 1",
				params);
				
		logUtilities.printShortLogEntry("Testing the execution of a sample application on the HPS...");
		try 
		{
			String	exeId	=	hpsService.executeApplication(app, true, 1);
			logUtilities.printShortLogEntry(app.getDescription() + " running on the HPS with execution id " + exeId);
			assertNotNull(exeId);
			/*
			 * TODO : Wait here until the application has run succesfully
			 */
			String	exeStatus = hpsService.getStatusOfExecution(exeId);
			assertNotNull(exeStatus);
			logUtilities.printShortLogEntry(exeId + " is in status " + exeStatus);

			String	exeOutput	=	hpsService.getOutputOfExecution(exeId);
			assertNotNull(exeOutput);
			logUtilities.printShortLogEntry(exeId + " output is available in " + exeOutput);
		} 
		catch (HPSServiceException e) 
		{
			assertTrue(false);
		}
		logUtilities.printShortLogEntry("... done");
	}
}
