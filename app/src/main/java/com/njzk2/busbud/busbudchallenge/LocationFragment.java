package com.njzk2.busbud.busbudchallenge;

import android.app.Dialog;
import android.app.DialogFragment;
import android.app.ProgressDialog;
import android.os.Bundle;

/**
 * Created by niluge on 18/11/14.
 */
public class LocationFragment extends DialogFragment {
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        ProgressDialog dialog = new ProgressDialog(getActivity());
        dialog.setCancelable(false);
        dialog.setIndeterminate(true);
        dialog.setTitle(R.string.searching);
        ((CityListener) getActivity()).found();

        return dialog;
    }
}
