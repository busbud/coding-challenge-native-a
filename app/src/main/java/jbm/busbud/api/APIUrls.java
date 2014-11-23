package jbm.busbud.api;

import android.location.Location;
import android.util.Log;

import java.net.URLEncoder;
import java.util.Locale;

import jbm.busbud.util.StringUtils;

/**
 * Declare all API URL here and add some helper to compute args.
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class APIUrls {

    private static final String LOG_TAG = APIUrls.class.getSimpleName();

    private static final String BASE_URL = "https://busbud-napi-prod.global.ssl.fastly.net";

    /**
     * Authentication URL
     */
    public static final String AUTH_URL_BASE = BASE_URL + "/auth/guest";

    /**
     * Search URL and helper method
     */
    private static final String SEARCH_URL_BASE = BASE_URL + "/search";

    public static final String getSearchUrlWithArgs(String lang, String query, int limit, Location location, String originId) {
        // TODO add exception for mandatory parameters
        StringBuilder builder = new StringBuilder(SEARCH_URL_BASE);
        builder.append("?");
        int baseLength = builder.length();
        addParameter(builder, baseLength, "lang", lang);
        addParameter(builder, baseLength, "q", query);
        addParameter(builder, baseLength, "origin_id", originId);
        addParameter(builder, baseLength, "limit", Integer.toString(limit));
        if (location != null) {
            addParameter(builder, baseLength, "lat", Double.toString(location.getLatitude()));
            addParameter(builder, baseLength, "lon", Double.toString(location.getLongitude()));
        }
        String url = builder.toString();
        Log.d(LOG_TAG, String.format(Locale.US, "Url computed %s", url));
        return url;
    }

    /**
     * Add parameters to the url
     *
     * @param builder
     * @param baseUrlLenght
     * @param paramName
     * @param paramValue
     */
    private static void addParameter(StringBuilder builder, int baseUrlLenght, String paramName, String paramValue) {
        try {
            if (!StringUtils.isEmpty(paramValue)) {
                if (baseUrlLenght != builder.length()) {
                    builder.append("&");
                }
                builder.append(paramName).append("=").append(URLEncoder.encode(paramValue, "UTF-8"));
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, String.format(Locale.US, "Unable to process parameter %s / %s", paramName, paramValue));
        }
    }
}
