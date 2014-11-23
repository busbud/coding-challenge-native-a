package jbm.busbud;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import jbm.busbud.fragment.BBSearchFragment;

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
            if (!pref.getBoolean(AppConstants.KEY_HAS_SEEN_HELP_ONCE, false)) {
                //Never tried the app, display the tuto
                getSupportFragmentManager().beginTransaction()
                        .add(R.id.container, new TutorialFragment())
                        .commit();
            } else {
                getSupportFragmentManager().beginTransaction()
                        .add(R.id.container, new BBSearchFragment())
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
                    // Save that we click on the button
                    SharedPreferences pref = v.getContext().getSharedPreferences(AppConstants.SHARED_PREF_NAME, Activity.MODE_PRIVATE);
                    pref.edit().putBoolean(AppConstants.KEY_HAS_SEEN_HELP_ONCE, true).commit();

                    // Then open the search fragment
                    try {
                        android.support.v4.app.FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
                        fragmentTransaction.replace(R.id.container, new BBSearchFragment());
                        fragmentTransaction.setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);
                        fragmentTransaction.commitAllowingStateLoss();
                    } catch (Exception e) {
                        Log.e(LOG_TAG, "Unbale to switch fragment", e);
                    }
                }
            });
            return rootView;
        }
    }
}
