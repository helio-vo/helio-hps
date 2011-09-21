package eu.heliovo.hps.server.application;

import java.util.Vector;

public class CompleteApplicationDescription extends AbstractApplicationDescription
{
	/*
	 * These are fields that pertain the concrete application
	 */
	String							location;
	String							exeFile;
	String							jdlFile;
	
	public CompleteApplicationDescription() 
	{
		super();
		this.location 			= 	"undefined";
		this.exeFile 			= 	"undefined";
		this.jdlFile 			= 	"undefined";
	}
	
	public CompleteApplicationDescription(
			String 	name, 
			String	id,
			String 	description,
			String	location,
			String	exeFile,
			String	jdlFile
			) 
	{
		super(name, id, description);
		this.location 			= 	location;
		this.exeFile 			= 	exeFile;
		this.jdlFile 			= 	jdlFile;
	}
	
	public CompleteApplicationDescription(String name, 
			String	id,
			String description,
			Vector<ApplicationParameter> parameters,
			String	location,
			String	exeFile,
			String	jdlFile
			)
	{
		super(name, id, description, parameters);
		this.location 			= 	location;
		this.exeFile 			= 	exeFile;
		this.jdlFile 			= 	jdlFile;
	}

	
	
	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getExeFile() {
		return exeFile;
	}

	public void setExeFile(String exeFile) {
		this.exeFile = exeFile;
	}

	public String getJdlFile() {
		return jdlFile;
	}

	public void setJdlFile(String jdlFile) {
		this.jdlFile = jdlFile;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() 
	{
		String	res		=	super.toString();
		res		+=		"[";
		res		+=		location;
		res		+=		",";
		res		+=		exeFile;
		res		+=		",";
		res		+=		jdlFile;
		res		+=		"]";
		return res;
	}	
}
