/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

public class Alohomora.CipherManagerTest {
    public static void init () {
        Test.add_func ("/cipher_manager/encipher_simple_text", () => {
            var secret = "alohomora";
            var key = "my-secret-key";
            assert (Alohomora.CipherManager.encipher (secret, key) != secret);
        });

        Test.add_func ("/cipher_manager/decipher_simple_text", () => {
            var secret = "alohomora";
            var key = "my-secret-key";
            assert (Alohomora.CipherManager.decipher (Alohomora.CipherManager.encipher (secret, key), key) == secret);
        });

        Test.add_func ("/cipher_manager/decipher_complex_text", () => {
            var secret = "Al0h0m0r4";
            var key = "my-secret-key";
            assert (Alohomora.CipherManager.decipher (Alohomora.CipherManager.encipher (secret, key), key) == secret);
        });
    }
}
