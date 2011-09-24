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
		executable	=	appExeDesc.getAppDesc().getLocation() + 
		"/" +
		appExeDesc.getAppDesc().getExeFile();
		/*
		 * Adding the parameters to the executable...
		 */
		int	numOfArgs	=			appExeDesc.getAppDesc().getParameters().size();
		for(int currArg = 0; currArg < numOfArgs; currArg++)
		{
			String arg = appExeDesc.getAppDesc().getParameters().get(currArg).getValue();			
			logUtilities.printLongLogEntry("["+currArg+"]="+arg);			
			executable += " " + arg;
			logUtilities.printLongLogEntry("executable = "+executable);			
		}
		logFile		=	"/tmp/logFile.txt";
	}

	@Override
	public void run() 
	{		
		try 
		{
//			logUtilities.printLongLogEntry("Executing the scripts with the new method...");
//			String[]	commands	=	{"pwd", "cd /tmp", "pwd", executable};
//			logUtilities.printLongLogEntry(sysUtilities.sysExec(commands));
//			logUtilities.printLongLogEntry("...done");
			logUtilities.printLongLogEntry("Executing the scripts with the old method...");
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
