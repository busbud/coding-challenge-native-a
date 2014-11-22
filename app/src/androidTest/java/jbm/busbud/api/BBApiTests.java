package jbm.busbud.api;

import android.location.Location;
import android.test.InstrumentationTestCase;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;

import java.util.ArrayList;
import java.util.Locale;

import jbm.busbud.model.BBCity;

/**
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBApiTests extends InstrumentationTestCase {

    private Location mLocation;

    public BBApiTests() {
        mLocation = new Location("gps");
        // Montreal
        mLocation.setLatitude(45.508669);
        mLocation.setLongitude(-73.553992);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
    }

    public void testBBHttpHelper() throws Exception {
        // Basic test
        HttpResponse response = BBHttpHelper.getInstance().httpGetBusBudUrl(APIUrls.getSearchUrlWithArgs(Locale.getDefault().getLanguage(), null, 5, mLocation, null));
        final int statusCode = response.getStatusLine().getStatusCode();
        assertTrue(statusCode == HttpStatus.SC_OK);
        if (statusCode == HttpStatus.SC_OK) {
            ArrayList<BBCity> results = BBSearchHandlerHelper.parseJson(response.getEntity().getContent());
            assertEquals(results.size(), 5);
        }
    }
}
