package jbm.busbud.util;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.NavUtils;
import android.support.v7.app.ActionBarActivity;
import android.view.MenuItem;

import java.lang.reflect.Constructor;

import jbm.busbud.R;

/**
 * An activity that display a fragment
 * Avoid to declare always the activities in the Manifest
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class SingleFragmentActivity extends ActionBarActivity {

    public static final String EXTRA_TITLE = "jbm.busbud.EXTRA_TITLE";
    public static final String EXTRA_CLASS = "jbm.busbud.EXTRA_CLASS";
    public static final String EXTRA_ARGS = "jbm.busbud.EXTRA_ARGS";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_bbmain);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowTitleEnabled(true);

        if (getIntent().hasExtra(EXTRA_TITLE)) {
            setTitle(getIntent().getStringExtra(EXTRA_TITLE));
        }

        FragmentManager fragmentManager = getSupportFragmentManager();

        if (findViewById(R.id.container) == null) {
            throw new IllegalArgumentException("R.id.container missing");
        }

        if (savedInstanceState == null) {
            try {
                FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
                Class<Fragment> fragmentClass = (Class<Fragment>) getIntent().getSerializableExtra(EXTRA_CLASS);
                Bundle args = getIntent().getParcelableExtra(EXTRA_ARGS);
                Constructor<Fragment> constructor = fragmentClass.getConstructor();
                Fragment fragment = constructor.newInstance(new Object[]{});
                fragment.setHasOptionsMenu(true);
                fragment.setArguments(args);
                fragmentTransaction.replace(R.id.container, fragment);
                fragmentTransaction.commitAllowingStateLoss();
            } catch (Exception e) {
                e.printStackTrace();
                finish();
            }
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
