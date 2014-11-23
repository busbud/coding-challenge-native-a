package jbm.busbud.api;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.InputStream;
import java.util.ArrayList;

import jbm.busbud.model.BBCity;
import jbm.busbud.util.StringUtils;

/**
 * This helper is able to parse and handle an input stream of search API response
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBSearchHandlerHelper {

    public interface JSONNodes {
        String CITY_ID = "city_id";
        String CITY_URL = "city_url";
        String FULL_NAME = "full_name";
    }

    private static final String LOG_TAG = BBSearchHandlerHelper.class.getSimpleName();

    public static ArrayList<BBCity> parseJson(InputStream input) {
        ArrayList<BBCity> result = new ArrayList<BBCity>();

        try {
            JSONArray cities = new JSONArray(StringUtils.fromInputStream(input));
            for (int i = 0; i < cities.length(); i++) {
                JSONObject city = (JSONObject) cities.get(i);
                String cityId = city.optString(JSONNodes.CITY_ID);
                String cityUrl = city.optString(JSONNodes.CITY_URL);
                String fullName = city.optString(JSONNodes.FULL_NAME);
                if (!StringUtils.isEmpty(cityId) && !StringUtils.isEmpty(fullName)) {
                    BBCity cityObj = new BBCity(cityId, cityUrl, fullName);
                    result.add(cityObj);
                } else {
                    Log.e(LOG_TAG, "Missing mandatory parameters");
                }
            }
        } catch (JSONException e) {
            Log.e(LOG_TAG, "Houston, we got an API issue");
            // TODO through a event to new relic. Something is very wrong with our own APIs.
        }

        return result;
    }
}
