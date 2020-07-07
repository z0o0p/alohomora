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

public class Alohomora.CipherManager {
    public static string encipher (string secret, string key) {
        int len = secret.char_count ();
        int key_len = key.char_count ();
        string cipher = "";
        string modified_key = "";
        char character;
        for (int i = 0, j = 0; i < len; i++, j++) {
            if (j == key_len) {
                j = 0;
            }
            modified_key = modified_key.concat (key[j].to_string ());
        }
        for (int i = 0; i < len; i++) {
            if (secret[i].isalpha ()) {
                character = ((secret[i].toupper () + modified_key[i].toupper ()) % 26) + 'A';
                if (secret[i].islower ()) {
                    cipher += character.tolower ().to_string ();
                }
                else {
                    cipher += character.to_string ();
                }
            }
            else {
                cipher += secret[i].to_string ();
            }
        }
        return cipher;
    }

    public static string decipher (string cipher, string key) {
        int len = cipher.char_count ();
        int key_len = key.char_count ();
        string secret = "";
        string modified_key = "";
        unichar character;
        for (int i = 0, j = 0; i < len; i++, j++) {
            if (j == key_len) {
                j = 0;
            }
            modified_key = modified_key.concat (key[j].to_string ());
        }
        for (int i = 0; i < len; i++) {
            if (cipher[i].isalpha ()) {
                character = (((cipher[i].toupper () - modified_key[i].toupper ()) + 26) % 26) + 'A';
                if(cipher[i].islower ()) {
                    secret += character.tolower ().to_string ();
                }
                else {
                    secret += character.to_string ();
                }
            }
            else {
                secret += cipher[i].to_string ();
            }
        }
        return secret;
    }
}
