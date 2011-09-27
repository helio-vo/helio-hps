package eu.heliovo.hps.client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Vector;

import javax.xml.ws.BindingProvider;
import javax.xml.ws.WebFault;

import eu.heliovo.hps.server.AbstractApplicationDescription;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceException;
import eu.heliovo.hps.server.HPSServiceService;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceClientDemo 
{
	/*
	 * Various utilities
	 */
	LogUtilities		logUtilities	=	new LogUtilities();
	/*
	 * Data regarding applications present on the HPS
	 */
	Vector<AbstractApplicationDescription>		presentApplications		=	new Vector<AbstractApplicationDescription>();
	/*
	 * Data regarding applications running on the HPS
	 */
	Vector<String>								runningApplications		=	new Vector<String>();
	/*
	 * The Service Stubs
	 */
	HPSServiceService	hpsSS			=	new HPSServiceService();
//	String				serviceAddress	=	"http://localhost:8080/helio-hps-server/hpsService";
	String  			serviceAddress	=	"http://cagnode58.cs.tcd.ie:8080/helio-hps-server/hpsService";

	public static void main(String[] args) 
	{
		HPSServiceClientDemo	demoHPS	=	new HPSServiceClientDemo();
		demoHPS.runUI();
	}
		
	private void runUI() 
	{
		boolean terminate	=	false;
		
		while (!terminate) 
		{
			System.out.println();
			System.out.println(" * Please Select the action you want to perform : ");
			System.out.println("----------------------------------------------------------------------------");					
			System.out.println(" * [0] - Test if the hps is running");
			System.out.println(" * [1] - List the applications present in the HPS");
			System.out.println(" * [2] - Select a job to run ");
			System.out.println(" * [3] - Run a test application on the grid");
			System.out.println(" * [4] - Run a test application on the computational cache");
			System.out.println(" * [5] - Check execution status ");
			System.out.println(" * [6] - Retrieve output of a completed application ");
			System.out.println(" * [X] - Exit ");
			System.out.println("----------------------------------------------------------------------------");					
			System.out.print(" * Please enter the corresponding key: ");

			String key = null;
			InputStreamReader reader = new InputStreamReader(System.in);
			BufferedReader in = new BufferedReader(reader);

			try 
			{
				key = in.readLine();
			} 
			catch (IOException e) 
			{
				e.printStackTrace();
			}
			System.out.println();

			if (key.equals("0") 
					|| key.equals("1") 
					|| key.equals("2")
					|| key.equals("3") 
					|| key.equals("4") 
					|| key.equals("5") 
					|| key.equals("6") 
					|| key.equals("X")) 
			{
				if (key.equals("0")) 
				{
					try 
					{
						performSimpleTest();
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
					}					
				} 
				if (key.equals("1")) 
				{
					try 
					{
						getApplicationList();
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
					}					
				} 
				else if (key.equals("2")) 
				{
					try 
					{
						selectAndSubmitApplication();
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
					}					

				} 				
				if (key.equals("3")) 
				{
					try 
					{
						submitTestOnGrid();
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
					}					
				} 
				if (key.equals("4")) 
				{
					try 
					{
						submitTestOnMiniGrid();
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
					}					
				} 
				if (key.equals("5")) 
				{
					try 
					{
						checkExecutionStatus();
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
					}					
				} 
				if (key.equals("6")) 
				{
					try 
					{
						retrieveExecutionOutput();
					} 
					catch (Exception e) 
					{
						e.printStackTrace();
					}					
				} 
				else if (key.equals("X")) 
				{
					logUtilities.printShortLogEntry("Quitting...");
					terminate = true;
				}
			}
			else
				logUtilities.printShortLogEntry("Your selection ["+key+"] is not valid, please selec a new one...");
				
			logUtilities.printShortLogEntry("... done");
		}
	}

	
	private void retrieveExecutionOutput() 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		
		logUtilities.printShortLogEntry("Retrieving the output of an application from the hps...");
		logUtilities.printShortLogEntry("-------------------------------------------------------");

		Vector<String>	completedApplications 	=	new	Vector<String>();
		
		int index = 0;
		for(index = 0; index < runningApplications.size(); index ++)
		{
			String 	currId		=	runningApplications.get(index);
			String	currStatus	=	hpsService.getStatusOfExecution(currId);
			/*
			 * TODO : This works only if you have keep both stata
			 */
			if(currStatus.contains("submission-status"))
				completedApplications.add(currId);			

//			if(currStatus.equals(ApplicationExecutionsStates.COMPLETED))
//				completedApplications.add(currId);
//			if(currStatus.contains("Done (Success)"))
//				completedApplications.add(currId);			
		}
		for(index = 0; index < completedApplications.size(); index ++)
		{
			String 	currId		=	completedApplications.get(index);
			String	currStatus	=	completedApplications.get(index);
			System.out.println(" * [" + index + "] - [" + currId + "] --> " + currStatus);
		}
		
		String key = null;
		InputStreamReader reader = new InputStreamReader(System.in);
		BufferedReader in = new BufferedReader(reader);

		System.out.print(" * Please enter the corresponding key: ");
		try 
		{
			key = in.readLine();
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
		}
		System.out.println();
		String 	selectedId	=	null;
		
		int keyNum = new Integer(key);		
		if (keyNum < 0 || keyNum > index)
			System.out.println(" * Sorry, " + key + " is not a valid menu voice, try again.");
		else 
		{
			try 
			{

			selectedId	=	completedApplications.get(keyNum);
			System.out.println(" * You have selected to retrieve the output of " + selectedId);
			System.out.println(" * The output of " + selectedId + " is available at : " + hpsService.getOutputOfExecution(selectedId));
			} 
			catch (Exception e) 
			{
				e.printStackTrace();
			}
		}			
		logUtilities.printShortLogEntry("-------------------------------------------------------");
		logUtilities.printShortLogEntry("... done");		
	}

	private void checkExecutionStatus() throws Exception 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		logUtilities.printShortLogEntry("Checking the execution status of the applications running on the hps...");
		logUtilities.printShortLogEntry("-----------------------------------------------------------------------");

		for(int index = 0; index < runningApplications.size(); index ++)
		{
			String 	currId		=	runningApplications.get(index);
			String	currStatus	=	hpsService.getStatusOfExecution(currId);
			System.out.println("[" + currId + "] --> " + currStatus);
		}

		logUtilities.printShortLogEntry("-----------------------------------------------------------------------");
		logUtilities.printShortLogEntry("... done");		
	}

	
	private void selectAndSubmitApplication() 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		
		logUtilities.printShortLogEntry("Selecting and running an application on the hps...");
		logUtilities.printShortLogEntry("--------------------------------------------------");

		Boolean							fastExecution	=	true;
		int								numJobs			=	1;
		AbstractApplicationDescription	app				= 	null;
		String 							key 			= 	null;
		String							executionId		=	null;
		InputStreamReader 				reader 			=	new InputStreamReader(System.in);
		BufferedReader 					in 				= 	new BufferedReader(reader);

		try 
		{
			/*
			 * Select an application 
			 */
			Vector<AbstractApplicationDescription> res = new Vector<AbstractApplicationDescription>();
			res.addAll(hpsService.getPresentApplications());

			System.out.println(" * Please Select one application by selecting the corresponding key : ");

			int	index	=	0;

			for(index = 0; index < res.size(); index ++)
			{
				System.out.println(" * [" + index + "] "
						+	res.get(index).getName() + " "
						+ 	res.get(index).getDescription());
				
			}
			
			System.out.print(" * Please enter the corresponding key: ");
			key = in.readLine();
			System.out.println();

			int keyNum = new Integer(key);
			app	=	res.get(keyNum);
			
			if (keyNum < 0 || keyNum > index)
				System.out.println(" * Sorry, " + key
						+ " is not a valid menu voice, try again.");
			else {
				System.out.println(" * You have selected " + app.getName());
			}
		
			/*
			 * Select parameters 
			 */
			for(int currParam = 0; currParam < app.getParameters().size(); currParam++)
			{
				System.out.println(" * " + app.getDescription());
				System.out.print(" * Enter value for " + 
						app.getParameters().get(currParam).getName() + " [" +
						app.getParameters().get(currParam).getType() + "] : ");
				key = in.readLine();
				System.out.println();
				app.getParameters().get(currParam).setValue(key);
			}	
			
			/*
			 * Select computational resource 
			 */

			System.out.println(" * Please Select one Computational Resource by selecting the corresponding key : ");
			System.out.println(" * [0] - Grid Resource (5 Minutes of overhead for submission but supports up to 100 parallel jobs of 3 weeks max duration) ");
			System.out.println(" * [1] - Lightweight Resource (No overhead for submission but supports only up to 4 parallel jobs of 10 minutes max duration) ");		
			System.out.print(" * Please enter the corresponding key: ");
			key = in.readLine();
			System.out.println();

			
			if (key.equals("0") || key.equals("1"))
			{
				System.out.print(" * You have selected to execute " + app.getDescription() + " on ");
				if(key.equals("0"))
				{
					System.out.println("the Grid");
					fastExecution 	= 	false;
					numJobs			=	1;
				}
				if(key.equals("1"))
				{
					System.out.println("the Lightweight Resource");
					fastExecution 	= 	true;
					numJobs			=	1;
				}	
			}
			else 
			{
				System.out.println(" * Sorry, " + key + " is not a valid menu voice, try again.");		
			}
			executionId = hpsService.executeApplication(app, fastExecution , numJobs);
			runningApplications.add(executionId);

			System.out.println(" * " + app.getDescription() + " is being executed with execution ID " + executionId);
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
		
		logUtilities.printShortLogEntry("--------------------------------------------------");
		logUtilities.printShortLogEntry("... done");		
	}

	
	private void submitTestOnMiniGrid() throws Exception 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		logUtilities.printShortLogEntry("Running a simple test application on the minigrid...");
		logUtilities.printShortLogEntry("----------------------------------------------------");
		/*
		 * Select an application to run
		 */
		AbstractApplicationDescription	selectedApp	=	selectStandardApplication();
		System.out.println(" *  The following application will be executed ");
		System.out.println(" * " + selectedApp.getDescription());
		/*
		 * Submit the application
		 */
		String executionId = hpsService.executeApplication(selectedApp, true, 1);
		System.out.println(" * " + selectedApp.getName() + " is running under " + executionId + " id");
		/*
		 * 
		 */
		logUtilities.printShortLogEntry("-----------------------------------------------");
		logUtilities.printShortLogEntry("... done");		
	}

	private AbstractApplicationDescription selectStandardApplication() 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		
		Vector<AbstractApplicationDescription> res = new Vector<AbstractApplicationDescription>();
		res.addAll(hpsService.getPresentApplications());
		AbstractApplicationDescription	selectedApp	=	res.get(0);		
		selectedApp.getParameters().get(0).setValue("http://cdaweb.gsfc.nasa.gov/sp_phys/data/ace/cris_h2/2003/ac_h2_cris_20030101_v05.cdf");
		selectedApp.getParameters().get(1).setValue("http://cdaweb.gsfc.nasa.gov/sp_phys/data/ace/sep_h2/2003/ac_h2_sep_20030101_v04.cdf");
		return selectedApp;
	}

	private void submitTestOnGrid() throws Exception 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		
		logUtilities.printShortLogEntry("Running a test application on the grid ...");
		logUtilities.printShortLogEntry("------------------------------------------");
		/*
		 * Select an application to run
		 */
		AbstractApplicationDescription	selectedApp	=	selectStandardApplication();
		System.out.println(" *  The following application will be executed ");
		System.out.println(" * " + selectedApp.getDescription());
		/*
		 * Submit the application
		 */
		String executionId = hpsService.executeApplication(selectedApp, false, 1);
		System.out.println(" * " + selectedApp.getName() + " is running under " + executionId + " id");
		/*
		 * 
		 */
		logUtilities.printShortLogEntry("-----------------------------------------------");
		logUtilities.printShortLogEntry("... done");		
	}

	
	private void getApplicationList() 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		logUtilities.printShortLogEntry("Getting the list of present applications on the HPS");
		presentApplications.clear();
		presentApplications.addAll(hpsService.getPresentApplications());
		System.out.println("There are " + presentApplications.size() + " applications in the HPS");					
		System.out.println("----------------------------------------------------------------------------");					
		for(int n=0; n < presentApplications.size(); n++)		
		{
			System.out.println("[" + n + "] - " + presentApplications.get(n).getDescription());			
		}
		System.out.println("----------------------------------------------------------------------------");			
	}

	private void performSimpleTest() 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		logUtilities.printShortLogEntry("Invoking test on the HPS...");
		logUtilities.printShortLogEntry(hpsService.test("Hello there !!"));
		logUtilities.printShortLogEntry("...done");
	}
}
