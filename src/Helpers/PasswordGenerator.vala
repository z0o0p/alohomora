/*
* Copyright (c) 2020 Taqmeel Zubeir
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Taqmeel Zubeir <taqmeelzubeir.dev@gmail.com>
*/

public class Alohomora.PasswordGenerator {
    public static string generate () {
        const string LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
        const string UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const string DIGIT = "1234567890";
        const string SPECIAL = "!@#$%^&*+=><?";
        StringBuilder password = new StringBuilder ();
        Settings settings = new Settings ("com.github.z0o0p.alohomora");
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
