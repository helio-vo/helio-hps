package eu.heliovo.hps.client;

import java.util.Vector;

import javax.xml.ws.BindingProvider;

import eu.heliovo.hps.server.AbstractApplicationDescription;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceService;
import eu.heliovo.shared.common.utilities.LogUtilities;

public class HPSServiceClientDemoOld 
{
	/*
	 * Various utilities
	 */
	LogUtilities		logUtilities	=	new LogUtilities();
	/*
	 * Data regarding applications
	 */
	Vector<AbstractApplicationDescription>		presentApplications		=	new Vector<AbstractApplicationDescription>();

//	HPSServiceImpl		hpsSI	=	new HPSServiceImpl();
	HPSServiceService	hpsSS	=	new HPSServiceService();

	public static void main(String[] args) 
	{
		HPSServiceClientDemoOld	demoHPS	=	new HPSServiceClientDemoOld();
		demoHPS.perform();
	}

	
	
	
	private void perform() 
	{	
		HPSService	hpsService	=	hpsSS.getHPSServicePort();

		((BindingProvider)hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
				"http://localhost:8080/helio-hps-server/hpsService");
//				"http://cagnode58.cs.tcd.ie:8080/helio-example-server/exampleService");

		System.out.println(hpsService.test("Hello there !!"));

		
		
		logUtilities.printShortLogEntry("Getting the list of present applications on the HPS");
		presentApplications.addAll(hpsService.getPresentApplications());
		System.out.println("There are " + presentApplications.size() + " applications in the HPS");					
		System.out.println("----------------------------------------------------------------------------");					
		for(int n=0; n < presentApplications.size(); n++)		
		{
			System.out.println("[" + n + "] - " + presentApplications.get(n).getDescription());			
		}
		System.out.println("----------------------------------------------------------------------------");			
	}
}
