package eu.heliovo.hps.utilities;

// Java classes
import java.util.*;
import java.text.*;

public class TimeUtilities 
{
	private SimpleDateFormat format = null;
	private String defaultFormat = "yyyyMMddHHmmssSSS";
	
	public TimeUtilities()
	{
		format = new SimpleDateFormat(defaultFormat);
	}

	public TimeUtilities(String timeFormat)
	{
		format = new SimpleDateFormat(timeFormat);
	}

	public void setFormat(String f)
	{
		format = new SimpleDateFormat(f);
	}

	public String getMiniStamp()
	{
		return getMiniStamp(new Date());
//        	Date now = new Date();
//        	setFormat("HH:mm:ss");	
//        	return format.format(now);
	}

	public String getShortStamp()
	{
        	Date now = new Date();
        	setFormat("EEE MMM dd yyyy - HH:mm:ss");	
        	return format.format(now);
	}

	public String getLongStamp()
	{
        	Date now = new Date();
        	setFormat("EEE MMM dd yyyy - HH:mm:ss.SSS");	
        	return format.format(now);
	}

	public String getCompactStamp()
	{
        	Date now = new Date();
        	setFormat("yyyyMMddHHmmssSSS");
        	return format.format(now);
	}

	public String getCompactStamp(Date d)
	{
        	setFormat("yyyyMMddHHmmssSSS");
        	return format.format(d);
	}

	public String getTimeStamp()
	{
        	Date now = new Date();
        	return format.format(now);
	}

	public String getMiniStamp(Date d)
	{
    	setFormat("HH:mm:ss");	
    	return format.format(d);
	}
}
