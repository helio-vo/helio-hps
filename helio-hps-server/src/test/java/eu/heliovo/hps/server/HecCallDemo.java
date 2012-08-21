package eu.heliovo.hps.server;

import java.net.URL;

import net.ivoa.xml.votable.v1.VOTABLE;

import org.junit.Before;
import org.junit.Test;
import org.springframework.context.support.GenericXmlApplicationContext;

import uk.ac.starlink.table.StarTable;
import uk.ac.starlink.votable.VOElement;

import eu.heliovo.clientapi.HelioClient;
import eu.heliovo.clientapi.query.HelioQueryResult;
import eu.heliovo.clientapi.query.QueryService;
import eu.heliovo.clientapi.utils.STILUtils;
import eu.heliovo.registryclient.HelioServiceName;

public class HecCallDemo {
    /**
     * The context must be created only once per JVM.
     */
    GenericXmlApplicationContext  context; 
    
    @Before public void setup() {
        // make sure to call this line only once in your whole application
        context = new GenericXmlApplicationContext("classpath*:/spring/clientapi-main.xml");
        
        // alternatively you can add your 
        //context = new GenericXmlApplicationContext("classpath*:/application-context.xml");
    }

    @Test public void sampleCallToHec() throws Exception {
        // every call like this will return the singelton instance of the helio client.
        HelioClient helioClient = (HelioClient) context.getBean("helioClient");
        
        // the null values can be safely ignored for this example. 
        QueryService hecService = (QueryService) helioClient.getServiceInstance(HelioServiceName.HEC, null, null);
        
        // now comes the acutal query.
        HelioQueryResult resultObject = hecService.query("2002-12-01T00:00:00", "2002-12-12T00:00:00", "goes_sxr_flare", -1, 0, null);
        
        // inspect the result
        // get a url to the VOTable (will be stored locally in user.home/.helio/...)
        URL url = resultObject.asURL();
        System.out.println(url);
        
        // read votable into a string
        String str = resultObject.asString();
        System.out.println(trunc(str, 1000));

        // convert  to a VOTable object which can be programmatically inspected.
        // this model was created by converting the VOTable XML Schema into a set of Java classes. 
        VOTABLE votable = resultObject.asVOTable();
        
        // alternatively you can use the Starlink STIL data model to analyse the VOTable data.
        // the starlink model does some Normalisation of the votable and thus looses some information.
        STILUtils stilUtils = (STILUtils)context.getBean("stilUtils");
        StarTable[] stilModel = stilUtils.read(url);
        
        // or you can use the VO model from stil which is comparable to the XML Schema model, but more user friendly.
        VOElement voelement = stilUtils.readVOElement(url);
    }
    
    /**
     * Truncate a string and append '...'
     * @param string the string to trunc
     * @param len the length of the string.
     * @return the truncated string followed by ...
     */
    private  String trunc(String string, int len) {
        if (string.length() <= len) {
            return string;
        }
        return string.substring(0, len) + "...";
    }
}
