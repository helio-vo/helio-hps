package eu.heliovo.hps.client;

import javax.xml.ws.BindingProvider;

//import eu.heliovo.hps.server.HPSServiceImpl;
//import eu.heliovo.hps.server.HPSServiceImplPortType;

public class HPSServiceClientDemoBad 
{
//	HPSServiceImpl	hpsSI	=	new HPSServiceImpl();
	
	public static void main(String[] args) 
	{
		HPSServiceClientDemoBad	demoHPS	=	new HPSServiceClientDemoBad();
		demoHPS.perform();
	}

	private void perform() 
	{		
//		HPSServiceImplPortType	hpsService	=	hpsSI.getHPSServiceImplPort();
//
//		((BindingProvider)hpsService).getRequestContext().put(
//				BindingProvider.ENDPOINT_ADDRESS_PROPERTY,
//				"http://localhost:8080/helio-hps-server/hpsService");
////				"http://cagnode58.cs.tcd.ie:8080/helio-hps-server/hpsService");
//
//		System.out.println(hpsService.test("Hello there !!"));
	}
}
