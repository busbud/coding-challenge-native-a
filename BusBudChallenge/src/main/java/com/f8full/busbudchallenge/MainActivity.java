package com.f8full.busbudchallenge;

import android.content.IntentSender;
import android.location.Location;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesClient;
import com.google.android.gms.location.LocationClient;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MainActivity extends ActionBarActivity implements
        GooglePlayServicesClient.ConnectionCallbacks,
        GooglePlayServicesClient.OnConnectionFailedListener {

    private static final String BUSBUD_API_ENDPOINT = "https://api-staging.busbud.com/";

    //default language
    private static String USER_LANG_CODE = "en";

    /*
     * Define a request code to send to Google Play services
     * This code is returned in Activity.onActivityResult
     */
    private final static int CONNECTION_FAILURE_RESOLUTION_REQUEST = 9000;

    private LocationClient mLocationClient;

    private String originUrlForm = "";

    private List<String> destUrlFormList = new ArrayList<String>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.container, new PlaceholderFragment())
                    .commit();
        }

        mLocationClient = new LocationClient(this, this, this);

        ActionBar actionBar = getSupportActionBar();
        actionBar.hide();

        new HttpAsyncTask().execute(BUSBUD_API_ENDPOINT + "en/api/v1/languages");
    }

    @Override
    protected void onStart() {
        super.onStart();
        // Connect the client.
        mLocationClient.connect();
    }

    @Override
    protected void onStop() {
        // Disconnecting the client invalidates it.
        mLocationClient.disconnect();
        super.onStop();
    }

    /**
     * A placeholder fragment containing a simple view.
     */
    public static class PlaceholderFragment extends Fragment {

        public PlaceholderFragment() {
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                Bundle savedInstanceState) {
            return inflater.inflate(R.layout.fragment_main, container, false);
        }
    }

    public void onShowTripClick(View v) {

        final String tripUrl = "http://www.busbud.com/" + USER_LANG_CODE + "/bus-schedules/" +
        originUrlForm + "/" + destUrlFormList.get(((Spinner)findViewById(R.id.destination_spinner)).getSelectedItemPosition());

        Fragment frag = new WebFragment();
        Bundle bundle = new Bundle();
        bundle.putString(WebFragment.EXTRA_URL, tripUrl);
        frag.setArguments(bundle);

        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.add(R.id.container, frag);
        ft.addToBackStack(WebFragment.class.getSimpleName());
        ft.commit();
    }


    private class HttpAsyncTask extends AsyncTask<String, Void, String> {
        @Override
        protected String doInBackground(String... urls) {

            InputStream inputStream;
            String result = "";
            try {

                // create HttpClient
                HttpClient httpclient = new DefaultHttpClient();

                // make GET request to the given URL
                HttpGet getRequest = new HttpGet(urls[0]);

                getRequest.addHeader("X-Busbud-Application-ID", BusbudCredentials.APP_ID);
                getRequest.addHeader("X-Busbud-Device-Token", BusbudCredentials.DEVICE_TOKEN);

                HttpResponse httpResponse = httpclient.execute(getRequest);

                // receive response as inputStream
                inputStream = httpResponse.getEntity().getContent();

                // convert inputstream to string
                if(inputStream != null)
                    result = convertInputStreamToString(inputStream);
                else
                    result = "Did not work!";

            } catch (Exception e) {
                Log.d("InputStream", e.getLocalizedMessage());
            }

            return result;
        }
        // onPostExecute displays the results of the AsyncTask.
        @Override
        protected void onPostExecute(String result) {
            //Toast.makeText(getBaseContext(), "Received!", Toast.LENGTH_LONG).show();
            //etResponse.setText(result);
            JSONObject resultJSON;

            try {

                resultJSON = new JSONObject(result);

                if(resultJSON.has("current"))
                {
                    ((TextView)findViewById(R.id.OriginTV)).setText(resultJSON.getJSONObject("current").getString("name"));

                    originUrlForm = resultJSON.getJSONObject("current").getString("urlform");

                    new HttpAsyncTask().execute(BUSBUD_API_ENDPOINT + USER_LANG_CODE +
                            "/api/v1/search/locations-from/" + originUrlForm);
                }
                else if (resultJSON.has("from"))
                {
                    setupDestinationSpinner(resultJSON);
                }

            }catch (Exception e) {
                try {
                    //Language answer is an array
                    JSONArray langArray = new JSONArray(result);

                    for (int i=0; i<langArray.length(); i++)
                    {
                        String code = langArray.getJSONObject(i).getString("code");
                        if (code.equals(Locale.getDefault().getLanguage()))
                        {
                            USER_LANG_CODE = code;
                            break;
                        }
                    }

                } catch (Exception e1){
                    Log.d("InputStream", e1.getLocalizedMessage());

                }

            }
        }

        private void setupDestinationSpinner(JSONObject resultJSON)
        {
            try {
                JSONArray locationsArray = resultJSON.getJSONArray("locations");

                final List<String> list=new ArrayList<String>();

                for (int i=0; i<locationsArray.length(); i++)
                {
                    list.add(locationsArray.getJSONObject(i).getString("name"));
                    destUrlFormList.add(locationsArray.getJSONObject(i).getString("urlform"));
                }

                final ArrayAdapter<String> adp= new ArrayAdapter<String>(getBaseContext(),
                        android.R.layout.simple_list_item_1,list);
                adp.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

                ((Spinner)findViewById(R.id.destination_spinner)).setAdapter(adp);
            }catch (Exception e) {
                Log.d("InputStream", e.getLocalizedMessage());
            }
        }


    }

    private static String convertInputStreamToString(InputStream inputStream) throws IOException {
        BufferedReader bufferedReader = new BufferedReader( new InputStreamReader(inputStream));
        String line;
        String result = "";
        while((line = bufferedReader.readLine()) != null)
            result += line;

        inputStream.close();
        return result;

    }

    /*
     * Called by Location Services when the request to connect the
     * client finishes successfully. At this point, you can
     * request the current location or start periodic updates
     */
    @Override
    public void onConnected(Bundle dataBundle) {
        // Display the connection status
        //Toast.makeText(this, "Connected", Toast.LENGTH_SHORT).show();

        Location userLocation = mLocationClient.getLastLocation();

        new HttpAsyncTask().execute(BUSBUD_API_ENDPOINT + USER_LANG_CODE +
                "/api/v1/search/locations/?latitude=" +
                String.valueOf(userLocation.getLatitude()) +
                "&longitude=" + String.valueOf(userLocation.getLongitude()) +
                "&accuracy=10");

    }
    /*
     * Called by Location Services if the connection to the
     * location client drops because of an error.
     */
    @Override
    public void onDisconnected() {
        // Display the connection status
        Toast.makeText(this, "Disconnected. Please re-connect.",
                Toast.LENGTH_SHORT).show();
    }
    /*
     * Called by Location Services if the attempt to
     * Location Services fails.
     */
    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        /*
         * Google Play services can resolve some errors it detects.
         * If the error has a resolution, try sending an Intent to
         * start a Google Play services activity that can resolve
         * error.
         */
        if (connectionResult.hasResolution()) {
            try {
                // Start an Activity that tries to resolve the error
                connectionResult.startResolutionForResult(
                        this,
                        CONNECTION_FAILURE_RESOLUTION_REQUEST);
                /*
                 * Thrown if Google Play services canceled the original
                 * PendingIntent
                 */
            } catch (IntentSender.SendIntentException e) {
                // Log the error
                e.printStackTrace();
            }
        } else {
            /*
             * If no resolution is available, display a dialog to the
             * user with the error.
             */
            //showErrorDialog(connectionResult.getErrorCode());
        }
    }

}
