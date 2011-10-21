package eu.heliovo.hps.server.processing.fast;

import java.io.File;
import java.io.IOException;

import eu.heliovo.hps.server.application.ApplicationExecutionDescription;
import eu.heliovo.hps.server.utilities.RandomUtilities;
import eu.heliovo.shared.common.utilities.LogUtilities;
import eu.heliovo.shared.common.utilities.SystemUtilities;

public class SimpleScriptController extends Thread
{
	/*
	 * Various Utilities
	 */
	LogUtilities					logUtilities	=	new LogUtilities();
	RandomUtilities					rndUtilities	=	new RandomUtilities();
	SystemUtilities					sysUtilities	=	new SystemUtilities();
	/*
	 * The execution description
	 */
	ApplicationExecutionDescription	appExeDesc		=	null;
	/*
	 * The full path to the executable
	 */
	String							executable		=	null;
	/*
	 * The full path to the log file
	 */
	String							logFile			=	null;
	String							output			=	null;

	public void setAppExeDesc(ApplicationExecutionDescription appExeDesc) 
	{
		this.appExeDesc = appExeDesc;

//		System.out.println(" **** SimpleScriptController - parameters are " + appExeDesc.getAppDesc().getParameters());

		executable	=	appExeDesc.getAppDesc().getLocation() + 
		"/" +
		appExeDesc.getAppDesc().getExeFile();
//		System.out.println(" **** SimpleScriptController - executable line is " + executable);
		
//		/*
//		 * Adding the parameters to the executable...
//		 */
//		executable += " 2011-09-11T23:00 25.00 10.00 500.00 /tmp/nasikon.gab.today";

		int	numOfArgs	=			appExeDesc.getAppDesc().getParameters().size();
		for(int currArg = 0; currArg < numOfArgs; currArg++)
		{
			String arg = appExeDesc.getAppDesc().getParameters().get(currArg).getValue();			
//			logUtilities.printLongLogEntry(" **** SimpleScriptController - ["+currArg+"]="+arg);			
			executable += " " + arg;
//			logUtilities.printLongLogEntry(" **** SimpleScriptController - executable = "+executable);			
		}
		/*
		 * Define the temporary directory where the results will be stored
		 */
		/*
		 * I changed this to reflect the changes into the scripts that DVD 
		 * implemented on 20.10.2011.
		 */
		String 	tmpDir	=	"/var/www/html/output_dir/" + appExeDesc.getAppExeId() + "/";
//		String 	tmpFile	=	tmpDir + "/" + appExeDesc.getAppExeId();
		/*
		 * Create the temporary directory...
		 */
		sysUtilities.sysExec("mkdir " + tmpDir);
		/*
		 * Add the tmp dir to the parameters for saving the output
		 */
		executable += " " + tmpDir;		
//		System.out.println(" **** SimpleScriptController - executable line is " + executable);
	}

	@Override
	public void run() 
	{		
		String 	tmpDir	=	"/tmp/" + appExeDesc.getAppExeId();

		try 
		{
//			logUtilities.printLongLogEntry("Executing the scripts with the new method...");
//			String[]	commands	=	{"pwd", "cd /tmp", "pwd", executable};
//			logUtilities.printLongLogEntry(sysUtilities.sysExec(commands));
//			logUtilities.printLongLogEntry("...done");
			logUtilities.printLongLogEntry("Executing " + executable + " script...");
			/*
			 * Create the temporary directory...
			 */
			sysUtilities.sysExec("mkdir " + tmpDir);
			/*
			 * Executing the script
			 */
			logUtilities.printLongLogEntry(sysUtilities.sysExec(executable));
			logUtilities.printLongLogEntry("...done");
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
	}


//	@Override
//	public void run() 
//	{		
//		ProcessBuilder	pb	=	new ProcessBuilder();
//		logUtilities.printShortLogEntry("env = " + pb.environment());
//		pb.directory(new File("/tmp"));
//		logUtilities.printShortLogEntry("pwd = " + pb.directory().getAbsolutePath());
//		logUtilities.printShortLogEntry("Thread.run() - Before invoking " + executable);		
//		pb.command(executable);
//		logUtilities.printShortLogEntry("Thread.run() - After invoking " + executable);		
//	}

//	@Override
//	public void run() 
//	{		
//		/*
//		 * Debug to understand where and how the processing is running...
//		 */
//		logUtilities.printShortLogEntry("user.dir = " + System.getProperty("user.dir"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("pwd"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("ls -la"));
//		/*
//		 * Changing directory
//		 */
//		System.setProperty("user.dir", "/tmp");  
//		logUtilities.printShortLogEntry("CD=" + System.getProperty("user.dir"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("pwd"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("ls -la"));
//
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("cd /tmp"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("pwd"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("ls -la"));
//
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("mkdir nasiks"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("ls -la"));
//
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("mkdir /tmp/nasikon"));
//		logUtilities.printShortLogEntry(sysUtilities.sysExec("ls -la"));
//
//		//		logUtilities.printShortLogEntry("Thread.run() - Before invoking " + executable);		
////		logUtilities.printLongLogEntry(sysUtilities.sysExec(executable));
////		logUtilities.printShortLogEntry("Thread.run() - After invoking " + executable);		
//
////		logUtilities.printShortLogEntry("Thread.run() - Before invoking " + executable + " > " + logFile);		
////		sysUtilities.sysExec(executable + " > " + logFile);
////		logUtilities.printShortLogEntry("Thread.run() - After invoking " + executable + " > " + logFile);		
//	}

	@Override
	public String toString() 
	{
		return getState().toString();
	}	
}
