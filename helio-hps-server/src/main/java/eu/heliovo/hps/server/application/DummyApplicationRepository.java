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
		 * This is just for prototyping
		 */
		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED", "Gab"));
		params.add(new ApplicationParameter("param_b", "String", "UNDEFINED", "Nasik"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED", "7.12"));
		
		applications.put("app_1", new CompleteApplicationDescription(
				"Application_1", 
				"app_1",
				"Description of application 1",
				params,
				"location",
				"exeFile",
				"jdlFile"
				));
		applications.put("app_2", new CompleteApplicationDescription(
				"Application_2", 
				"app_2",
				"Description of application 2",
				params,
				"location",
				"exeFile",
				"jdlFile"
				));
		applications.put("app_3", new CompleteApplicationDescription(
				"Application_3", 
				"app_3",
				"Description of application 3, This actually is the only active application",
				params,
				"location",
				"exeFile",
				"jdlFile"
				));
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
	public CompleteApplicationDescription getApplicationCompleteDescription	(		
			String appId) 
	{
		return applications.get(appId);
	}
}
