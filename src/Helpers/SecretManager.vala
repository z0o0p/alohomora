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

public class Alohomora.SecretManager: GLib.Object {
    public signal void key_validated (bool is_validated);
    public signal void key_changed (bool is_changed);

    private Secret.Schema cipher_schema () {
        var schema = new Secret.Schema (
            "com.github.z0o0p.alohomora.cipher", Secret.SchemaFlags.NONE,
            "user-name", Secret.SchemaAttributeType.STRING
        );
        return schema;
    }

    public async void create_cipher_key (string user_name, string cipher_key) {
        try {
            var res = yield Secret.password_store (
                cipher_schema (),
                Secret.COLLECTION_DEFAULT,
                "Alohomora Cipher",
                cipher_key,
                null,
                "user-name", user_name,
                null
            );
            key_validated (res);
        }
        catch (Error err) {
            warning ("%s", err.message);
        }
    }

    public async void lookup_cipher_key (string user_name, string entered_cipher_key) {
        try {
            var key = yield Secret.password_lookup (
                cipher_schema (),
                null,
                "user-name", user_name,
                null
            );
            key_validated (entered_cipher_key == key);
        }
        catch (Error err) {
            warning("%s", err.message);
        }
    }

    public async void change_cipher_key (string user_name, string old_key, string new_key) {
        try {
            var key = yield Secret.password_lookup (
                cipher_schema (),
                null,
                "user-name", user_name,
                null
            );
            if(key == old_key) {
                var res = yield Secret.password_store (
                    cipher_schema (),
                    Secret.COLLECTION_DEFAULT,
                    "Alohomora Cipher",
                    new_key,
                    null,
                    "user-name", user_name,
                    null
                );
                key_changed (res);
            }
            else {
                key_changed (false);
            }
        }
        catch(Error err) {
            warning("%s", err.message);
        }
    }
}
