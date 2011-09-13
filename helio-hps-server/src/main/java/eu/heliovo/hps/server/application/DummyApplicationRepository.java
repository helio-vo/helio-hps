package eu.heliovo.hps.server.application;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

public class DummyApplicationRepository implements ApplicationRepository 
{
	Map<String, AbstractApplicationDescription>	applications	=	new HashMap<String, AbstractApplicationDescription>();

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
		
		applications.put("app_1", new AbstractApplicationDescription(
				"Application_1", 
				"app_1",
				"Description of application 1",
				params));
		applications.put("app_2", new AbstractApplicationDescription(
				"Application_2", 
				"app_2",
				"Description of application 2",
				params));
		applications.put("app_3", new AbstractApplicationDescription(
				"Application_3", 
				"app_3",
				"Description of application 3, This actually is the only active application",
				params));
	}

	/* (non-Javadoc)
	 * @see eu.heliovo.hps.server.application.ApplicationRepository#getPresentApplications()
	 */
	@Override
	public Collection<AbstractApplicationDescription> getPresentApplications() 
	{
		return applications.values();
	}
	
	/* (non-Javadoc)
	 * @see eu.heliovo.hps.server.application.ApplicationRepository#getApplication(java.lang.String)
	 */
	@Override
	public AbstractApplicationDescription	getApplication(String appId)
	{
		return applications.get(appId);
	}
}
