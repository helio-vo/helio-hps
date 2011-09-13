package eu.heliovo.hps.server.application;

public class ApplicationParameter 
{
	String	name	=	null;
	String	type	=	null;
	String	value	=	null;
	String	def		=	null;

	public ApplicationParameter() 
	{
		super();
		this.name 	= "undefined";
		this.type 	= "undefined";
		this.value 	= "undefined";
		this.def 	= "undefined";
	}

	public ApplicationParameter(String name, 
			String type, 
			String value,
			String def) 
	{
		super();
		this.name  	= name;
		this.type  	= type;
		this.value 	= value;
		this.def	= def;
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
	public void setName(String name) 
	{
		this.name = name;
	}

	/**
	 * @return the type
	 */
	public String getType() 
	{
		return type;
	}

	/**
	 * @param type the type to set
	 */
	public void setType(String type) {
		this.type = type;
	}

	/**
	 * @return the value
	 */
	public String getValue() {
		return value;
	}

	/**
	 * @param value the value to set
	 */
	public void setValue(String value) {
		this.value = value;
	}

	
	public String getDef() 
	{
		return def;
	}

	public void setDef(String def) 
	{
		this.def = def;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() 
	{
		return "ApplicationParameter [" +
				"name=" + name + 
				", type=" + type + 
				", value=" + value + 
				", default_value=" + def + 
				"]";
	}
	
	public	String	getShortDescription()
	{
		return value;
	}
}
