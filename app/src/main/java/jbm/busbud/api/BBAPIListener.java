package jbm.busbud.api;

import java.util.ArrayList;

import jbm.busbud.model.BBCity;

/**
 * To listen to result from AsyncTask
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public interface BBAPIListener {

    /**
     * If an error occured
     */
    void onError();

    /**
     * If we got a 200OK
     * @param cities the list of cities
     */
    void onSuccess(ArrayList<BBCity> cities);
}
