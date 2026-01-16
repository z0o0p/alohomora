/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
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
