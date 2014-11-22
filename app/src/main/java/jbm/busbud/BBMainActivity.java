package jbm.busbud;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/**
 * Main Activity - Load the Tutorial or the BBSearchFragment
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBMainActivity extends ActionBarActivity {

    private static final String LOG_TAG = BBMainActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Basic activity layout with a Framelayout
        setContentView(R.layout.activity_bbmain);

        if (savedInstanceState == null) {
            SharedPreferences pref = getSharedPreferences(AppConstants.SHARED_PREF_NAME, Activity.MODE_PRIVATE);
            if (!pref.getBoolean(AppConstants.SHARED_PREF_NAME, false)) {
                //Never tried the app, display the tuto
                getSupportFragmentManager().beginTransaction()
                        .add(R.id.container, new TutorialFragment())
                        .commit();
            }
        }
    }

    /**
     * A Tutorial fragment when you open the app and you never tried
     */
    public static class TutorialFragment extends Fragment {

        public TutorialFragment() {
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.helpme_layout, container, false);
            rootView.findViewById(R.id.helpme_start).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //TODO
                }
            });
            return rootView;
        }
    }
}
