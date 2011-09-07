package eu.heliovo.hps.server;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

import eu.heliovo.hps.utilities.RandomUtilities;
import eu.heliovo.hps.utilities.TimeUtilities;

//import eu.heliovo.shared.common.utilities.RandomUtilities;
//import eu.heliovo.shared.common.utilities.TimeUtilities;

public class HPSDummyService implements HPSService 
{
	/*
	 * This is the dummy for the application description repository
	 */
	static 	Map<String, ApplicationDescription>	applications	=	new HashMap<String, ApplicationDescription>();
	/*
	 * This is the dummy for the application execution description repository
	 */
	static	Map<String, String>					executions		=	new HashMap<String, String>();
	/*
	 * Various Utilities
	 */
	TimeUtilities		timeUtilities	=	new TimeUtilities();
	RandomUtilities		rndUtilities	=	new RandomUtilities();
	
	public HPSDummyService() 
	{
		super();
		Vector<ApplicationParameter>	params	=	new Vector<ApplicationParameter>();
		params.add(new ApplicationParameter("param_a", "String", "UNDEFINED"));
		params.add(new ApplicationParameter("param_b", "Integer", "UNDEFINED"));
		params.add(new ApplicationParameter("param_c", "Float", "UNDEFINED"));
		
		applications.put("app_1", new ApplicationDescription(
				"Application_1", 
				"app_1",
				"Description of application 1",
				"undefined",
				"undefined",				
				params));
		applications.put("app_2", new ApplicationDescription(
				"Application_2", 
				"app_2",
				"Description of application 2",
				"undefined",
				"undefined",				
				params));
		applications.put("app_3", new ApplicationDescription(
				"Application_3", 
				"app_3",
				"Description of application 3",
				"undefined",
				"undefined",				
				params));	
	}

	@Override
	public String test(String arg) 
	{
		return "Result of test performed by HPSDummyService";
	}

	@Override
	public Collection<ApplicationDescription> getPresentApplications() throws HPSServiceException 
	{
		return applications.values();
	}

	@Override
	public String getStatusOfExecution(String exeId) 
	{
		return changeStatus(exeId);
	}

	private String changeStatus(String exeId) 
	{
		String oldStatus	=	executions.get(exeId);
		String newStatus	=	oldStatus;

		if(oldStatus.equals(ApplicationExecutionsStates.RUNNING))
		{
			if(rndUtilities.getRandomBetween(0, 100) < 90)
				newStatus =  ApplicationExecutionsStates.RUNNING;
			else
				newStatus =  ApplicationExecutionsStates.COMPLETED;
		
			executions.put(exeId, newStatus);
		}
		return newStatus;
	}

	@Override
	public Boolean isRunning(String exeId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void putFile(String fileLocation, String fileContent)
			throws HPSServiceException {
		// TODO Auto-generated method stub

	}

	@Override
	public String getFile(String fileLocation) throws HPSServiceException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String executeApplication(ApplicationDescription app,
			Boolean fastExecution, int numParallelJobs)
			throws ApplicationEngineException 
	{
		String	exeId	=	createExecutionId();
		executions.put(exeId, ApplicationExecutionsStates.RUNNING);
		return 	exeId;
	}

	private String createExecutionId() 
	{
		return 	timeUtilities.getCompactStamp() 
					+ "-" + 
				String.valueOf(rndUtilities.getRandomBetween(1, 1000));
	}

	@Override
	public String getOutputOfExecution(String exeId) throws HPSServiceException 
	{
		return "http://cagnode58.cs.tcd.ie:80/tmp/"+exeId;
	}
}
