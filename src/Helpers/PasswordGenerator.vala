/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.PasswordGenerator {
    public static string generate () {
        const string LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
        const string UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const string DIGIT = "1234567890";
        const string SPECIAL = "!@#$%^&*+=><?";
        StringBuilder password = new StringBuilder ();
        Settings settings = new Settings ("io.github.z0o0p.alohomora");
        while (password.len < settings.get_int ("gen-pass-length")) {
            string next = "";
            switch (GLib.Random.int_range (0, 4)) {
                case 0:
                    next = LOWER_CASE[GLib.Random.int_range (0, LOWER_CASE.length)].to_string ();
                    break;
                case 1:
                    next = UPPER_CASE[GLib.Random.int_range (0, UPPER_CASE.length)].to_string ();
                    break;
                case 2:
                    if (settings.get_boolean ("include-digit")) {
                        next = DIGIT[GLib.Random.int_range (0, DIGIT.length)].to_string ();
                    }
                    break;
                case 3:
                    if (settings.get_boolean ("include-special")) {
                        next = SPECIAL[GLib.Random.int_range (0, SPECIAL.length)].to_string ();
                    }
                    break;
            }
            password.append (next);
        }
        return password.str;
    }
}
