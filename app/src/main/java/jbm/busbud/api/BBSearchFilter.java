package jbm.busbud.api;

import android.location.Location;
import android.widget.Filter;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Locale;

import jbm.busbud.model.BBCity;
import jbm.busbud.util.BBException;

/**
 * For AutoCompleteText background processing
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBSearchFilter extends Filter {

    private final BBAPIListener mListener;
    private Location mLocation;

    private BBCity mOriginCity;

    public BBSearchFilter(BBAPIListener listener) {
        mListener = listener;
    }

    public void setLocation(Location location) {
        mLocation = location;
    }

    public void setOriginCity(BBCity originCity) {
        mOriginCity = originCity;
    }

    @Override
    protected FilterResults performFiltering(CharSequence constraint) {
        // Asynchronous method - let's make the request!
        FilterResults filterResults = new FilterResults();
        if (constraint != null) {
            try {
                String filterString = constraint.toString().toLowerCase();
                HttpResponse response = BBHttpHelper.getInstance().httpGetBusBudUrl(
                        APIUrls.getSearchUrlWithArgs(
                                Locale.getDefault().getLanguage(), filterString, 4,
                                mLocation == null ? null : mLocation,
                                mOriginCity == null ? null : mOriginCity.getCityId()));
                final int statusCode = response.getStatusLine().getStatusCode();
                if (statusCode == HttpStatus.SC_OK) {
                    ArrayList<BBCity> results = BBSearchHandlerHelper.parseJson(response.getEntity().getContent());
                    filterResults.values = results;
                    filterResults.count = results.size();
                    return filterResults;
                }
            } catch (BBException e) {
                // Do nothing
            } catch (IOException e) {
                // Do nothing
            }
        }
        return filterResults;
    }

    @Override
    protected void publishResults(CharSequence contraint, FilterResults results) {
        // Main thread
        if (mListener != null) {
            if (results != null && results.count > 0) {
                mListener.onSuccess((ArrayList<BBCity>) results.values);
            } else {
                mListener.onError();
            }
        }
    }
}
