package com.njzk2.busbud.busbudchallenge;

import com.njzk2.busbud.busbudchallenge.api.City;

/**
 * Created by simon on 18/11/14.
 */
public interface CityListener {

    public void selected(City origin, City destination);
}
