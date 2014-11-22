package jbm.busbud.api;

import android.location.Location;
import android.widget.BaseAdapter;
import android.widget.Filter;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Locale;

import jbm.busbud.model.BBCity;
import jbm.busbud.util.BBException;

/**
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBSearchFilter extends Filter {

    //TODO
    private final BaseAdapter mAdapter;
    private final Location mLocation;

    public BBSearchFilter(Location location, BaseAdapter adapter) {
        mAdapter = adapter;
        mLocation = location;
    }

    @Override
    protected FilterResults performFiltering(CharSequence constraint) {
        // Asynchronous method - let's make the request!
        FilterResults filterResults = new FilterResults();
        if(constraint != null) {
            try {
                HttpResponse response = BBHttpHelper.getInstance().httpGetBusBudUrl(APIUrls.getSearchUrlWithArgs(Locale.getDefault().getLanguage(), null, 5, mLocation, null));
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
        if(results != null && results.count > 0) {
            mAdapter.notifyDataSetChanged();
        } else {
            mAdapter.notifyDataSetInvalidated();
        }
    }
}
