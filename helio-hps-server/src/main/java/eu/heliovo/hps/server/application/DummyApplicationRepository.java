package eu.heliovo.hps.server.application;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Vector;

public class DummyApplicationRepository implements ApplicationRepository 
{
	Map<String, CompleteApplicationDescription>	applications	=	new HashMap<String, CompleteApplicationDescription>();

	public DummyApplicationRepository() 
	{
		super();
		initialize();
	}

	protected void initialize() 
	{
		/*
		 * This is the first prototype of the propagation model.
		 */
		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("CME's starting time", "String", "UNDEFINED", "2011-09-11T23:00"));
		params.add(new ApplicationParameter("CME's starting point", "Float", "UNDEFINED", "25.00"));
		params.add(new ApplicationParameter("CME's starting width", "Float", "UNDEFINED", "10.00"));
		params.add(new ApplicationParameter("CME's starting speed", "Float", "UNDEFINED", "500.00"));
		
		applications.put("pm_1", new CompleteApplicationDescription(
				"Propagation Model (First Prototype)", 
				"pm_1",
				"The first prototype of the Propagation Model",
				params,
				"/usr/local/helio/applications/pm_1",
				"pm_1.sh",
				"pm_1.jdl"
				));		

		/*
		 * This is the first prototype of the file archival utility.
		 */
		params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("File 1", "String", "UNDEFINED", "http://cdaweb.gsfc.nasa.gov/sp_phys/data/ace/cris_h2/2003/ac_h2_cris_20030101_v05.cdf"));
		params.add(new ApplicationParameter("File 2", "String", "UNDEFINED", "http://cdaweb.gsfc.nasa.gov/sp_phys/data/ace/cris_h2/2003/ac_h2_cris_20030101_v05.cdf"));
		
		applications.put("fa_1", new CompleteApplicationDescription(
				"File Archiver (First Prototype)", 
				"fa_1",
				"The first prototype of the File Archiver",
				params,
				"/usr/local/helio/applications/fa_1",
				"fa_1.sh",
				"fa_1.jdl"
				));		
//		/*
//		 * This is just for prototyping
//		 */
//		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
//		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED", "Gab"));
//		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED", "Nasik"));
//		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED", "7.12"));
//		
//		applications.put("app_1", new CompleteApplicationDescription(
//				"Application_1", 
//				"app_1",
//				"Description of application 1",
//				params,
//				"/usr/local/helio/applications/app_1",
//				"app_1.sh",
//				"app_1.jdl"
//				));
//		applications.put("app_2", new CompleteApplicationDescription(
//				"Application_2", 
//				"app_2",
//				"Description of application 2",
//				params,
//				"location",
//				"exeFile",
//				"jdlFile"
//				));
//		applications.put("app_3", new CompleteApplicationDescription(
//				"Application_3", 
//				"app_3",
//				"Description of application 3, This actually is the only active application",
//				params,
//				"location",
//				"exeFile",
//				"jdlFile"
//				));
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.server.application.ApplicationRepository#getPresentApplications()
	 */
	@Override
	public Collection<AbstractApplicationDescription> getPresentApplications() 
	{
		Collection<AbstractApplicationDescription>	result =	new ArrayList<AbstractApplicationDescription>();
		
		Iterator<CompleteApplicationDescription>	iter	=	applications.values().iterator();
	
		while(iter.hasNext())
			result.add(iter.next());
		
		return result;
	}
	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.server.application.ApplicationRepository#getApplication(java.lang.String)
	 */
	@Override
	public AbstractApplicationDescription	getApplication(String appId)
	{
		return (AbstractApplicationDescription) applications.get(appId);
	}

	@Override
	public CompleteApplicationDescription getApplicationCompleteDescription	(AbstractApplicationDescription app) 
	{
		/*
		 * TODO : Remove comments
		 */
		/*
		 * Extract the description from the map and add the newly set parameters
		 */
		CompleteApplicationDescription	res	=	applications.get(app.getId());
		res.setParameters(app.getParameters());	
//		System.out.println(" **** " + applications.get(app.getId()).getFullDescription());		
//		System.out.println(" **** Type returned is " + applications.get(app.getId()).getClass());
//		System.out.println(" **** Argument returned is " + applications.get(app.getId()).getParameters());
		/*
		 * Now set the parameters
		 */
		return res;
	}
}
