package jbm.busbud.model;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * The basic BusBud City object.
 * It's parcelable to be easily pass through Bundles.
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBCity implements Parcelable {

    private final String mCityId;
    private final String mCityUrl;
    private final String mFullName;

    public BBCity(String id, String url, String fullName) {
        mCityId = id;
        mCityUrl = url;
        mFullName = fullName;
    }

    private BBCity(Parcel in) {
        mCityId = in.readString();
        mCityUrl = in.readString();
        mFullName = in.readString();
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(mCityId);
        dest.writeString(mCityUrl);
        dest.writeString(mFullName);
    }

    public static final Parcelable.Creator<BBCity> CREATOR = new Parcelable.Creator<BBCity>() {
        public BBCity createFromParcel(Parcel in) {
            return new BBCity(in);
        }

        public BBCity[] newArray(int size) {
            return new BBCity[size];
        }
    };

    /**
     * Getters
     */

    public String getCityId() {
        return mCityId;
    }

    public String getCityUrl() {
        return mCityUrl;
    }

    public String getFullName() {
        return mFullName;
    }

    @Override
    public String toString() {
        return mFullName;
    }
}
