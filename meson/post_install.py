#!/usr/bin/env python3

from os import path, environ
from subprocess import call

schemadir = path.join(environ['MESON_INSTALL_PREFIX'], 'share', 'glib-2.0', 'schemas')

if not environ.get ('DESTDIR'):
    print('Compiling GSetting Schemas…')
    call(['glib-compile-schemas', schemadir])
