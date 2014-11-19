package com.njzk2.busbud.busbudchallenge;

import android.app.Activity;
import android.app.Dialog;
import android.app.DialogFragment;
import android.app.ProgressDialog;
import android.location.Location;
import android.os.AsyncTask;
import android.os.Bundle;

import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.njzk2.busbud.busbudchallenge.api.City;
import com.njzk2.busbud.busbudchallenge.api.Token;

import java.util.List;
import java.util.Locale;

/**
 * Created by simon on 18/11/14.
 */
public class LocationFragment extends DialogFragment implements GoogleApiClient.ConnectionCallbacks {
    private GoogleApiClient client;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        client = new GoogleApiClient.Builder(activity)
                .addApi(LocationServices.API)
                .addConnectionCallbacks(this)
                .build();
        client.connect();
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        ProgressDialog dialog = new ProgressDialog(getActivity());
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.setIndeterminate(true);
        dialog.setMessage(getString(R.string.searching));

        return dialog;
    }

    @Override
    public void onConnected(Bundle bundle) {
        LocationServices.FusedLocationApi.requestLocationUpdates(client, LocationRequest.create(), new com.google.android.gms.location.LocationListener() {
            @Override
            public void onLocationChanged(final Location location) {

                new AsyncTask<Location, Void, City>() {

                    @Override
                    protected City doInBackground(Location... loc) {
                        Location location = loc[0];
                        List<City> cities = MainActivity.service.getCity(MainActivity.getToken(), Locale.getDefault().getLanguage(),
                                location.getLatitude(), location.getLongitude());
                        if (cities != null && cities.size() > 0) {
                            return cities.get(0);
                        }
                        return null;
                    }

                    @Override
                    protected void onPostExecute(City city) {
                        if (getActivity() != null) {
                            ((CityListener) getActivity()).found(city);
                        }
                        dismiss();
                    }
                }.execute(location);

                LocationServices.FusedLocationApi.removeLocationUpdates(client, this);
                client.disconnect();
            }
        });
    }

    @Override
    public void onConnectionSuspended(int i) {

    }
}
