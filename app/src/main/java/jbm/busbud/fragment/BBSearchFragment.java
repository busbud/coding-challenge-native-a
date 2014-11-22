package jbm.busbud.fragment;

import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;
import android.widget.Toast;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import jbm.busbud.R;
import jbm.busbud.api.BBAPIListener;
import jbm.busbud.api.BBAsyncTaskSearch;
import jbm.busbud.api.BBSearchFilter;
import jbm.busbud.model.BBCity;
import jbm.busbud.util.LocationHelper;
import jbm.busbud.util.SingleFragmentActivity;

/**
 * The Search UI
 * - Localized the User
 * - Make a single call to the API to init the From with hte closest city and set the origin city
 * - Use of AutocompleteTextView to choose destination
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBSearchFragment extends Fragment implements LocationListener {

    /**
     * On error we invalidate the search list
     * On success we change the data
     */
    private static final class BBSearchAPIListenerImpl implements BBAPIListener {

        private WeakReference<AutoCompleteTextView> mView;

        public BBSearchAPIListenerImpl(AutoCompleteTextView view) {
            mView = new WeakReference<AutoCompleteTextView>(view);
        }

        @Override
        public void onError() {
            AutoCompleteTextView view = mView.get();
            if (view != null) {
                ((BaseAdapter) view.getAdapter()).notifyDataSetInvalidated();
            }
        }

        @Override
        public void onSuccess(ArrayList<BBCity> cities) {
            AutoCompleteTextView view = mView.get();
            if (view != null) {
                ((AutoCompleteAdapter) view.getAdapter()).setData(cities);
                ((BaseAdapter) view.getAdapter()).notifyDataSetChanged();
            }
        }
    }

    private LocationManager mLocationManager;

    private static final long MIN_TIME = 15 * 1000; // 15 seconds
    private static final float MIN_DISTANCE = 400; // 400 meters

    private AutoCompleteTextView mFrom;
    private AutoCompleteTextView mTo;
    private Button mSearchButton;
    private TextView mState;

    private BBCity mFromCity;
    private BBCity mToCity;

    private BBSearchFilter mFromSearchFilter;

    private BBSearchFilter mToSearchFilter;

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        if (container == null) {
            return null;
        }

        View rootView = inflater.inflate(R.layout.search_layout, container, false);

        mSearchButton = (Button) rootView.findViewById(R.id.search);
        mSearchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mFromCity != null && mToCity != null) {
                    // We can search, launch the generic view with the search fragment
                    Intent intent = new Intent(v.getContext(), SingleFragmentActivity.class);
                    intent.putExtra(SingleFragmentActivity.EXTRA_TITLE, String.format(Locale.US, "%s > %s", mFromCity.getShortName(), mToCity.getShortName()));
                    intent.putExtra(SingleFragmentActivity.EXTRA_CLASS, BBResultFragment.class);
                    Bundle args = new Bundle();
                    args.putParcelable(BBResultFragment.ARGS_FROM, mFromCity);
                    args.putParcelable(BBResultFragment.ARGS_TO, mToCity);
                    intent.putExtra(SingleFragmentActivity.EXTRA_ARGS, args);
                    getActivity().startActivity(intent);
                } else {
                    // Display a toast, the user has to choose valid cities!!!
                    Toast.makeText(v.getContext(), R.string.choose_a_valid_city, Toast.LENGTH_SHORT).show();
                }
            }
        });

        mFrom = (AutoCompleteTextView) rootView.findViewById(R.id.from);
        mFrom.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                // Reset the text on focus
                if (hasFocus) {
                    mFrom.setText(null);
                    mFromCity = null;
                    mTo.setText(null);
                    mToCity = null;
                }
            }
        });
        mFrom.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                mFromCity = (BBCity) parent.getAdapter().getItem(position);
                // Change the from city
                mToSearchFilter.setOriginCity(mFromCity);
                mTo.requestFocus();
                if (mFromCity != null) {
                    mFrom.setText(mFromCity.getFullName());
                }
            }
        });
        mFromSearchFilter = new BBSearchFilter(new BBSearchAPIListenerImpl(mFrom));
        mFrom.setAdapter(new AutoCompleteAdapter(container.getContext(), mFromSearchFilter));

        mTo = (AutoCompleteTextView) rootView.findViewById(R.id.to);
        mTo.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                // Reset the text on focus
                if (hasFocus) {
                    mTo.setText(null);
                    mToCity = null;
                }
            }
        });
        mTo.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                mToCity = (BBCity) parent.getAdapter().getItem(position);
                if (mToCity != null && mFromCity != null) {
                    mSearchButton.requestFocus();
                }
                if (mToCity != null) {
                    mTo.setText(mToCity.getFullName());
                }
            }
        });
        mToSearchFilter = new BBSearchFilter(new BBSearchAPIListenerImpl(mTo));
        mTo.setAdapter(new AutoCompleteAdapter(container.getContext(), mToSearchFilter));

        mState = (TextView) rootView.findViewById(R.id.state);

        return rootView;
    }


    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mFrom.setText(null);
        mTo.setText(null);

        mFrom = null;
        mTo = null;
        mSearchButton = null;
        mState = null;
        mFromCity = null;
        mToCity = null;
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

    // Let's do the trick with the AutoCompleteAdapter
    public class AutoCompleteAdapter extends ArrayAdapter<BBCity> implements Filterable {
        private ArrayList<BBCity> mData;
        private final BBSearchFilter mFilter;

        public AutoCompleteAdapter(Context context, BBSearchFilter filter) {
            super(context, 0);
            mData = new ArrayList<BBCity>();
            mFilter = filter;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            // Recycle views
            TextView listItemView = (TextView) convertView;

            if (listItemView == null) {
                listItemView = new TextView(getContext());
            }

            listItemView.setText(getItem(position).getFullName());

            return listItemView;
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
            return mFilter;
        }

        public void setData(ArrayList<BBCity> data) {
            mData = data;
        }
    }

    /**
     * GPS LOCATION METHODS
     */

    private interface State {
        public static final int NO_LOCATION_AVAILABLE = 0;
        public static final int WAITING_FOR_LOCATION = 1;
        public static final int ACCURATE_COORDINATES = 2;
    }

    /**
     * Method to update the UI depending on the state of the location
     *
     * @param state
     * @param location
     */
    private void update(int state, final Location location) {
        if (state == State.ACCURATE_COORDINATES && location == null) {
            //Security
            state = State.NO_LOCATION_AVAILABLE;
        }
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
                if (mState != null) {
                    mState.setVisibility(View.VISIBLE);
                    mState.setText(R.string.finding_city);
                }
                new BBAsyncTaskSearch(new BBAPIListener() {
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
                        // Set the origin city
                        mToSearchFilter.setOriginCity(currentCity);
                        mToSearchFilter.setLocation(location);
                        mFromSearchFilter.setLocation(location);

                        // Focus in To and erase value as the from has changed
                        mTo.setText(null);
                        mToCity = null;
                        mTo.requestFocus();

                        // Enable inputs now we are localized!
                        enableInput(mFrom, true);
                        enableInput(mTo, true);
                        enableInput(mSearchButton, true);
                        mSearchButton.setClickable(true);
                    }
                }).execute(location);
                break;
        }
    }

    private void enableInput(View view, boolean enabled) {
        if (view != null) {
            view.setEnabled(enabled);
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
