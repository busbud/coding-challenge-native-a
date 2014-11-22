package jbm.busbud.api;

import android.os.AsyncTask;

import java.util.ArrayList;

import jbm.busbud.model.BBCity;

/**
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBAsyncTaskSearch extends AsyncTask<Void, Void, ArrayList<BBCity>> {

    @Override
    protected ArrayList<BBCity> doInBackground(Void... params) {
        return null;
    }

    @Override
    protected void onPostExecute(ArrayList<BBCity> bbCities) {
        super.onPostExecute(bbCities);
    }
}
