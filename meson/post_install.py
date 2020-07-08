#!/usr/bin/env python3

from os import path, environ
from subprocess import call

schema_dir = path.join(environ['MESON_INSTALL_PREFIX'], 'share', 'glib-2.0', 'schemas')
data_dir = path.join(environ.get('MESON_INSTALL_PREFIX', '/usr/local'), 'share')
desktop_database_dir = path.join(data_dir, 'applications')

if not environ.get('DESTDIR'):
    print('Compiling GSettings Schemas…')
    call(['glib-compile-schemas', schema_dir])
    print('Updating Desktop Database…')
    call(['update-desktop-database', '-q', desktop_database_dir])
    print('Updating Icon Cache…')
    call(['gtk-update-icon-cache', '-qtf', path.join(data_dir, 'icons', 'hicolor')])
