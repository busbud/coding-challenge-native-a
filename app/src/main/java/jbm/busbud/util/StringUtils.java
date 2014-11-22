package jbm.busbud.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringWriter;
import java.io.Writer;

/**
 * Various vital Java utils
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class StringUtils {

    /**
     * Convert an input stream into a String
     *
     * @param input
     * @return
     */
    public static String fromInputStream(InputStream input) {

        if (input == null) {
            return null;
        }

        try {
            Writer writer = new StringWriter();
            Reader reader = new BufferedReader(new InputStreamReader(input, "utf-8"));

            char[] buffer = new char[1024];
            int len;
            while ((len = reader.read(buffer)) > 0) {
                writer.write(buffer, 0, len);
            }

            input.close();
            return writer.toString();
        } catch (IOException e) {
            return null;
        } finally {
            try {
                input.close();
            } catch (IOException ioe) {
                // Do nothing
            }
        }
    }

    /**
     * Check if the String is empty or null
     *
     * @param str
     * @return
     */
    public static boolean isEmpty(CharSequence str) {
        return str == null || str.length() == 0;
    }
}
