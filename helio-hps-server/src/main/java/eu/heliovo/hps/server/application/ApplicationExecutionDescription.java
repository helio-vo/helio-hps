package eu.heliovo.hps.server.application;

import java.util.Date;

import eu.heliovo.hps.server.ApplicationExecutionStatus;

public class ApplicationExecutionDescription 
{
	CompleteApplicationDescription	appDesc				=	null;
	boolean							fastExecution		=	true;
	int								numParallelJobs		=	-1;
	String							appExeId			=	null;
	String							status				=	ApplicationExecutionStatus.Undefined;
	String							resource			=	null;
	Date							startedOn			=	null;
	
	public ApplicationExecutionDescription(
			CompleteApplicationDescription app,
			Boolean fastExecution, 
			int numParallelJobs) 
	{
		this.appDesc			=	app;
		this.fastExecution		=	fastExecution;
		this.numParallelJobs	=	numParallelJobs;
	
		this.status		=	ApplicationExecutionStatus.Running;
		this.startedOn	=	new Date();
	}

	public ApplicationExecutionDescription(
			CompleteApplicationDescription appDesc, 
			boolean fastExecution,
			int numParallelJobs, 
			String appExeId, 
			String resource) 
	{
		super();
		this.appDesc = appDesc;
		this.fastExecution = fastExecution;
		this.numParallelJobs = numParallelJobs;
		this.appExeId = appExeId;
		this.resource = resource;
		
		this.status		=	ApplicationExecutionStatus.Running;
		this.startedOn	=	new Date();
	}

	public String getAppExeId() {
		return appExeId;
	}

	public void setAppExeId(String appExeId) {
		this.appExeId = appExeId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getResource() {
		return resource;
	}

	public void setResource(String resource) {
		this.resource = resource;
	}

	public Date getStartedOn() {
		return startedOn;
	}

	@Override
	public String toString() 
	{
		return this.appExeId + " --> " + this.status;
	}	
}
