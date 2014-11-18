package com.njzk2.busbud.busbudchallenge;

import android.app.Activity;
import android.app.Dialog;
import android.app.DialogFragment;
import android.app.ProgressDialog;
import android.location.Location;
import android.os.Bundle;

import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;

/**
 * Created by niluge on 18/11/14.
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
        dialog.setIndeterminate(true);
        dialog.setTitle(R.string.searching);

        return dialog;
    }

    @Override
    public void onConnected(Bundle bundle) {
        LocationServices.FusedLocationApi.requestLocationUpdates(client, LocationRequest.create(), new com.google.android.gms.location.LocationListener() {
            @Override
            public void onLocationChanged(final Location location) {

                ((CityListener) getActivity()).found();

                LocationServices.FusedLocationApi.removeLocationUpdates(client, this);
                client.disconnect();
            }
        });
    }

    @Override
    public void onConnectionSuspended(int i) {

    }
}
