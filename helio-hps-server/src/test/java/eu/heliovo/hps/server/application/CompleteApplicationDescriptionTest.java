package eu.heliovo.hps.server.application;

import static org.junit.Assert.*;

import org.junit.Test;

public class CompleteApplicationDescriptionTest 
{
	@Test
	public void testTest() 
	{
		CompleteApplicationDescription	cd	=	new CompleteApplicationDescription();
		
		cd.setName("test");
		cd.setDescription("Test Application");
		cd.setLocation("location");
		cd.setExeFile("exeFile");
		cd.setJdlFile("jdlFile");
		cd.setParameters(null);
		
		AbstractApplicationDescription	ad	=	(AbstractApplicationDescription)cd;
		System.out.println(ad.getName());
		System.out.println(ad.getDescription());
		
	}
}
