package eu.heliovo.hps.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Vector;

import eu.heliovo.hps.server.application.AbstractApplicationDescription;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceImplDemo 
{
	/*
	 * The HPS Service
	 */
	HPSService		hpsService				=	new HPSServiceImpl();
	/*
	 * Various Utilities
	 */
	LogUtilities	logUtilities			=	new LogUtilities();
	/*
	 * Data regarding applications
	 */
	Vector<AbstractApplicationDescription>		presentApplications		=	new Vector<AbstractApplicationDescription>();
	
	public static void main(String[] args) 
	{
		HPSServiceImplDemo		demo		=	new HPSServiceImplDemo();
		demo.perform();
	}

	private void perform() 
	{		
		runUI();
//		performTest();
//		performGetPresentApplications();
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
//			System.out.println(" * [0] - Run a simple test job on the grid");
//			System.out.println(" * [1] - Run a simple test job on the computational cache");
//			System.out.println(" * [2] - Select a job to run ");
//			System.out.println(" * [3] - Check execution status ");
//			System.out.println(" * [4] - Retrieve Output of Application ");
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
//					|| key.equals("2")
//					|| key.equals("3") 
//					|| key.equals("4") 
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
//				else if (key.equals("2")) 
//				{
//					logUtilities.printShortLogEntry("Selecting and running an application on the hps...");
//					try 
//					{
//						selectAndSubmitApplication(local);
//					} 
//					catch (Exception e) 
//					{
//						e.printStackTrace();
//					}					
//
//				} 
//				else if (key.equals("3")) 
//				{
//					try 
//					{
//						checkExecutionStatus(local);
//					} 
//					catch (Exception e) 
//					{
//						e.printStackTrace();
//					}					
//
//				} 
//				else if (key.equals("4")) 
//				{
//					try 
//					{
//						retrieveExecutionOutput(local);
//					} 
//					catch (Exception e) 
//					{
//						e.printStackTrace();
//					}					
//
//				} 
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


	private void getApplicationList() 
	{
		logUtilities.printShortLogEntry("Getting the list of present applications on the HPS");
		presentApplications.addAll(hpsService.getPresentApplications());
		System.out.println("----------------------------------------------------------------------------");					
		for(int n=0; n < presentApplications.size(); n++)		
		{
			System.out.println("[" + n + "] - " + presentApplications.get(n).getDescription());			
		}
		System.out.println("----------------------------------------------------------------------------");			
	}

	private void performSimpleTest() 
	{
		logUtilities.printShortLogEntry("Executing test on hps...");
		hpsService.test("parameter");
		logUtilities.printShortLogEntry("...done");			
	}


//	private void performTest() 
//	{
//		logUtilities.printShortLogEntry("Executing test on hps...");
//		hpsService.test("parameter");
//		logUtilities.printShortLogEntry("...done");		
//	}	
}
