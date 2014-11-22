package jbm.busbud.fragment;

import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import jbm.busbud.R;
import jbm.busbud.api.BBAPIListener;
import jbm.busbud.api.BBAsyncTaskSearch;
import jbm.busbud.api.BBSearchFilter;
import jbm.busbud.model.BBCity;
import jbm.busbud.util.LocationHelper;

/**
 * The Search UI
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBSearchFragment extends Fragment implements LocationListener, BBAPIListener {

    private LocationManager mLocationManager;

    private static final long MIN_TIME = 15 * 1000; // 15 seconds
    private static final float MIN_DISTANCE = 400; // 400 meters

    private AutoCompleteTextView mFrom;
    private AutoCompleteTextView mTo;
    private Button mSearchButton;
    private TextView mState;
    private Location mLocation;

    private BBCity mFromCity;
    private BBCity mToCity;

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        if (container == null) {
            return null;
        }

        View rootView = inflater.inflate(R.layout.search_layout, container, false);
        mFrom = (AutoCompleteTextView) rootView.findViewById(R.id.from);
        mTo = (AutoCompleteTextView) rootView.findViewById(R.id.to);
        mSearchButton = (Button) rootView.findViewById(R.id.search);
        mState = (TextView) rootView.findViewById(R.id.state);

        // Disable and wait for position
        enableInputs(false);

        return rootView;
    }


    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mFrom = null;
        mTo = null;
        mSearchButton = null;
        mState = null;
    }

    private void enableInputs(boolean enabled) {
        enableInput(mFrom, enabled);
        enableInput(mTo, enabled);
        enableInput(mSearchButton, enabled);
    }

    private void enableInput(View view, boolean enabled) {
        if (view != null) {
            view.setEnabled(enabled);
            view.setSelected(false);
        }
    }

    @Override
    public void onStart() {
        // Called when the Fragment is visible to the user.
        super.onStart();
        if (mLocationManager == null) {
            mLocationManager = (LocationManager) getActivity().getSystemService(Context.LOCATION_SERVICE);
        }
        // Start Monitoring GPS position and wait for a position (or use the last good one)
        startTrackingPosition();
    }

    @Override
    public void onStop() {
        // Called when the Fragment is no longer started.
        super.onStop();
        // Stop monitoring position if we did'nt have a position yet
        stopTrackingPosition();
    }

    @Override
    public void onError() {
        if (mState != null) {
            mState.setVisibility(View.VISIBLE);
            mState.setText(R.string.finding_city_error);
        }
    }

    @Override
    public void onSuccess(ArrayList<BBCity> cities) {
        if (cities == null || cities.size() == 0) {
            if (mState != null) {
                mState.setVisibility(View.VISIBLE);
                mState.setText(R.string.finding_city_error);
            }
            return;
        }
        if (mState != null) {
            mState.setVisibility(View.INVISIBLE);
        }

        final BBCity currentCity = cities.get(0);
        mFrom.setText(currentCity.getFullName());
        mFromCity = currentCity;

        enableInputs(true);
    }

    // Let's do the trick with the AutoCompleteAdapter
    public class AutoCompleteAdapter extends ArrayAdapter<BBCity> implements Filterable {
        private ArrayList<BBCity> mData;

        public AutoCompleteAdapter(Context context, int textViewResourceId) {
            super(context, textViewResourceId);
            mData = new ArrayList<BBCity>();
        }

        @Override
        public int getCount() {
            return mData.size();
        }

        @Override
        public BBCity getItem(int index) {
            return mData.get(index);
        }

        @Override
        public Filter getFilter() {
            return new BBSearchFilter(null, this);
        }
    }

    private interface State {
        public static final int NO_LOCATION_AVAILABLE = 0;
        public static final int WAITING_FOR_LOCATION = 1;
        public static final int ACCURATE_COORDINATES = 2;
    }

    /***
     * GPS LOCATION METHODS
     */

    /**
     * Method to update the UI depending on the state of the location
     *
     * @param state
     * @param location
     */
    private void update(int state, Location location) {
        switch (state) {
            case State.NO_LOCATION_AVAILABLE:
                // Display error
                if (mState != null) {
                    mState.setVisibility(View.VISIBLE);
                    mState.setText(R.string.no_location_available);
                }
                break;
            case State.WAITING_FOR_LOCATION:
                if (mState != null) {
                    mState.setVisibility(View.VISIBLE);
                    mState.setText(R.string.geolocation_in_progress);
                }
                break;
            case State.ACCURATE_COORDINATES:
                // Do need to track position anymore
                stopTrackingPosition();
                mLocation = location;
                if (mState != null) {
                    mState.setVisibility(View.INVISIBLE);
                }
                new BBAsyncTaskSearch(this).execute(location);
                break;
        }
    }

    public void startTrackingPosition() {
        // List all the position providers available on device
        final List<String> providers = mLocationManager.getProviders(false);
        providers.remove("passive"); // hack in order to remove that provider that does nothing

        boolean foundActive = false;
        Location location = null;

        if (providers.size() == 0) {
            // Device does not have GPS, we are stuck.
            update(State.NO_LOCATION_AVAILABLE, null);
        } else {
            for (String provider : providers) {
                if (mLocationManager.isProviderEnabled(provider)) {
                    // We found one active we will be able to display a loader
                    foundActive = true;
                }
                location = mLocationManager.getLastKnownLocation(provider);
                if (location != null && LocationHelper.isRelevantPosition(location)) {
                    break;
                } else {
                    mLocationManager.requestLocationUpdates(provider, MIN_TIME, MIN_DISTANCE, this);
                }
            }
            if (location != null) {
                update(State.ACCURATE_COORDINATES, location);
            } else {
                if (foundActive) {
                    update(State.WAITING_FOR_LOCATION, null);
                } else {
                    update(State.NO_LOCATION_AVAILABLE, null);
                }
            }
        }
    }

    public void stopTrackingPosition() {
        mLocationManager.removeUpdates(this);
    }

    @Override
    public void onLocationChanged(Location location) {
        update(State.ACCURATE_COORDINATES, location);
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
        // Do nothing
    }

    @Override
    public void onProviderEnabled(String provider) {
        Location location = mLocationManager.getLastKnownLocation(provider);
        if (location != null && LocationHelper.isRelevantPosition(location)) {
            update(State.ACCURATE_COORDINATES, location);
        } else {
            update(State.WAITING_FOR_LOCATION, null);
        }
    }

    @Override
    public void onProviderDisabled(String provider) {
        // Do nothing
    }
}
