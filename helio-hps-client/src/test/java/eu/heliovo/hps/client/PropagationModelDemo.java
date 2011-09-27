package eu.heliovo.hps.client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Vector;

import javax.xml.ws.BindingProvider;
import javax.xml.ws.WebFault;

import eu.heliovo.hps.server.AbstractApplicationDescription;
import eu.heliovo.hps.server.ApplicationExecutionStatus;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceException;
import eu.heliovo.hps.server.HPSServiceService;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class PropagationModelDemo 
{
	/*
	 * Various utilities
	 */
	LogUtilities		logUtilities	=	new LogUtilities();
	/*
	 * The Service Stubs
	 */
	HPSServiceService	hpsSS			=	new HPSServiceService();
//	String				serviceAddress	=	"http://localhost:8080/helio-hps-server/hpsService";
	String  			serviceAddress	=	"http://cagnode58.cs.tcd.ie:8080/helio-hps-server/hpsService";

	public static void main(String[] args) 
	{
		PropagationModelDemo	pmDemo	=	new PropagationModelDemo();
		pmDemo.runPropagationModel();
	}
		
	private void runPropagationModel() 
	{
		HPSService	hpsService	=	hpsSS.getHPSServicePort();
		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				serviceAddress);

		Boolean							fastExecution	=	true;
		int								numJobs			=	1;
		AbstractApplicationDescription	app				= 	null;
		String 							key 			= 	null;
		String							exeId			=	null;
		String							exeStatus		=	null;
		String							exeOutput		=	null;
		InputStreamReader 				reader 			=	new InputStreamReader(System.in);
		BufferedReader 					in 				= 	new BufferedReader(reader);

		try 
		{
			/*
			 * Retrieve the application list and select the propagation model. 
			 */
			Vector<AbstractApplicationDescription> res = new Vector<AbstractApplicationDescription>();
			res.addAll(hpsService.getPresentApplications());
			app	=	res.get(0);		
			/*
			 * Select parameters 
			 */
			for(int currParam = 0; currParam < app.getParameters().size(); currParam++)
			{
				System.out.print(" * Enter value for " + 
						app.getParameters().get(currParam).getName() + " [" +
						app.getParameters().get(currParam).getType() + "] : ");
				key = in.readLine();
//				System.out.println();
				app.getParameters().get(currParam).setValue(key);
			}	
			exeId = hpsService.executeApplication(app, fastExecution , numJobs);
			logUtilities.printShortLogEntry(app.getName() + " is being executed with execution ID " + exeId);
			/*
			 * Wait until the application is completed
			 */
			
			exeStatus = hpsService.getStatusOfExecution(exeId);
			logUtilities.printShortLogEntry(exeId + " --> " + exeStatus);
			while(!exeStatus.equals(ApplicationExecutionStatus.Completed))
			{
				exeStatus = hpsService.getStatusOfExecution(exeId);
				logUtilities.printShortLogEntry(exeId + " --> " + exeStatus);
				Thread.sleep(1000);
			}
//			/*
//			 * If the application is completed, retrieve the output and
//			 * remove from the list of running applications
//			 */
//			if (exeStatus.equals(ApplicationExecutionStatus.Completed)) 
//			{
//				logUtilities.printShortLogEntry(exeId + " --> " + hpsService.getOutputOfExecution(exeId));
//			}
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
}
