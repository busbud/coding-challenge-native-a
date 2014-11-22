package jbm.busbud.api;

import android.location.Location;
import android.test.InstrumentationTestCase;

/**
 * Basic Unit tests
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class APIUrlsTests extends InstrumentationTestCase {
    @Override
    protected void setUp() throws Exception {
        super.setUp();
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
    }

    public void testAPIURLs() {
        Location basicLocation = new Location("gps");
        basicLocation.setLatitude(1.1);
        basicLocation.setLongitude(45.0);
        assertEquals(APIUrls.getSearchUrlWithArgs("fr", null, 1, null, null),
                "https://busbud-napi-prod.global.ssl.fastly.net/search?lang=fr&limit=1");
        assertEquals(APIUrls.getSearchUrlWithArgs("en", "Mont", 1, null, null),
                "https://busbud-napi-prod.global.ssl.fastly.net/search?lang=en&q=Mont&limit=1");
        assertEquals(APIUrls.getSearchUrlWithArgs("en", "Montréal City", 5, null, null),
                "https://busbud-napi-prod.global.ssl.fastly.net/search?lang=en&q=Montr%C3%A9al+City&limit=5");
        assertEquals(APIUrls.getSearchUrlWithArgs("fr", null, 1, basicLocation, "1234"),
                "https://busbud-napi-prod.global.ssl.fastly.net/search?lang=fr&origin_id=1234&limit=1&lat=1.1&lon=45.0");
    }
}