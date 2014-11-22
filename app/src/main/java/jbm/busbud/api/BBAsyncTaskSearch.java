package jbm.busbud.api;

import android.location.Location;
import android.os.AsyncTask;
import android.util.Log;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Locale;

import jbm.busbud.model.BBCity;

/**
 * The search task for the initialized called
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBAsyncTaskSearch extends AsyncTask<Location, Void, ArrayList<BBCity>> {

    private static final String LOG_TAG = BBAsyncTaskSearch.class.getSimpleName();

    private BBAPIListener mListener;

    public BBAsyncTaskSearch(BBAPIListener listener) {
        mListener = listener;
    }

    @Override
    protected ArrayList<BBCity> doInBackground(Location... params) {
        if (params == null || params.length == 0) {
            return null;
        }
        ArrayList<BBCity> results = null;
        try {
            HttpResponse response = BBHttpHelper.getInstance().httpGetBusBudUrl(APIUrls.getSearchUrlWithArgs(Locale.getDefault().getLanguage(), null, 1, params[0], null));
            final int statusCode = response.getStatusLine().getStatusCode();
            if (statusCode == HttpStatus.SC_OK) {
                results = BBSearchHandlerHelper.parseJson(response.getEntity().getContent());
            }
        } catch (Exception e) {
            Log.e(LOG_TAG, "Error while calling API", e);
        }
        return results;
    }

    @Override
    protected void onPostExecute(ArrayList<BBCity> bbCities) {
        super.onPostExecute(bbCities);
        if (mListener != null) {
            if (bbCities != null) {
                mListener.onSuccess(bbCities);
            } else {
                mListener.onError();
            }
        }
    }
}
