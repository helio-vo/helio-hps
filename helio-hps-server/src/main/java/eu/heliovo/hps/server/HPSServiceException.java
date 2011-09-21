package eu.heliovo.hps.server;

import javax.xml.ws.WebFault;

@WebFault
public class HPSServiceException extends Exception 
{
	private static final long serialVersionUID = 7352997547209987333L;

	public HPSServiceException(String string) 
	{
		super(string);
	}
}