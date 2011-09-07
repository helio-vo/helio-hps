package eu.heliovo.hps.server;

import java.util.Vector;


public class ApplicationDescription 
{
	String							name;
	String							id;
	String							description;
	String							executable;
	String							jdl;
	Vector<ApplicationParameter>	parameters;
	
	public ApplicationDescription() 
	{
		super();
		this.name 			=	"undefined";
		this.id				=	"undefined";	
		this.description 	= 	"undefined";
		this.executable 	= 	"undefined";
		this.jdl 			= 	"undefined";
	}
	
	public ApplicationDescription(String name, 
			String	id,
			String description,
			String executable,
			String jdl
			) 
	{
		super();
		this.name 			= 	name;
		this.id				=	id;
		this.description 	= 	description;
		this.executable 	= 	executable;
		this.jdl 			= 	jdl;
	}
	
	public ApplicationDescription(String name, 
			String	id,
			String description,
			String executable,
			String jdl,
			Vector<ApplicationParameter> parameters) 
	{
		super();
		this.name 			= 	name;
		this.id				=	id;
		this.description 	= 	description;
		this.executable 	= 	executable;
		this.parameters		=	parameters;
		this.jdl 			= 	jdl;
	}

	/**
	 * @return the parameters
	 */
	public Vector<ApplicationParameter> getParameters() {
		return parameters;
	}

	/**
	 * @param parameters the parameters to set
	 */
	public void setParameters(Vector<ApplicationParameter> parameters) {
		this.parameters = parameters;
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}
	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}
	
	public String getExecutable() {
		return executable;
	}

	public void setExecutable(String executable) {
		this.executable = executable;
	}

	/**
	 * @return the id
	 */
	public String getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}

	/**
	 * @return the description
	 */
	public String getDescription() {
		return description;
	}
	
	public String getJdl() {
		return jdl;
	}

	public void setJdl(String jdl) {
		this.jdl = jdl;
	}

	/**
	 * @param description the description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() 
	{
		String	res		=	"[";
		res				+=	name;
		res				+=	",";
		res				+=	id;
		res				+=	",";
		res				+=	description;
		res				+=	"]";

		return res;
	}


	public String getFullDescription() 
	{
		String	res		=	"[";
		res				+=	name;
		res				+=	"(";
		for(int index = 0; index < parameters.size(); index++)
		{
			res				+=	parameters.get(index).getShortDescription();
			if(index < parameters.size() -1);
			res				+=	", ";
		}
		res				+=	")";
		
		return res;
	}
}
