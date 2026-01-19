/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Taqmeel Zubeir (https://taqmeelzube.ir)
 */

void main (string[] args) {
    Test.init (ref args);
    Alohomora.CipherManagerTest.init ();
    Test.run ();
}
