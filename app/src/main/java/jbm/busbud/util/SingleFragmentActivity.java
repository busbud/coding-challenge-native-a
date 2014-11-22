package jbm.busbud.util;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

import java.lang.reflect.Constructor;

import jbm.busbud.R;

/**
 * An activity that display a fragment
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class SingleFragmentActivity extends FragmentActivity {

    public static final String EXTRA_TITLE = "jbm.busbud.EXTRA_TITLE";
    public static final String EXTRA_CLASS = "jbm.busbud.EXTRA_CLASS";
    public static final String EXTRA_ARGS = "jbm.busbud.EXTRA_ARGS";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getIntent().hasExtra(EXTRA_TITLE)) {
            setTitle(getIntent().getStringExtra(EXTRA_TITLE));
        }

        FragmentManager fragmentManager = getFragmentManager();

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
                finish();
            }
        }
    }
}
